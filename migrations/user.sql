--- user:
---     id: record(user)
---     first_name: string
---     last_name: string
---     email: string
---     pass: string
---     gravatar: string
---     gravatar_md5: string,
---     erased: bool
---
BEGIN;

DELETE user;

-- Solo los usuarios pueden modificar su información, pero todos pueden ver.
--
-- Por eso el select tiene FULL permissions y el resto de acciones solo se 
-- pueden realizer si el id de la persona que lo quiere realizar es igual 
-- al del usuario que se quiere modificar
DEFINE TABLE user SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update WHERE id = $auth.id
        FOR delete NONE
;

DEFINE FIELD id ON user PERMISSIONS 
    FOR create, update, delete NONE
    FOR select FULL
;

-- Define first_name and last_name
DEFINE FIELD first_name ON TABLE user TYPE string;
DEFINE FIELD last_name ON TABLE user TYPE string;

-- 1. Solo es accessible para el dueño de la cuenta
-- 2. El email no puede ser nulo y debe ser valido
DEFINE FIELD email ON TABLE user TYPE string
    PERMISSIONS
        FOR select WHERE id = $auth.id
    ASSERT 
        $value != NONE AND is::email($value)
;

-- Solo tu puedes ver el email de gravatar
DEFINE FIELD gravatar ON TABLE user
    VALUE $value OR "No gravatar"
    PERMISSIONS
        FOR select WHERE id = $auth.id
;

-- Todos pueden ver tu foto de perfil
DEFINE FIELD gravatar_md5 ON TABLE user
    VALUE $value OR ""
    PERMISSIONS
        FOR select FULL
;

-- La contraseña puede ser actualizada por el usuario pero no vista
DEFINE FIELD pass ON TABLE user PERMISSIONS FOR select NONE;

-- Por defecto las suscripciones son privadas
DEFINE FIELD public_sus ON user TYPE bool VALUE $value OR false;

-- Si este campo tiene valor true se borra el usuario y todo lo que creó.
DEFINE FIELD erased ON user TYPE bool VALUE $value OR false;

-- Endpoint para crear suscripciones del usuario
DEFINE FIELD suscribe_to ON user TYPE record(collection) VALUE $value OR NULL;

DEFINE EVENT suscribe_user_to_collection ON user WHEN $event = "UPDATE" AND $after.suscribe_to != NULL THEN {
    LET $from = id;
    LET $to = suscribe_to;
    LET $times_suscribed_to_target = RETURN SELECT VALUE count(->(sus WHERE out = $to)) FROM type::thing(id);
    LET $times_as_owner = RETURN SELECT VALUE count(->(owns WHERE out = $to)) FROM type::thing(id);
    
    IF ($from = $auth.id AND $times_suscribed_to_target[0] = 0 AND $times_as_owner[0] = 0) THEN
        RELATE $from->sus->$to UNIQUE
            SET sub_since = time::now()
    END;

    UPDATE type::thing(id) SET suscribe_to = NULL;
};

-- Evento que, cuando detecta que erased es true borra todos los articulos y al usuario.
DEFINE EVENT delete_user_collections ON user WHEN $event = "UPDATE" AND $after.erased = true THEN {
    DELETE collection WHERE <-owns<-(user WHERE id = type::thing($before.id));
    DELETE type::thing($after.id);
};

COMMIT;
