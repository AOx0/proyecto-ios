BEGIN;

DEFINE TABLE tagged SCHEMAFULL
    PERMISSIONS 
        FOR select 
            WHERE (in.author = $auth.id OR in.public = true)
        FOR create, update, delete NONE
;

DEFINE FIELD in ON tagged TYPE record(collection);
DEFINE FIELD out ON tagged TYPE record(tag);

COMMIT;