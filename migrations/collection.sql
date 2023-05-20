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
            WHERE public = true OR author = $auth.id
        FOR update
            WHERE author = $auth.id
        -- Solo se puede borrar por medio del campo erased
        FOR delete NONE
        FOR create FULL
;

DEFINE FIELD id ON collection PERMISSIONS 
    FOR create, update, delete NONE
    FOR select FULL
;

DEFINE FIELD is_sus ON collection 
    VALUE <future> { 
        RETURN (SELECT VALUE count(<-sus<-(user WHERE id = $auth.id)) = 1 FROM type::thing(id))[0];
    }
;

DEFINE FIELD author ON collection TYPE record(user);

DEFINE FIELD public ON collection TYPE bool VALUE $value OR false;

DEFINE FIELD name ON collection TYPE string VALUE $value OR "";

DEFINE FIELD description ON collection TYPE string VALUE $value OR "No description";

DEFINE FIELD num_sus ON collection TYPE int VALUE $value OR 0 
PERMISSIONS
    FOR create, update, delete NONE
;

DEFINE FIELD num_views ON collection TYPE int VALUE $value OR 0 
PERMISSIONS
    FOR create, update, delete NONE
;

-- Register owner when a collection gets created
DEFINE EVENT relate_autor_collection ON collection WHEN $event = "CREATE" THEN {
    LET $autor = $auth.id;
    LET $collection = $value.id;
    RELATE $autor->owns->$collection
        SET created_on = time::now();
    UPDATE type::thing($collection) SET author = $autor;
};

-- POSTMORTEM DE POSTMORTEM
-- Al borrar desde el evento si se borra en cascada porque en un ambiente de root si se tienen todos los permisos para borrar
-- POSTMOTEM
-- Evento que, cuando detecta que erased es true borra la coleccion y las relaciones de seguimiento
-- Borrar un elemento automaticamente borra todas las relaciones donde actua como out. 
--     Por eso no es necesario borrar a mano sus ni owns
DEFINE EVENT delete_collection_on_erased ON collection WHEN $event = "UPDATE" AND $after.erased = true THEN {
   DELETE type::thing($after.id);
};
-- Si este campo tiene valor true se borra la coleccion, la información de seguimiento
DEFINE FIELD erased ON collection TYPE bool VALUE $value OR false;


COMMIT;
