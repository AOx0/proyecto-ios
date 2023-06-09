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


DEFINE FUNCTION fn::is_following($user: record(user)) {
    RETURN (SELECT VALUE count(out) FROM ($auth.id->follow) WHERE out=$user)[0] = 1;
};

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
DEFINE FIELD suscribe_to ON user TYPE record(collection) VALUE $value OR NULL
    PERMISSIONS
        FOR select NONE
;

-- Endpoint para segur usuarios
DEFINE FIELD follow_user ON user TYPE record(user) VALUE $value OR NULL
    PERMISSIONS
        FOR select NONE
;

-- Ednpoint para registrar visitas a colecciones
DEFINE FIELD view_collection ON user TYPE record(collection) VALUE $value OR NULL
    PERMISSIONS
        FOR select NONE
;

-- Numero de usuarios que siguen a este usuario
DEFINE FIELD num_followers ON user TYPE int VALUE $value OR 0
    PERMISSIONS
        FOR select FULL
;

-- Numero de usuarios a los que sigue este usuario
DEFINE FIELD num_following ON user TYPE int VALUE $value OR 0
    PERMISSIONS
        FOR select FULL
;

DEFINE EVENT register_view ON user WHEN $event = "UPDATE" AND $after.view_collection != NULL THEN {
    LET $from = id;
    LET $to = view_collection;
    LET $times_as_owner = RETURN SELECT VALUE count(->(owns WHERE out = $to)) FROM type::thing(id);
    
    IF ($from = $auth.id AND $times_as_owner[0] = 0) THEN {
        UPDATE type::thing($to) SET num_views += 1;
        RELATE $from->view->$to
            SET id = [time::now(), $to];
    }
    END;

    UPDATE type::thing(id) SET view_collection = NULL;
};

DEFINE EVENT suscribe_user_to_collection ON user WHEN $event = "UPDATE" AND $after.suscribe_to != NULL THEN {
    LET $from = id;
    LET $to = suscribe_to;
    LET $times_suscribed_to_target = RETURN SELECT VALUE count(->(sus WHERE out = $to)) FROM type::thing(id);
    LET $times_as_owner = RETURN SELECT VALUE count(->(owns WHERE out = $to)) FROM type::thing(id);
    
    IF ($from = $auth.id AND $times_suscribed_to_target[0] = 0 AND $times_as_owner[0] = 0) THEN {
        UPDATE type::thing($to) SET num_sus += 1;
        RELATE $from->sus->$to UNIQUE
            SET sub_since = time::now(),
                id = [time::round(time::now(), 2h), $to, $from];
    }
    ELSE IF ($from = $auth.id AND $times_suscribed_to_target[0] != 0 AND $times_as_owner[0] = 0) THEN {
        UPDATE type::thing($to) SET num_sus -= 1;
        DELETE FROM ($from->sus) WHERE out= $to;
    }
    END;

    UPDATE type::thing(id) SET suscribe_to = NULL;
};

DEFINE EVENT create_user_follow ON user WHEN $event = "UPDATE" AND $after.follow_user != $before.follow_user AND $after.follow_user != NULL THEN {
    LET $from = id;
    LET $to = follow_user;
    LET $already_follow_relations = RETURN SELECT VALUE count(->(follow WHERE out = $to)) FROM type::thing(id);
    
    -- El trigger hace un toggle, es decir que si el usuario ya seguia a una persona hace que
    -- la deje de seguir y viceversa
    IF ($from = $auth.id AND $to != $from AND $already_follow_relations[0] = 1) THEN {
        UPDATE type::thing($to) SET num_followers -= 1;
        UPDATE type::thing($from) SET num_following -= 1;
        DELETE FROM ($from->follow) WHERE out=$to;
    }
    ELSE IF ($from = $auth.id AND $to != $from AND $already_follow_relations[0] = 0) THEN {
        UPDATE type::thing($to) SET num_followers += 1;
        UPDATE type::thing($from) SET num_following += 1;
        RELATE $from->follow->$to UNIQUE SET follow_since = time::now();
    }
    END;

    UPDATE type::thing(id) SET follow_user = NULL;
};

-- Evento que, cuando detecta que erased es true borra todos los articulos y al usuario.
DEFINE EVENT delete_user_collections ON user WHEN $event = "UPDATE" AND $after.erased = true THEN {
    -- Las relaciones se borran solas, pero datos de tablas en si no. Hay que borrar las colecciones del usuario
    -- a mano. No es necesario borrar las publicaciones con evento porque ya se esta corriendo en contexto de admin
    DELETE collection WHERE <-owns<-(user WHERE id = type::thing($before.id));
    DELETE type::thing($after.id);
};

COMMIT;
