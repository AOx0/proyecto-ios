BEGIN;

DELETE tag;

DEFINE TABLE tag SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR delete, update, create NONE
;

DEFINE FIELD name ON tag TYPE string;
DEFINE FIELD num_collections ON tag TYPE int VALUE $value OR 0;

COMMIT;