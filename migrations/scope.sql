BEGIN;

-- Define /signup and /signin endpoints
DEFINE SCOPE account SESSION 24h
    SIGNUP (
        CREATE type::thing("user", string::trim($user))
        SET
            email = $email,
            pass = crypto::argon2::generate($pass),
            first_name="",
            last_name=""
    )
    SIGNIN (
        SELECT * FROM user
            WHERE email = $email
                AND crypto::argon2::compare(pass, $pass)
    )
;

-- Creamos algunos usuarios de prueba
CREATE user:daniel
    SET
        email = "daniel@gmail.com",
        pass = crypto::argon2::generate("1234"),
        gravatar = "danielosorniolopez@gmail.com",
        gravatar_md5 = crypto::md5("danielosorniolopez@gmail.com"),
        first_name="Daniel",
        last_name="Osornio"
;

CREATE user:david
    SET
        email = "david@gmail.com",
        pass = crypto::argon2::generate("1234"),
        public_sus = true,
        first_name="Hector",
        last_name="Espinoza"
;

CREATE user:agus
    SET
        email = "agus@gmail.com",
        pass = crypto::argon2::generate("1234"),
        first_name="Agus",
        last_name="Lopez"
;

COMMIT;
