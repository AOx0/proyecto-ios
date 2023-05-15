BEGIN;

DELETE follow;

DEFINE TABLE follow SCHEMAFULL
    PERMISSIONS 
        FOR select
            WHERE (in.id = $auth.id OR in.public_sus = true)
        FOR delete
            WHERE in.id = $auth.id
        FOR create, update NONE
;

DEFINE FIELD in ON follow TYPE record(user);
DEFINE FIELD out ON follow TYPE record(user);
DEFINE FIELD follow_since ON follow
    PERMISSIONS
        FOR select
            WHERE in.id = $auth.id
;

COMMIT;
