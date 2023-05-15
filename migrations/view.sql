BEGIN;

DELETE view;

DEFINE TABLE view SCHEMAFULL
    PERMISSIONS 
        FOR select
            WHERE (in.id = $auth.id OR in.public_views = true)
        FOR delete, create, update NONE
;

DEFINE FIELD in ON view TYPE record(user);
DEFINE FIELD out ON view TYPE record(collection);

COMMIT; 
