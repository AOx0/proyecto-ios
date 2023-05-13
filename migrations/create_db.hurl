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
file,scope.sql;
HTTP 200

POST http://localhost:8000/sql
Accept: application/json
NS: proyecto_ios
DB: proyecto
[BasicAuth]
root: root
file,owns.sql;
HTTP 200
