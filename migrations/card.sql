BEGIN;

DEFINE TABLE card SCHEMAFULL
    PERMISSIONS 
        FOR select
            WHERE (collection.author.id = $auth.id OR collection.public = true)
        FOR delete
            WHERE in.id = $auth.id
        FOR create, update NONE
;

DEFINE FIELD collection ON card TYPE record(collection);

DEFINE FIELD front ON card TYPE string;
DEFINE FIELD back ON card TYPE string;

COMMIT;
