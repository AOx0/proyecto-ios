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
    automovil: i64,
    puntuacion_min: i64,
    id_grupo: i64,
    id_usuarios: Option<i32>,
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
    // licencia: Option<String>,
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
        // licencia,
    } = new_user;
    sqlx::query(&format!("INSERT INTO usuario(nombre, apellido, fecha_nacimiento, correo, telefono) VALUES ('{nombre}', '{apellido}', '{fecha_nacimiento}', '{correo}', '{telefono}')")).execute(&mut state.db_pool.acquire().await.unwrap()).await.unwrap();

    (StatusCode::CREATED, ())
}

#[debug_handler]
async fn get_group_info(State(state): State<Arc<AppState>>, Path(id): Path<u64>) -> Html<String> {
    let grupo: Vec<Grupo> =
        sqlx::query_as::<_, Grupo>(&format!("SELECT * FROM grupo WHERE id_grupo = {id}"))
            .fetch_all(&mut state.db_pool.acquire().await.unwrap())
            .await
            .unwrap();

    Html(
        grupo
            .first()
            .map(|first| serde_json::to_string(first).unwrap())
            .unwrap_or(String::new()),
    )
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
        .with_state(state);

    Server::bind(&format!("{}:{}", address, port).parse().unwrap())
        .serve(router.into_make_service())
        .await
        .unwrap()
}
