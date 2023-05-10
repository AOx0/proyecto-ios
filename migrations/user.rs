/// user:
///     first_name: string
///     last_name: string
///     email: string
///     pass: string
///     gravatar: string
///     gravatar_md5: string
///     collections: [record(collection)]
///     saved: [record(collection)]
///
BEGIN;

// Borrar la tabla si ya existe
DELETE user;

// Solo los usuarios pueden modificar su información, pero todos pueden ver.
//
// Por eso el select tiene FULL permissions y el resto de acciones solo se 
// pueden realizer si el id de la persona que lo quiere realizar es igual 
// al del usuario que se quiere modificar
DEFINE TABLE user
    PERMISSIONS
        FOR select
            FULL
        FOR create, update, delete
		        WHERE id = $auth.id
;

// El email solo es accessible para el dueño de la cuenta, privado para el
// resto de personas
DEFINE FIELD email ON TABLE user TYPE string
    PERMISSIONS
        FOR select, create, update, delete
		    WHERE id = $auth.id
    ASSERT 
        // El email no puede ser nulo
        $value != NONE
        // El email debe ser un string correctamente formateado
        AND is::email($value)
;

// La contrase√±a puede ser actualizada por el usuario pero no vista
DEFINE FIELD pass ON TABLE user
    PERMISSIONS
        FOR select
            NONE
        FOR create, update, delete
		        WHERE id = $auth.id
;

// El id no es modificable, el usuario no puede verlo ni actualizarlo
DEFINE FIELD id ON TABLE user 
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE
;


// Las otras personas solo pueden ver tus suscripciones si lo tienes
// marcado como publico
DEFINE FIELD suscriptions ON TABLE user
    PERMISSIONS
        FOR select
            WHERE id = $auth.id OR ps = true
        FOR create, update, delete
            WHERE id = $auth.id
;

// Por defecto las suscripciones son privadas
DEFINE FIELD ps ON TABLE user    
    VALUE $value OR false
;

// Todos pueden ver tu foto de perfil
DEFINE FIELD gravatar_md5 ON TABLE user    
    VALUE $value OR ""
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete
            WHERE id = $auth.id
;

// Solo tu puedes ver el email de gravatar
DEFINE FIELD gravatar ON TABLE user    
    VALUE $value OR ""
    PERMISSIONS
        FOR select, create, update, delete
            WHERE id = $auth.id
;


COMMIT;
