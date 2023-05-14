
BEGIN;

DELETE sus;

DEFINE TABLE sus SCHEMAFULL
    PERMISSIONS 
        FOR select
            WHERE (in.id = $auth.id OR in.public_sus = true)
        FOR delete
            WHERE in.id = $auth.id
        FOR create, update NONE
;

DEFINE FIELD in ON sus TYPE record(user);
DEFINE FIELD out ON sus TYPE record(collection);
DEFINE FIELD sub_since ON sus
    PERMISSIONS
        FOR select
            WHERE in.id = $auth.id
;

COMMIT;
