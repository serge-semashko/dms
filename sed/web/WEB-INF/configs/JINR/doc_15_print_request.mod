JINR/doc_15_print_request.mod


[parameters]
request_name=U:Печать заявки на пропуск
service=jinr.sed.ServiceViewDoc
tableCfg=table_no
LOG=ON
t_start=<table class="item"><tr><td class="label">
t_mid=</td><td class="cont">
t_lab=</td><td class="label">
t_end=</td></tr></table>
SYS_FIELDS=DOC_ID
SYS_FIELDS_TYPES=int
[end]

.s3 {font-size:13pt;}
.s2 {font-size:10pt;}
.s1 {font-size:9pt;}
.s0, table.item td.s0 {font-size:8pt;}
.s-1 {font-size:7pt;}

[report header]
    $INCLUDE dat/common.dat[check login]
    $LOG1 <b>============== print_doc: doc_id=#doc_id#; USER_ID=#USER_ID#; ==================</b><br>
    $CALL_SERVICE c=sys/getARUD; ??USER_ID

    $SET_PARAMETERS DOC_DATA_RECORD_ID=;
    $GET_DATA docs/view_doc.cfg[getDocInfo]    ??AR_R=Y
    $INCLUDE docs/custom_settings.cfg[set custom parameters]

$SET_PARAMETERS s3=21px; s2=19px; s1=17px; s0=15px; s-1=12px; solid=dotted;
<!DOCTYPE html><html><head><TITLE>Заявка на пропуск</TITLE>
<META http-equiv=Content-Type content="text/html; charset=utf-8">

