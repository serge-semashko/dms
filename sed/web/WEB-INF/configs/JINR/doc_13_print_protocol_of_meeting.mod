JINR/doc_13_print_protocol_of_meeting.mod


[parameters]
request_name=U:Печать протокола заседания закупочной комиссии.
service=jinr.sed.ServiceViewDoc  ??
service=dubna.walt.service.Service
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


[report]
    $INCLUDE [head]
    $INCLUDE dat/common.dat[check login]
    $LOG1 <b>============== print_doc: doc_id=#doc_id#; USER_ID=#USER_ID#; ==================</b><br>
    $CALL_SERVICE c=sys/getARUD; ??USER_ID

    $SET_PARAMETERS DOC_DATA_RECORD_ID=;
    $GET_DATA docs/view_doc.cfg[getDocInfo]    ??AR_R=Y
    $INCLUDE docs/custom_settings.cfg[set custom parameters]

    $GET_DATA [get more data]
    $GET_DATA [get doc_id list]

    $SET_PARAMETERS s3=21px; s2=19px; s1=17px; s0=15px; s-1=12px; solid=dotted;

    <body>
    <center>
        <img src="https://sed.jinr.ru/sed/images/JINR_Logo.png">
    </center>
    
    <br>
    <div class="b_c">Протокол заседания #Protocol_ZK_header# № #DocNumber# от #DocDate#</div>
    <br>

    <div class="b"> Присутствовали:</div>
    <br>
    <div class="t_i"><p>#Protocol_ZK_titulature#</p></div>
    <div class="t_i"><p>#Protocol_ZK_present#</p></div>
    
    <div class="b"><br> Повестка заседания:</div>  ??Protocol_agenda
    <div class="b_j">#Protocol_agenda#</div>  ??Protocol_agenda

    <div><br> Принять к сведению:</div>  ??Protocol_take_into_account
    <div class="j">#Protocol_take_into_account#</div>  ??Protocol_take_into_account

    <div class="b"><br> Постановили:</div>  ??Protocol_decided
    <div class="b_j">#Protocol_decided#</div>  ??Protocol_decided
    
    <br>
    
    <table>
    <tr><td class="b">Проголосовали «ЗА»:&nbsp;</td><td class="b_u">Проголосовали «ЗА»:</td></tr>
    <tr><td class="b">Проголосовали «ПРОТИВ»:&nbsp;</td><td class="b_u">Проголосовали «ЗА»:</td></tr>
    </table>
    
    <div>
    <BR>  ??Protocol_special_opinion
    Особое мнение: <BR>  ??Protocol_special_opinion
    #Protocol_special_opinion#  ??Protocol_special_opinion
    </div>
    
    <BR>
    
    <div class="b">Подписи:</div>


    
    
    
    <div> #OPEN_PROTOCOL_PRESENT#</div>
    <div> Процедура вскрытия конвертов с предложениями состоялась #OPEN_PROTOCOL_DATE# г. в ___ Мск.</div>
    <div> Извещение о начале проведения конкурентной процедуры было направлено в следующие компании: #provider_list# </div>
    <div> #OPEN_PROTOCOL#</div>
    <br>
    <div class="ft_sz_10">
    Предоставленные документы:
    </div>

    <table>
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=provider; label=; mode=1;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=+; label=Заявка на участие; mode=3;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=const_docs; label=Учредительные документы; mode=2;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=tax_certificate; label=Свидетельство о постановке на учет в налоговом органе; mode=2;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=extract; label=Выписка из ЕГРЮЛ; mode=2;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=accnt_report; label=Бухгалтерский отчет на последнюю дату; mode=2;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=; label=Ренференц-лист; mode=3;
    </table>
    
    <br>
    <div>
    Результаты оформлены в виде сравнительной таблицы
    </div>
    <div class="r_sz_10_st_i"> 
    Сравнительная таблица предложений участников
    </div>
    
    <table>
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=provider; label=Организация; mode=1; 
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=IF(TP_d_data.technical_task=1, 'да', 'нет'); label=Соответствие конкурсной документации; mode=1;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=bank_guarantee; label=Банковская гарантия; mode=1;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=concat(IFNULL(CAST(TP_d_data.cost as CHAR),' '), ' ', TP_d_data.cost_curr); label=Общая стоимость; mode=1;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=VAT; label=НДС; mode=1;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=terms_of_payment; label=Условия оплаты; mode=1;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=delivery_time; label=Срок поставки; mode=1;
        $CALL_SERVICE c=JINR/doc_13_print_opening_protocol_item; field=guarantee; label=Гарантия; mode=1;
    </table>


    <script type="text/javascript" language="javascript"> 
        window.setTimeout(function(){window.print();}, 700); > ??
    </script>

    </body></html>
