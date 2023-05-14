POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
[BasicAuth]
root: root
file,user.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
[BasicAuth]
root: root
file,collection.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
[BasicAuth]
root: root
file,owns.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
[BasicAuth]
root: root
file,sus.sql;
HTTP 200


POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
[BasicAuth]
root: root
file,scope.sql;
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
CREATE collection
	SET name= "Weird Words",
		public = true
;

CREATE collection
	SET name= "WWII"
;
```
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