<style>
body {border:dotted 1px ##a0a0a0; font-family:Times; font-size:#s0#; width:510pt; margin:0 10pt 0 30pt; padding:3px;} ??
body {border:none 1px ##a0a0a0; font-family:Times; font-size:#s0#; width:640pt; margin:0 20pt 0 50pt; padding:3px;}

.s3 {font-size:#s3#;}
.s2 {font-size:#s2#;}
.s1 {font-size:#s1#;}
.s0, table.item td.s0 {font-size:#s0#;}
.s-1 {font-size:#s-1#;}

.b {font-weight:bold;}
.c {text-align:center;}
.r {text-align:right;}

.fl {float:left;}
.fr {float:right;}
.clr {clear:both;}

table.item {width:100%;}
td {font-size:#s0#; vertical-align:top;} 
td.label {width:1%; white-space:nowrap;}
td.cont {text-align:center; border-bottom:#solid# 1px black; font-size:#s1#;}

table.list td, table.list th {font-size:#s1#;}
table.list th {border:solid 1px black; border-left:none; font-weight:normal;}
table.list td {border-right:#solid# 1px black; border-bottom:#solid# 1px black;}
table.list td.l, table.list th.l {border-left:solid 1px black;}
</style>
</head>

<body>
<div class="s-1" style="text-align:right; margin:20px 10px 20px;">
Приложение №1<br>к порядку оформления документов при приеме лиц, приглашенных (направленных) в ОИЯИ<br> ??
и не состоящих в трудовых отношениях с Институтом ??
</div>

<div class="s3 c" style="letter-spacing:2pt;">ОБЪЕДИНЕННЫЙ ИНСТИТУТ ЯДЕРНЫХ ИССЛЕДОВАНИЙ</div>
<div class="s2 fr" style="text-align:left; margin:10pt 150pt 20pt 0pt;"><b>УТВЕРЖДАЮ</b><br>Директор Института</div> ??
<div class="clr"></div>
[end]


[report footer]
$GET_DATA [get more data]
$SET_PARAMETERS visit_aim=; ??visit_aim_id=0

<div class="b c s3" style="margin:10pt;">#division#</div>
<div class="b c s3" style="letter-spacing:5pt;">ЗАЯВКА</div>
<div class="b c s3"> на выдачу пропуска в ОИЯИ</div>

<div style="padding:10pt 70pt 15pt 70pt;">
<table border=0 style="width:100%;"><tr><td class="label cont">#today#</td><td class="c s2" style="width:50%;">г. Дубна</td>
<td class="label s2">№ _______ / <b>K</b>  #t_end#
</div>

#t_start#В соответствии с#t_mid##visit_osnovanie#</td></tr>
<tr><td colspan=2 class="c cont">&nbsp;</td></tr>
<tr><td colspan=2 class="c s-1">протокол о выполнении совместных НИР, договор, соглашение, план приема специалистов
#t_end#

<div class="s2">&nbsp; ПРИНЯТЬ:</div>
#t_start#Фамилия, имя, отчество#t_mid##visitor_F# #visitor_I# #visitor_O##t_end#
#t_start#Место работы и должность#t_mid##visitor_employment#, #visitor_post# #t_end#
#t_start#Гражданство#t_mid##visitor_strana##t_lab#Дата рождения#t_mid##visitor_dr# #t_lab# email #t_mid# #visitor_email# #t_end#
#t_start# ??
<table style="width:50%"><tr><td class="label">Срок приема с #t_mid##visit_dates##t_lab# по #t_mid##visit_dates_end_date# #t_end#


#t_start#Цель приема #t_mid##visit_aim# #visit_aim_comment#</td></tr>
<tr><td></td><td class="c s-1"> совместная работа (шифр темы), участие в совещании и т.д.#t_end#

<div class="b">&nbsp; Данные паспорта:</div>
#t_start#Фамилия, имя, отчество #t_mid##visitor_surname# #visitor_name# #visitor_patronymic# #t_end#
#t_start#Номер #t_mid##passport_nomer# #t_lab#Дата выдачи #t_mid##passport_date# #t_lab#Код подразделения #t_mid##passport_kod_podrazd# #t_end#
#t_start#Паспорт выдан #t_mid##passport_vidan# #t_end#

<br> 
$SET_PARAMETERS TYPE=16; COLLECTION_DOC_TYPE=16; LOG=ON; ??
$INCLUDE JINR/common_fields.dat[mnts_list_read] ??

$CALL_SERVICE c=svs/get_user_info; requested_user_id=#responsible_id#; ??responsible_id
#t_start#<b>Ответственный  за прием в подразделении:</b>#t_mid##responsible# #t_lab#№ телефона #t_mid##u_phone# 
</tr><td colspan=2></td><td class="label r"> e-mail #t_mid# #u_email# #t_end#

$SET_PARAMETERS u_IOF=;
$CALL_SERVICE c=svs/get_user_info; requested_user_id=#director_id#; ??director_id

<br><br>	
#t_start#Руководитель структурного подразделения:#t_mid# #t_lab# &nbsp; #t_mid# #u_IOF# </td></tr>
<tr><td></td><td class="c s0" style="width:35%;"><i>подпись</i>#t_lab# &nbsp; <td class="c s0" style="width:25%;"><i>расшифровка подписи </i>
 #t_end#

<script type="text/javascript" language="javascript"> 
window.setTimeout(function(){window.print();}, 700); 
</script>

</body></html>
[end]


[get more data]
select DATE_FORMAT(now(),'#dateFormat#') AS "today" 
, DATE_FORMAT('#visit_dates#','#dateFormat#') AS "visit_dates" ??visit_dates
, DATE_FORMAT('#visit_dates_end_date#','#dateFormat#') AS "visit_dates_end_date" ??visit_dates_end_date
, DATE_FORMAT('#visitor_dr#','#dateFormat#') AS "visitor_dr" ??visitor_dr
, DATE_FORMAT('#passport_date#','#dateFormat#') AS "passport_date" ??passport_date
;
select name as "division" from info_10 where id=#division_id# 
;
select user_id as "director_id" 
from a_user_role 
where role_id=6 and target_type_id=1 and active=1 and target_code=#division_id#
order by priority
limit 1
;
select visitor_F, visitor_I, visitor_O
from d_data_#DOC_TYPE_ID# where doc_id = #doc_id#

[end]


pass_LIAP=1 pass_LVE=1 pass_time=1 visa=1
