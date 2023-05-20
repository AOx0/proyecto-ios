BEGIN;

DELETE stack;

DEFINE TABLE stack SCHEMAFULL
    PERMISSIONS 
        FOR select 
            WHERE (in.author = $auth.id OR in.public = true)
        FOR create, update, delete NONE
;

DEFINE FIELD in ON stack TYPE record(collection);
DEFINE FIELD out ON stack TYPE record(card);

COMMIT;