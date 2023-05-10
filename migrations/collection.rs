BEGIN;

DELETE collection;

// La información de las colecciones solo se puede ver si eres el dueño
// o tienes la información como publica
DEFINE TABLE collection
    PERMISSIONS
        FOR select
            WHERE autor = $auth.id OR public = true
        FOR create, update, delete
            WHERE id = $auth.id
;

// Por defecto la coleccion es privada
DEFINE FIELD public ON TABLE collection
    VALUE $value OR false
;

COMMIT;
