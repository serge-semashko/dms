gateway/post_doc.mod

[comments]
descr=S: Посылка документа в gateway
input=doc_id - ID документа (из таблицы d_list)
output=
parents=docs/view_doc
childs=
test_URL=?c=gateway/post_doc&doc_id=1
author=Куняев
[end]

[description]
<ol>
<li>Запросы в БД [getDocInfo] для получения данных объекта</li>
<li>Проверка: если gateway_object_id=0 (ObjectType в терминах шлюза), то объект не посылается в шлюз (через сброс DOC_DATA_RECORD_ID) </li>
<li>.....</li>
<li></li>
</ol>
[end]


[parameters]
request_name=S:Посылка документа
service=jinr.sed.gateway.ServicePostDoc
tableCfg=table_no
LOG=ON
SYS_FIELDS=DOC_ID, IS_ACTIVE, DATE_FORMAT(modified,'#dateTimeFormat#') as DOC_MODIFIED, VERSION
SYS_FIELDS_TYPES=int,int,varchar,int
encoding=utf-8 
[end]


[report header]
    $SET_PARAMETERS_GLOBAL GatewayHost=http://lt-a9.jinr.ru:8080/gateway/a ??
    $SET_PARAMETERS_GLOBAL GatewayHost=http://lt-a3.jinr.ru:8080/gateway/a ??
    $SET_PARAMETERS host=#GatewayHost#;
    $LOG <b>============== post_doc: doc_id=#doc_id#; host=#host#; USER_ID=#USER_ID#; ==================</b><br>
    $CALL_SERVICE c=sys/getARUD;  ??
    $SET_PARAMETERS AR_R=Y; 
    $SET_PARAMETERS silent=Y;
    $SET_PARAMETERS silent=;    ??mode=print
    $SET_PARAMETERS request=read;

    $GET_DATA [getDocInfo]
    $SET_PARAMETERS DOC_DATA_RECORD_ID=;  ??ObjectType=0|!ObjectType
    $INCLUDE docs/custom_settings[set custom object data] ??ObjectType>0&ZZZ-перенесено ниже
    <html><body><div style="padding:20px;"> ??!silent
[end]

[table header] ******* Выполняется после запроса из базы значений полей документа, перед формированием объекта.
    $LOG <br><b>+++++++++++++++++++++ [table header] +++++++++++++++++++++++</b><br>
    $INCLUDE docs/custom_settings[set custom object data] ??ObjectType>0

+++++ Не шлем уже посланный документ! ??
    <b>nr_ADB=#nr_ADB#; DOC_DATA_RECORD_ID=#DOC_DATA_RECORD_ID#;</b> <br> ??mode=print
    $SET_PARAMETERS DOC_DATA_RECORD_ID=;  ??nr_ADB>0&!force=Y
[end]

============== Вывод одного поля  ======= ??
[item]
<br>#NAME# (#FIELD_DB_NAME#): ??!silent
$INCLUDE #FIELD_SRC_FILE#[#FIELD_SECTION#] ??!silent
[end]

[report footer]
</div>  ??!silent
$INCLUDE [print request] ??mode=print
    $CALL_SERVICE c=sys/ar/set_doc_permits; 
<script>
alert('Документ послан в шлюз.\n\rОтвет: #ResultCode#: #Result#; ID: #DestObjectID#'); ??!silent&ResultCode=0&USER_ID=2309|USER_ID=413|USER_ID=4790|USER_ID=8329|USER_ID=9635
alert('Ошибка посылки документа в шлюз!\n\rКод ошибки: #ResultCode# #Result#'); ??!silent&!ResultCode=0&responce
alert('Ошибка посылки документа в шлюз!\n\rНе получен ответ из шлюза!'); ??!silent&!ResultCode=0&!responce
</script>
$LOG <b>Encoded Data:</b>#encodedData#<br> ??
</body></html>  ??!silent
[end]

[print request]
<hr>
<b>Request:</b><xmp>
$INCLUDE [post params]
<hr> ??
Object=#objectJSON#;</xmp>
<hr><b>Encoded Data:</b>#encodedData#<br> ??
<hr><b>==> #GatewayHost#:<br> Responce:</b><xmp>#responce#</xmp>
    <b>ДОКУМЕНТ НЕ ПОСЛАН! nr_ADB=#nr_ADB#;</b> DOC_DATA_RECORD_ID=#DOC_DATA_RECORD_ID#; add force=Y to send<br>   ??!DOC_DATA_RECORD_ID
[end]

Ver=1 

ClientID=3
ClientID=211

