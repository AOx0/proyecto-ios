use std::sync::Arc;

use axum::{
    debug_handler,
    extract::{Path, State},
    http::{Response, StatusCode},
    response::{Html, IntoResponse},
    routing::{get, patch, post},
    Json, Router, Server,
};
use serde::{Deserialize, Serialize};
use sqlx::postgres::PgPoolOptions;
use sqlx::prelude::*;

#[derive(Debug, FromRow)]
struct Cliente {
    id: i64,
    modelo: String,
}

//TODO: Re-hacer esto
#[derive(Debug, Serialize, Deserialize, FromRow)]
struct Grupo {
    id_conductor: i32,
    puntuacion_min: i64,
    id_owner: i32,
}

#[allow(dead_code)]
#[derive(FromRow, Debug)]
struct Automovil {
    id_placas: i32,
    asientos: i64,
    dueño: i32,
    niv: i64,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
struct RegisterUser {
    nombre: String,
    apellido: String,
    fecha_nacimiento: String,
    correo: String,
    telefono: String,
    password: String,
    // licencia: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
struct Correo {
    correo: String,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
struct LogIn {
    correo: String,
    password: String,
}

#[debug_handler]
async fn register_user(
    State(state): State<Arc<AppState>>,
    Json(new_user): Json<RegisterUser>,
) -> impl IntoResponse {
    let RegisterUser {
        nombre,
        apellido,
        fecha_nacimiento,
        correo,
        telefono,
        password,
        // licencia,
    } = new_user;

    let new_mail: Vec<Correo> = sqlx::query_as::<_, Correo>(&format!(
        "SELECT correo FROM usuario WHERE correo = '{correo}'"
    ))
    .fetch_all(&mut state.db_pool.acquire().await.unwrap())
    .await
    .unwrap();

    if new_mail.is_empty() {
        sqlx::query(&format!("INSERT INTO usuario(nombre, apellido, fecha_nacimiento, correo, telefono, password) VALUES ('{nombre}', '{apellido}', '{fecha_nacimiento}', '{correo}', '{telefono}', '{password}')")).execute(&mut state.db_pool.acquire().await.unwrap()).await.unwrap();

        (StatusCode::CREATED, "Usuario Creado")
    } else {
        (StatusCode::FOUND, "EL correo ya esta en uso")
    }
}

async fn login(State(state): State<Arc<AppState>>, Json(log): Json<LogIn>) -> impl IntoResponse {
    let LogIn { correo, password } = log;

    let login: Vec<LogIn> = sqlx::query_as::<_, LogIn>(&format!(
        "SELECT correo, password FROM usuario WHERE correo = '{correo}' and password = '{password}' "
    ))
    .fetch_all(&mut state.db_pool.acquire().await.unwrap())
    .await
    .unwrap();
    // println!("{:?}", login);

    if !login.is_empty() {
        (StatusCode::ACCEPTED, "LogIn exitoso")
    } else {
        (
            StatusCode::NON_AUTHORITATIVE_INFORMATION,
            "Error en algun campo",
        )
    }
}

async fn new_group(
    State(state): State<Arc<AppState>>,
    Json(grup): Json<Grupo>,
) -> impl IntoResponse {
    let Grupo {
        id_conductor,
        puntuacion_min,
        id_owner,
    } = grup;
}

async fn get_user_groups(
    Path(id): Path<u64>,
    State(state): State<Arc<AppState>>,
) -> impl IntoResponse {
    let groups: Vec<Grupo> = sqlx::query_as(&format!(
        "SELECT * FROM grupos_usuarios JOIN grupo USING(id_grupo) WHERE id_usuario = {}",
        id
    ))
    .fetch_all(&mut state.db_pool.acquire().await.unwrap())
    .await
    .unwrap();

    (StatusCode::OK, serde_json::to_string(&groups).unwrap())
}

#[debug_handler]
async fn get_group_info(
    State(state): State<Arc<AppState>>,
    Path(id): Path<u64>,
) -> impl IntoResponse {
    let grupo: Vec<Grupo> =
        sqlx::query_as::<_, Grupo>(&format!("SELECT * FROM grupo WHERE id_grupo = {id}"))
            .fetch_all(&mut state.db_pool.acquire().await.unwrap())
            .await
            .unwrap();
    println!("{:?}", grupo);

    if grupo.is_empty() {
        (StatusCode::NO_CONTENT, "No se encontro el Id".to_owned())
    } else {
        (
            StatusCode::OK,
            serde_json::to_string(grupo.first().unwrap()).unwrap(),
        )
    }
}

struct AppState {
    db_pool: sqlx::postgres::PgPool,
}

#[tokio::main]
async fn main() {
    let state = Arc::new(AppState {
        db_pool: PgPoolOptions::new()
            .max_connections(5)
            .connect("postgres://postgres:aesr7AESR@database-1.ch4zzh5xjoph.us-east-1.rds.amazonaws.com/postgres")
            .await
            .unwrap(),
    });

    let address = std::env::var("BK_ADDRESS").unwrap_or("0.0.0.0".to_owned());
    let port = std::env::var("BK_PORT").unwrap_or("9090".to_owned());

    let router = Router::new()
        .route("/register", post(register_user))
        .route("/group/:id", get(get_group_info))
        .route("/groups_of/:id", get(get_user_groups))
        .route("/login", post(login))
        .with_state(state);

    Server::bind(&format!("{}:{}", address, port).parse().unwrap())
        .serve(router.into_make_service())
        .await
        .unwrap()
}
