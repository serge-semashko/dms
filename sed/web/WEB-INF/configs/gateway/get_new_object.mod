gateway/get_new_object.mod

ТЕСТ шлюза. В РАБОТЕ НЕ ИСПОЛЬЗУЕТСЯ!
[comments]
descr=S: Запрос нового документа из gateway (для отладки)

input=
output=
parents=
childs=
test_URL=?c=gateway/get_new_object
author=Куняев
[end]


[parameters]
request_name=S:Запрос документа
service=jinr.sed.gateway.ServiceGetNewObject
tableCfg=table_no
LOG=ON
encoding=utf-8
[end]

[request]
Command=GetNewObject
Ver=1
ClientID=3
[end]
ObjectType=1 ??

ObjectType=[ID типа объекта] (если не задан – то любой тип объекта)
Time=[

[report]
REQUEST:<xmp>
$INCLUDE [request]
</xmp><br><br>
RESPONCE:<xmp>
#responce#</xmp>
<hr>
[end]


CALL_SERVICE c=gateway/register_object; ??GateObjectID>0

$CALL_SERVICE c=gateway/register_object;  ??GateObjectID>0

[end]

