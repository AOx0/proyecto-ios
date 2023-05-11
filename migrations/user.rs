/// user:
///     id: record(user)
///     first_name: string
///     last_name: string
///     email: string
///     pass: string
///     gravatar: string
///     gravatar_md5: string
///
BEGIN;

DELETE user;

// Solo los usuarios pueden modificar su información, pero todos pueden ver.
//
// Por eso el select tiene FULL permissions y el resto de acciones solo se 
// pueden realizer si el id de la persona que lo quiere realizar es igual 
// al del usuario que se quiere modificar
DEFINE TABLE user SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete WHERE id = $auth.id
;

// El id no es modificable, el usuario no puede verlo ni actualizarlo
DEFINE FIELD id ON TABLE user PERMISSIONS 
    FOR select, create, update, delete NONE
;

// Define first_name and last_name
DEFINE FIELD first_name ON TABLE user TYPE string;
DEFINE FIELD last_name ON TABLE user TYPE string;

// 1. Solo es accessible para el dueño de la cuenta
// 2. El email no puede ser nulo y debe ser valido
DEFINE FIELD email ON TABLE user TYPE string
    PERMISSIONS
        FOR select WHERE id = $auth.id
    ASSERT 
        $value != NONE AND is::email($value)
;

// Solo tu puedes ver el email de gravatar
DEFINE FIELD gravatar ON TABLE user
    VALUE $value OR ""
    PERMISSIONS
        FOR select WHERE id = $auth.id
;

// Todos pueden ver tu foto de perfil
DEFINE FIELD gravatar_md5 ON TABLE user
    VALUE $value OR ""
    PERMISSIONS
        FOR select FULL
;

// La contraseña puede ser actualizada por el usuario pero no vista
DEFINE FIELD pass ON TABLE user PERMISSIONS FOR select NONE;

// Por defecto las suscripciones son privadas
DEFINE FIELD public_sus ON TABLE user VALUE $value OR false;

COMMIT;
