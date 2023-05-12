BEGIN;

DELETE owns;

DEFINE TABLE owns SCHEMAFULL
    PERMISSIONS 
        FOR select 
            WHERE (in.id = $auth.id OR out.public = true)
        FOR create, update, delete NONE
;

DEFINE FIELD in ON owns TYPE record(user);
DEFINE FIELD out ON owns TYPE record(collection);

COMMIT;
