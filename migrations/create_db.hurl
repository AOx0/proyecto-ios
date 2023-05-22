POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,user.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,collection.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,owns.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,sus.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,scope.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,follow.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,view.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,card.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,stack.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,tag.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
file,tagged.sql;
HTTP 200


##########################
# Actions as user:david
##########################

POST http://localhost:8000/signin
Accept: application/json
{
	"NS": "proyecto_ios",
	"DB": "proyecto",
	"SC": "account_short",
	"email": "david@gmail.com",
	"pass": "1234"
}
HTTP 200
[Captures]
auth_dav: jsonpath "$['token']"

POST http://localhost:8000/sql
Authorization: Bearer {{auth_dav}}
Accept: application/json
NS: proyecto_ios
DB: proyecto
```
CREATE collection
	SET name= "Español I",
		public = true
;

CREATE collection
	SET name= "Español II",
		public = true
;
```
HTTP 200


##########################
# Actions as user:daniel
##########################

POST http://localhost:8000/signin
Accept: application/json
{
	"NS": "proyecto_ios",
	"DB": "proyecto",
	"SC": "account_short",
	"email": "daniel@gmail.com",
	"pass": "1234"
}
HTTP 200
[Captures]
auth_dan: jsonpath "$['token']"

POST http://localhost:8000/sql
Authorization: Bearer {{auth_dan}}
Accept: application/json
NS: proyecto_ios
DB: proyecto
```
CREATE collection:col1
	SET name= "Weird Words",
		public = true
;

UPDATE collection:col1 SET add_card = {
	front: "ethos",
	back: "espiritu"
};

UPDATE collection:col1 SET add_card = {
	front: "pathos",
	back: "sentimiento"
};

UPDATE collection:col1 SET add_card = {
	front: "logos",
	back: "razon"
};

UPDATE collection:col1 SET add_card = {
	front: "kairos",
	back: "tiempo"
};

UPDATE collection:col1 SET add_card = {
	front: "nomos",
	back: "ley"
};

UPDATE collection:col1 SET add_card = {
	front: "physis",
	back: "naturaleza"
};

UPDATE collection:col1 SET add_card = {
	front: "telos",
	back: "fin o meta"
};

UPDATE collection:col1 SET add_card = {
	front: "aletheia",
	back: "verdad"
};

UPDATE collection:col1 SET add_card = {
	front: "doxa",
	back: "opinion"
};

UPDATE collection:col1 SET add_card = {
	front: "episteme",
	back: "conocimiento"
};

CREATE collection
	SET name= "WWII"
;
```
HTTP 200
