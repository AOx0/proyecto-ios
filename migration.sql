BEGIN TRANSACTION;

-- Delete all existing data
DELETE collection;
DELETE user;

-- Solo los usuarios pueden modificar su informaci√≥n, pero todos pueden ver.
--
-- Por eso el select tiene FULL permissions y el resto de acciones solo se 
-- pueden realizer si el id de la persona que lo quiere realizar es igual 
-- al del usuario que se quiere modificar
DEFINE TABLE user 
    PERMISSIONS
        FOR select
            FULL
        FOR create, update, delete
		        WHERE id = $auth.id
;

-- El email solo es accessible para el due√±o de la cuenta, privado para el
-- resto de personas
DEFINE FIELD email ON TABLE user TYPE string
    PERMISSIONS
        FOR select, create, update, delete
		        WHERE id = $auth.id
    ASSERT 
        -- El email no puede ser nulo
        $value != NONE
        -- El email debe ser un string correctamente formateado
        AND is::email($value)
;

-- La contrase√±a puede ser actualizada por el usuario pero no vista
DEFINE FIELD pass ON TABLE user
    PERMISSIONS
        FOR select
            NONE
        FOR create, update, delete
		        WHERE id = $auth.id
;

-- El id no es modificable, el usuario no puede verlo ni actualizarlo
DEFINE FIELD id ON TABLE user 
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE
;


-- Las otras personas solo pueden ver tus suscripciones si lo tienes
-- marcado como publico
DEFINE FIELD suscriptions ON TABLE user
    PERMISSIONS
        FOR select
            WHERE id = $auth.id OR ps = true
        FOR create, update, delete
            WHERE id = $auth.id
;

-- Por defecto las suscripciones son privadas
DEFINE FIELD ps ON TABLE user    
    VALUE $value OR false
;

-- Todos pueden ver tu foto de perfil
DEFINE FIELD gravatar_md5 ON TABLE user    
    VALUE $value OR ""
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete
            WHERE id = $auth.id
;

-- Solo tu puedes ver el email de gravatar
DEFINE FIELD gravatar ON TABLE user    
    VALUE $value OR ""
    PERMISSIONS
        FOR select, create, update, delete
            WHERE id = $auth.id
;

-- La informaci√≥n de las colecciones solo se puede ver si eres el due√±o
-- o tienes la informaci√≥n como publica
DEFINE TABLE collection
    PERMISSIONS
        FOR select
            WHERE autor = $auth.id OR public = true
        FOR create, update, delete
            WHERE id = $auth.id
;

-- Por defecto la coleccion es privada
DEFINE FIELD public ON TABLE collection
    VALUE $value OR false
;

-- Define /signup and /signin endpoints
DEFINE SCOPE account SESSION 24h
    SIGNUP ( 
        CREATE type::thing("user", string::trim($user))
        SET 
    		email = $email,
            pass = crypto::argon2::generate($pass),
            collections = [],
            first_name="",
            last_name=""
	)
	SIGNIN ( 
        SELECT * FROM user 
            WHERE email = $email 
                AND crypto::argon2::compare(pass, $pass)
    )
;

-- Create a bunch of testing users
CREATE user:daniel
    SET
		email = "daniel@gmail.com",
        pass = crypto::argon2::generate("1234"),
        gravatar = "danielosorniolopez@gmail.com",
        gravatar_md5 = crypto::md5("danielosorniolopez@gmail.com"),
        collections = [collection:col1],
        suscriptions = [],
        first_name="Daniel",
        last_name="Osornio"
;

CREATE collection:col1
    SET
        name = "My Collection",
        autor = user:daniel,
        cards = [],
        public = true
;

CREATE user:david
    SET
		email = "david@gmail.com",
        pass = crypto::argon2::generate("1234"),
        collections = [],
        suscriptions = [collection:col1],
        ps = true,
        first_name="David",
        last_name="Osornio"
;

CREATE user:agus
    SET
		email = "agus@gmail.com",
        pass = crypto::argon2::generate("1234"),
        collections = [],
        suscriptions = [collection:col1],
        first_name="Agus",
        last_name="Osornio"
;

COMMIT TRANSACTION;

