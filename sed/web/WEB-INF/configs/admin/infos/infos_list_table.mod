[comments]
descr=А: Вывод списка справочников (вывод самой таблицы). 
Вызывается из admin/infos/tab_infos

input=
output=HTML таблица справочников
parents=
childs=
testURL=?c=admin/infos/infos_list_table
[end]

</div>

[parameters]
service=dubna.walt.service.TableServiceSpecial
request_name=A:Таблица справочников
tableCfg=table_no
KeepLog=false
$INCLUDE dat/common.dat[rowLinks]
[end]


[report header]
+++++++ временно - открыто всем. Потом - проверить R и RW права пользователя +++ ??
$SET_PARAMETERS RWACC=Y; RACC=Y;
$INCLUDE [OK report header]  ??RACC
[end]


[OK report header]
+++++++ сортировка таблицы по умолчанию ++++ ??
$SET_PARAMETERS srt=i.id; desc=; ??!srt
+++++++ начальная строка и кол-во строк на странице по умолчанию ++++ ??
$SET_PARAMETERS srn=1; rpp=9999;

<div id="result_table">
<small>#c#</small> ??debug=on
<center>
<input type=hidden name="srn" value="#srn#"> 
<input type=hidden name="srt" value="#srt#">
<input type=hidden name="desc" value="#desc#">

++++++++++++++++++ Шапка таблицы  +++++++++++++++++++++ ??
<table class=tlist cellspacing=0>
<tr>
<th class="srh" sr="i.id">id</th>
<th class="srh" sr="i.name">Название справочника</th>
<th class="srh" sr="u.LOGIN">Тип</th>
<th class="srh" sr="u.DIV_CODE">Структура</th>
<th>Активный</th>
<th class="srh" sr="u.modified">Обновлен</th>
</tr>
[end]


[item]
++++++++++++++++++ Строка таблицы - 1 справочник +++++++++++++++++++++ ??
<tr class="pt
oddRow ??oddRow=1
" onClick="AjaxCall('content_table','c=admin/infos/info_item&info_id=#ID#')">
<td class=small>#ID#</td>
<td>#INFO_NAME#</td>
<td>
внешний, ??IS_EXTERNAL=1
внутренний ??IS_EXTERNAL=0
$INCLUDE [ext_data_desc]
</td>
<td>
иерархический ??IS_TREE=1
плоский	 ??IS_TREE=0
</td>
<td>
да ??IS_ACTIVE=1
удаленный ??IS_ACTIVE=0
</td> 

<td>
$CALL_SERVICE c=admin/users/user_roles ??
</td>
<td class=small><small>#MODIFIER#, #MODIFIED#</small></td> 
</tr>
[end]

[ext_data_desc]
БД ??SRC_TYPE=0
Oracle, ??DB_TYPE=1
#CONN_NAME#
&nbsp;
[end]

[report footer]
</table>
<input type="button" class="butt1" style="width:220;" value="Добавить справочник" onclick="AjaxCall('content_table','c=admin/infos/info_item&cop=new')">  ??RWACC
</div>

+++++++++ Скрипт возврата результатов в вызывавшую страницу ++++ ??
<script>
window.parent.getResult("content_table", document.getElementById("result_table"));
window.parent.setModule("admin/infos/infos_list_table");
window.parent.oldCmd="";
--------- Отображение сортировки в заголовке таблицы ----- ??
window.parent.showSrt("#srt#","sup"); ??!desc
window.parent.showSrt("#srt#","sdown"); ??desc
</script>
[end]


***************************** Шаблон SQL запроса ***************************
[SQL]
select i.ID
, i.name as INFO_NAME, i.IS_EXTERNAL
, ed.SRC_TYPE, ec.DB_TYPE, ec.CONN_NAME
, i.IS_TREE, i.IS_ACTIVE
, i.table_name
, data_updated 
from i_infos i
left join i_external_data ed on ed.info_id=i.id
left join i_ext_connections ec on ec.id=ed.conn_id
where  ??
order by #srt# #desc# 
[end]