[post params]
ClientID=#GW_CLIENT_ID#
Command=PutObject
ObjectType=#ObjectType#
ClientObjectID=#doc_id#
Time=#MODIFIED# 
[end]

LINK=#ServerPath##ServletPath#?sid=#doc_id#&mode=ext

[object header]
DOC_TYPE=#DOC_TYPE#
LINK=#ServerPath##ServletPath#?c=docs/view_doc&doc_id=#doc_id#&mode=ext
DOC_TYPE_ID=#DOC_TYPE_ID#
DOC_TYPE_VERSION=#DOC_TYPE_VERSION#
DOC_NUMBER=#NUMBER#
DOC_DATE=#DOC_DATE#
TITLE=#TITLE#
INITIATOR_COMMENT=#INITIATOR_COMMENT#
CREATOR=#CREATOR#
MODIFIER=#MODIFIER#
CREATED=#CREATED#
MODIFIED=#MODIFIED#
$INCLUDE docs/custom_settings.cfg[custom object data] 
[end]

#JSON#
}

==============================================================================
***************************** Шаблоны SQL запросов ***************************
==============================================================================
[getDocInfo]
select 
  dtp.NAME as "DOC_TYPE", dtp.ID as "DOC_TYPE_ID"
 , dtp.gateway_object_id as "ObjectType"
 , dtp.number_type
 , concat('d_data_', cast(dtp.id as char)) as TABLE_NAME
 , dh.type_version as "DOC_TYPE_VERSION", dh.pid as PARENT_DOC_ID, dh.TITLE, dh.NUMBER
 , dh.comment as "INITIATOR_COMMENT"

 , u.FIO as CREATOR, u.email as "CRE_MAIL", u.phone as "CRE_PHONE" 
 , uu.FIO as MODIFIER
 , ifnull(DATE_FORMAT(dh.doc_date,'#dateFormat#'),'') as DOC_DATE
 , ifnull(DATE_FORMAT(dh.created,'#dateTimeSecFormat#'),'') as CREATED
 , ifnull(DATE_FORMAT(dh.modified,'#dateTimeSecFormat#'),'') as MODIFIED
, dg.has_wf as "HAS_WF"

from d_list dh 
left join d_types dtp on dtp.Id = dh.type_id
left join doc_groups dg on dg.Id = dtp.group_id
left join #table_users_full# u on u.Id = dh.creator_id
left join #table_users_full# uu on uu.Id = dh.modifier_id
where dh.Id = #doc_id#
; 

select /* LAST doc data record ID */ id as DOC_DATA_RECORD_ID 
from #TABLE_NAME# 
where doc_id = #doc_id# 
    and is_active=1 
 and version=#DOC_VERSION# ??DOC VERSIONS NOT IMPLEMENTED
order by modified desc
limit 0,1
;

select concat(dtf.field_db_name, ',') as FIELDS
 , concat(dtf.name, ',') as FIELDS_NAMES 
 , concat(dtf.type, ',') as FIELDS_TYPES
 , concat(dtf.form_field_type, ',') as FORM_FIELDS_TYPES
from d_fields dtf
where dtf.type_id = #DOC_TYPE_ID#
 ----- выбираем только активные поля + служебные ---- ??
    and (dtf.is_active=1 or dtf.field_category=1 or dtf.form_field_type=1)
    and dtf.min_doc_type_version <= #DOC_TYPE_VERSION#  
    and dtf.max_doc_type_version >= #DOC_TYPE_VERSION#  
    and dtf.field_category>1  ??request=write 
order by nr
;
[end]


[SQL]
select /* doc data fields description */
  dtf.NR, dtf.NAME, dtf.TYPE, dtf.SIZE, dtf.FORM_FIELD_TYPE, dtf.FIELD_DB_NAME, dtf.NULLS
, dtf.INFO_ID, dtf.info_view_nr as INFO_VIEW
, ifnull(dtf.lx, 400) as LX, ifnull(dtf.ly, 40) as LY, ROUND((ifnull(dtf.ly, 40) + 5)/15) as ROWS
, ft.src_file as "FIELD_SRC_FILE"
, ft.section_r  ??request=read
, ft.section_w  ??request=write 
  as "FIELD_SECTION"
from d_fields dtf
left join d_form_fields_types ft on (ft.id = dtf.form_field_type)
left join d_list dh on dtf.type_id = dh.type_id
where dh.Id = #doc_id# 
    and dtf.is_visible=1 
    and dtf.is_active=1
    and dtf.min_doc_type_version <= #DOC_TYPE_VERSION#  
    and dtf.max_doc_type_version >= #DOC_TYPE_VERSION#  
    and dtf.form_field_type not in(1004, 1006) ??
order by nr
[end]


