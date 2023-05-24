
RETURN array::distinct(array::flatten((select value id from collection where name ?~ 'w')));


RETURN array::distinct(array::flatten((SELECT * FROM (SELECT VALUE id FROM tag WHERE type::string(id) ~ 'es')<-tagged<-collection)));


RETURN array::distinct(array::flatten((SELECT * FROM (SELECT VALUE id FROM user WHERE type::string(id) ~ 'da')->owns->collection)));