use axum::{
    debug_handler,
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Json, Router, Server,
};

use serde::{Deserialize, Serialize};
use surrealdb::{
    engine::remote::ws::{Client, Ws},
    *,
};

static DB: Surreal<Client> = Surreal::init();

#[derive(Debug, Serialize, Deserialize)]
struct User {
    name: String,
    age: usize,
}

async fn register_user(Json(user): Json<User>) -> impl IntoResponse {
    (StatusCode::OK, ())
}

#[tokio::main]
async fn main() {
    let address = std::env::var("BK_ADDRESS").unwrap_or("0.0.0.0".to_owned());
    let port = std::env::var("BK_PORT").unwrap_or("9090".to_owned());

    let router = Router::new();

    Server::bind(&format!("{}:{}", address, port).parse().unwrap())
        .serve(router.into_make_service())
        .await
        .unwrap()
}
