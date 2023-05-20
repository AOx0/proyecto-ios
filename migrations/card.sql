BEGIN;

DEFINE TABLE card SCHEMAFULL
    PERMISSIONS 
        FOR select
            WHERE (in.id = $auth.id OR in.public_sus = true)
        FOR delete
            WHERE in.id = $auth.id
        FOR create, update NONE
;



COMMIT;
