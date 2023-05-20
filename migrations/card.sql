BEGIN;

DELETE card;

DEFINE TABLE card SCHEMAFULL
    PERMISSIONS 
        FOR select
            WHERE (collection.author.id = $auth.id OR collection.public = true)
        FOR delete, update
            WHERE collection.author.id = $auth.id
        FOR create NONE
;

DEFINE FIELD collection ON card TYPE record(collection)
    PERMISSIONS
        FOR update, delete, create NONE
;

DEFINE FIELD front ON card TYPE string;
DEFINE FIELD back ON card TYPE string;

COMMIT;
