[comments]
descr=А: Редактирование структуры справочника

input=info_id - ID выбранного справочника
output=HTML форма редактирования структуры справочника, 
parents=admin/infos/infos_list_table.cfg
childs=admin/users/user_set_roles
test_URL=?c=admin/infos/info_edit&info_id=1
[end]

[parameters]
request_name=A:редактир. справочника
KeepLog=false
[end]


[report]
$SET_PARAMETERS RWACC=Y; RACC=Y; ??AR_ADMIN=1
$INCLUDE [report_]  ??RACC
[end]


[report_]
<html><body>
$INCLUDE [process] ??cop&RWACC=Y
$GET_DATA [getInfoSQL] ??!cop=new

$LOG === module: admin/infos/info_edit
<div id="result">
#c# ??debug=on
<center>
$INCLUDE [form] 	
$INCLUDE [pasteBackScript] 
</body></html>
[end]


активный ??IS_ACTIVE=1
удаленный ??IS_ACTIVE=0


[form]
<table border=1 cellpadding=5 style="background-color:white; width_:100%; border:none 1px gray;">

<tr><td class=label>ID:</td><td><input class="xp" size=5 name=new_id value="#new_id#"></td></tr> ??cop=new

<tr><td class=label>Название справочника:</td><td><input class="xp" size=45 name=INFO_NAME value="#INFO_NAME#">
<input type=checkbox class="xp" name=ext  
onClick="doSubmit('set_ext','#c#');" ??!cop=new
checked ??IS_EXTERNAL=1
> внешний</td></tr>

$SET_PARAMETERS NEW_TABLE=info_#new_id#; ??cop=new&!NEW_TABLE
<tr><td class=label>Имя таблицы:</td><td><input class="xp" size=15 name=NEW_TABLE value="#NEW_TABLE#"></td></tr> ??cop=new

<tr><td class=label>Структура:</td><td>
<input type=radio name=tree value=1 
onClick="doSubmit('set_tree','#c#');" ??!cop=new
checked ??IS_TREE=1
> иерархический (дерево)
<input type=radio name=tree value=0 
onClick="doSubmit('set_tree','#c#');" ??!cop=new
checked ??!IS_TREE=1
> плоский
</td></tr>

<tr><td class=label>
Поля:  ??!cop=new
</td><td>
$CALL_SERVICE c=admin/infos/info_edit_fields; ??!cop=new
<input type="button" class="butt1 pt" style="width:160; margin:10px 0 10px 250px;" value='Создать справочник' onClick="doSubmit('create','#c#');">  ??cop=new
</td></tr>

<tr><td colspan=4 class="bottom_dotted"></td></tr>

$INCLUDE [ExtSrc] ??IS_EXTERNAL=1
$CALL_SERVICE c=admin/infos/info_editExternal ??IS_EXTERNAL=1

<tr><td class=label>Изменено:</td><td class=small>#MODIFIED#, #MODIFIER#</td></tr> ??

</table>
</center>
</div>
[end]


[ExtSrc]
<tr><td class=label>Источник:</td><td>
<input type=radio name=src_type value=0
checked ??SRC_TYPE=0
> База данных
<input type=radio name=src_type value=1 disabled
checked ??SRC_TYPE=1
> XML данные
<input type=radio name=src_type value=2 disabled
checked ??SRC_TYPE=2
> JSON данные
</td></tr>
[end]


[pasteBackScript]
<script type="text/javascript">
window.parent.getResult("dt_infoItem", document.getElementById("result"));
</script>
[end]


[getInfoSQL]
select i.ID
, i.name as INFO_NAME, i.IS_EXTERNAL
, ed.SRC_TYPE, ed.CONN_ID, ed.REQUEST
, ec.DB_TYPE, ec.CONN_NAME, ec.DB as DB_SCHEMA
, i.IS_TREE, i.IS_ACTIVE
, ec.SERVER, ec.PORT, ec.PARAM, ec.USR as CONN_USR, ec.PW as CONN_PW
, i.TABLE_NAME
, data_updated 
from i_infos i
left join i_external_data ed on ed.info_id=i.id
left join i_ext_connections ec on ec.id=ed.conn_id
where i.Id=#info_id#
;
try: select count(*) as NUM_RECORDS from #TABLE_NAME#
;
[end]

[getNextId]
select max(id)+1 as new_id from i_infos where id<1000
[end]

================== Занесение данных в базу  ====================
[process]
$LOG =========== Request processing =============<br>
$GET_DATA [getNextId]  ??cop=new
$GET_DATA [create info] ??cop=create&new_id&info_name&new_table
$SET_PARAMETERS cop=new; ??cop=create&!info_id

$GET_DATA [setTreeSQL]  ??cop=set_tree
$GET_DATA [setExtSQL] 	??cop=set_ext

#ERROR#

<script type="text/javascript">alert("#ERROR#"); </script>   ??ERROR
[end]

[create info]

try: insert into i_infos(id,name,is_external,is_tree, table_name)
values(#new_id#,'#INFO_NAME#'
, 0 ??!ext
, 1 ??ext
,#tree#, '#NEW_TABLE#')
;
select id as info_id from i_infos where id=#new_id#;
[end]


[setTreeSQL]
update i_infos set is_tree=#tree# where id=#info_id#;
[end]

[setExtSQL]
update i_infos set is_external
=1 ??ext
=0 ??!ext
where id=#info_id#
[end]



[updateInfoSQLs]
[end]
