BEGIN;

DELETE collection;
-- collection:
--     id: record(collection)
--     public: bool
--     name: string

-- La información de las colecciones solo se puede ver si eres el dueño
-- o tienes la información como publica
DEFINE TABLE collection SCHEMAFULL
    PERMISSIONS
        FOR select
            WHERE ( 
                public = true 
                    OR count((
                        SELECT * FROM type::thing(id)
                            WHERE <-owns<-(user WHERE id = $auth.id)
                    )) = 1
            )
        FOR update, delete
            WHERE id = $auth.id
        FOR create FULL
;

DEFINE FIELD id ON collection PERMISSIONS 
    FOR create, update, delete NONE
    FOR select FULL
;

DEFINE FIELD public ON collection TYPE bool VALUE $value OR false;

DEFINE FIELD name ON collection TYPE string VALUE $value OR "";

DEFINE FIELD description ON collection TYPE string VALUE $value OR "No description";

-- Register owner when a collection gets created
DEFINE EVENT relate_autor_collection ON collection WHEN $event = "CREATE" THEN {
    LET $autor = $auth.id;
    LET $collection = $value.id;
    RELATE $autor->owns->$collection
        SET created_on = time::now()
};

COMMIT;