[end]

[head]
    <!DOCTYPE html><html><head><TITLE>Протокол закупочной комиссии</TITLE>
    <META http-equiv=Content-Type content="text/html; charset=utf-8">

    <style>
    body {border:dotted 1px ##a0a0a0; font-family:Times; font-size:#s0#; width:510pt; margin:0 10pt 0 30pt; padding:3px;} ??
        body {border:none 1px ##a0a0a0; font-family:Times; font-size:#s0#; margin:0 20pt 0 50pt; padding:3px;}

        .s3 {font-size:#s3#;}
        .s2 {font-size:#s2#;}
        .s1 {font-size:#s1#;}
        .s0, table.item td.s0 {font-size:#s0#;}
        .s-1 {font-size:#s-1#;}
        
        .ft_sz_10 {font-size:10pt;}
        .ft_st_i {font-style:italic;}

        .b {font-weight:bold;}
        .c {text-align:center;}
        .r {text-align:right;}
        .b_c {
            font-weight:bold;
            text-align:center;
        }
        .b_j {
            font-weight:bold;
            text-align:justify;
        }
        .j {
            text-align:justify;
        }
        .b_u {
            font-weight:bold;
            text-decoration:underline;
        }
        
        .r_sz_10_st_i {
            text-align:right;
            font-size:10pt;
            font-style:italic;
        }
        
        .t_i {
            text-indent: 2.5em;
            text-align: justify;
        }

        .fl {float:left;}
        .fr {float:right;}
        .clr {clear:both;}

        table {
            border-collapse: collapse;
            border-color: #008a77; ??
            font-size: 10pt;  ??
        }
        td, th {
            border: 1px solid black;  ??
        }
        
    </style>
    </head>
[end]

[get doc_id list]
    select group_concat(TP_d_data.doc_id) as "doc_id_list"
    from d_data_14 TP_d_data
        left join d_list dh on dh.id = TP_d_data.doc_id
    where dh.pid = #doc_id#
[end]




[get more data]
    select dh.id
        , dh.number AS "DocNumber"
        , DATE_FORMAT(dh.doc_date,'#dateFormat#') AS "DocDate"
        , dh.title AS "DocTitle"
    from d_list dh
    where dh.id = #doc_id#
;
    select d_d.id
        , d_d.ZK_header AS "Protocol_ZK_header"
        , d_d.ZK_titulature AS "Protocol_ZK_titulature"
        , d_d.ZK_present AS "Protocol_ZK_present"
        , d_d.commission_members` mediumtext COMMENT 'Состав закупочной комиссии',  ??
        , d_d.commission_members_id` varchar(1000) DEFAULT NULL COMMENT 'IDs справочника - Состав закупочной комиссии',  ??
        , d_d.commission_members_rank` varchar(1000) DEFAULT NULL COMMENT 'Должности (1- Председатель ЗК, 2- Зам.пред, 3- Член ЗК, 4- Секретарь)',  ??
        , d_d.commission_members_presence` varchar(1000) DEFAULT NULL COMMENT 'Присутствие (0- отсутствует, 1- присутствует)',  ??
        , d_d.commission_members_votes` varchar(1000) DEFAULT NULL COMMENT 'Результат голосования (-1- не голосует (секретарь), 0- не голосовал, 1- ЗА, 2- Против, 3- Воздержался)',  ??
        , d_d.invited` mediumtext COMMENT 'Приглашенные ',  ??
        , d_d.invited_id` varchar(1000) DEFAULT NULL COMMENT 'IDs справочника - Приглашенные ',  ??
        , d_d.agenda AS "Protocol_agenda"
        , d_d.take_into_account AS "Protocol_take_into_account"
        , d_d.considered AS "Protocol_considered"
        , d_d.decided AS "Protocol_decided"
        , d_d.tenderer_id` varchar(255) DEFAULT NULL COMMENT 'Участники конкурса (ID типа объектов коллекции)',  ??
        , d_d.special_opinion AS "Protocol_special_opinion"
        , d_d.opening_protocol AS "Protocol_opening_protocol"
        , DATE_FORMAT(d_d.opening_protocol_date,'#dateFormat#') AS "Protocol_opening_protocol_date"
        , d_d.opening_protocol_contract AS "Protocol_opening_protocol_contract"
        , d_d.opening_protocol_present AS "Protocol_opening_protocol_present"
    from d_data_13 d_d
    where doc_id = #doc_id# 
;
    select concat(TP_d_data.provider, ', ') as "provider_list"
    from d_data_14 TP_d_data
        left join d_list dh on dh.id = TP_d_data.doc_id
    where dh.pid = #doc_id#
[end]



