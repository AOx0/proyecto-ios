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

DEFINE FUNCTION fn::is_sus($user: record(collection)) {
    RETURN (SELECT VALUE count(<-sus<-(user WHERE id = $auth.id)) = 1 FROM $user)[0];
};

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

-- Endpoint para agregar cartas al stack
DEFINE FIELD add_card ON collection TYPE object VALUE $value OR NULL;
DEFINE FIELD add_card.front ON collection TYPE string;
DEFINE FIELD add_card.back ON collection TYPE string;

-- Endpoint para agregar tags
DEFINE FIELD add_tag ON collection TYPE string VALUE $value OR NULL;
DEFINE FIELD num_tags  ON collection TYPE int VALUE $value OR 0
PERMISSIONS 
    FOR create, update, delete NONE
;

-- Cuando se asigna a add_tag se crea la relacion con el tag si el numero de tags es menor a 5
DEFINE EVENT add_tag_to_collection ON collection WHEN (
    $event = "UPDATE" AND $after.add_tag != NULL AND $after.add_tag != $before.add_tag
) THEN {
    LET $from = id;
    LET $tag_name = string::replace(add_tag, " ", "");
    LET $to = (type::thing("tag", $tag_name));

    -- Si el nombre del tag es de mas de 25 caracteres o no es alfanumerico o si la coleccion ya tiene 5 tags no se hace nada
    IF num_tags > 5 OR is::alphanum($tag_name) = false OR string::len($tag_name) > 25 THEN {
        RETURN;
    }
    END;

    -- Checamos si la relacion ya existe
    LET $times_added = (SELECT VALUE id FROM $from->(tagged WHERE out = $to))[0];
    -- Checamos si el tag existe
    LET $tag = (SELECT VALUE id FROM $to)[0];

    -- En caso de que no exista la relacion se crea
    IF count($times_added) = 0 THEN {
        -- Si el tag no existe se crea
        IF ($tag = NONE) THEN {
            CREATE $to SET name = $tag_name;
        }
        END;

        -- Se crea la relacion, y aumenta el numero de tags de la coleccion y el numero de colecciones del tag
        RELATE $from->tagged->$to;
        UPDATE type::thing($from) SET num_tags += 1;
        UPDATE type::thing($to) SET num_collections += 1;
    }
    ELSE IF count($times_added) = 1 THEN {
        -- Se borra la relacion, y disminuye el numero de tags de la coleccion y el numero de colecciones del tag
        DELETE FROM ($from->tagged) WHERE out = $to;
        UPDATE type::thing($from) SET num_tags -= 1;
        UPDATE type::thing($to) SET num_collections -= 1;
    }
    END;

    -- Se resetea el campo add_tag
    UPDATE type::thing($from) SET add_tag = NULL;
};

-- Cuando se crea una carta se agrega al stack
-- Esperamos un objecto de la forma:
/*
{
    front: String,
    back: String,
}
*/
-- Usamos top y bottom para crear un nuevo registo en la tabla card
DEFINE EVENT add_card_to_stack ON collection WHEN $event = "UPDATE" AND $after.add_card != NULL THEN {
    IF add_card.front != NULL AND add_card.back != NULL THEN {
        LET $collection = id;
        LET $front = add_card.front;
        LET $back = add_card.back;

        LET $card = (CREATE card SET
            front = $front,
            back = $back,
            collection = $collection
        );
        RELATE $collection->stack->$card;
        UPDATE type::thing($collection) SET add_card = NULL;
    }
    END;
};

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
