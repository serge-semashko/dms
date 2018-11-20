[comments]
descr=А: Структура справочника, его данные и старт обновления данных. 
note=Вызывается из admin/infos/info_item.cfg по клику на табе
input=info_id - ID выбранного справочника
output=HTML представление структуры, источника и данных справочника, 
parents=admin/infos/info_item.cfg
childs=admin/infos/info_viewData.cfg
test_URL=?c=admin/infos/info_data&info_id=1
author=Куняев
[end]

[parameters]
request_name=A:данные справочника
KeepLog=false
hr=<tr><td colspan=2><hr></td></tr>
[end]


[report]
    <html><body>
        $SET_PARAMETERS RWACC=Y; RACC=Y;
        $SET_PARAMETERS debug=on ??
        $GET_DATA [getInfoSQL]
        <div id="result">
        #c# ??debug=on
        <center>
            $INCLUDE [form] ??!cop&RACC=Y
            $INCLUDE [pasteBackScript] ??!cop
            $INCLUDE [process] ??cop&RWACC=Y
    </body></html>
[end]


[form]
    <table border=0 cellpadding=3 style="background-color:white; width_:100%; border:none 1px gray;">
        <tr>
            <td class=label>Справочник:</td>
            <td><b>#INFO_NAME#</b>,
                внутренний, ??IS_EXTERNAL=0
                внешний,			??IS_EXTERNAL=1
                иерархический (дерево) ??IS_TREE=1
                плоский ??IS_TREE=0
            </td>
        </tr>
        <tr>
            <td class=label>Поля:</td><td>
                $CALL_SERVICE c=admin/infos/info_list_fields; 
            </td>
        </tr>
        $INCLUDE [ExtSrc] ??IS_EXTERNAL=1

        <tr>
            <td class=label>Последнее<br>обновление данных:</td>
            <td>
                <div style="width:400px; float:left; border:none 1px green;"><b>?</b></div>
                $INCLUDE [updateButton]  ??IS_EXTERNAL=1
                <div style="clear:both;"></div>
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <input type="button" class="butt1 pt" style="width:160; margin-bottom:10px;" value="Просмотр данных" onClick="showNext(0);"> 
            </td>
        </tr>
    <tr><td class=label>Изменено:</td><td class=small>#MODIFIED#, #MODIFIER#</td></tr> ??
    </table>

    #hr#
    <div id="test_result" style="width:100%; overflow: auto;
        border:solid 1px black; ??
       " class="resize">
    </div>
    </center>

    <script type="text/javascript">
        var showNext  = function(shift){
        try{
                var start_rec = Number(document.theForm.START_REC.value);
                var irpp = Number(document.theForm.irpp.value);
                if(shift > 0) start_rec = start_rec + irpp;
                else if(shift < 0) start_rec = start_rec - irpp;
                else start_rec = 1;
                if(start_rec < 1) start_rec = 1;
                document.theForm.START_REC.value = start_rec;
                } catch (e) {;}
                document.theForm.c.value = "admin/infos/info_viewData"; ??
        //	log(3, "showNext: start_rec=" + start_rec); 
                document.theForm.submit(); 
        }
    </script>
</div>
[end]


[updateButton]
    <div class=right style="float:left; border:none 1px red;">
        <input type="button" class="butt1 pt" style="width:160; margin-bottom:10px;" value="Импорт данных" 
            onClick=
            "doSubmit('', 'admin/infos/info_loadData');"  ??!CUSTOM_UPDATER
            "AjaxCall('test_result', 'c=#CUSTOM_UPDATER#&info_id=#info_id#');"  ??CUSTOM_UPDATER
        > <br>
        Показывать: 
        <input type=radio name=show value="changed" checked> только изменения
        <input type=radio name=show value="all"> все данные
    </div> 
[end]



[ExtSrc]
    #hr# 
    <tr><td class=label>Источник:</td><td><b>
            База данных ??SRC_TYPE=0
            XML данные ??SRC_TYPE=1
            JSON данные ??SRC_TYPE=2
        </b></td>
    </tr>

    <tr>
        <td class=label>Подключение:</td><td><b>#CONN_NAME#</b> (
            MySQL ??DB_TYPE=0
            Oracle ??DB_TYPE=1
            MS SQL ??DB_TYPE=2
            ):
            #SERVER#:#PORT#:#PARAM#
            (#CONN_USR# / 
            ***** ??CONN_PW
            , #DB_SCHEMA# ??DB_SCHEMA
            )
        </td>
    </tr>
    <tr><td class=label>SQL запрос:</td><td>#REQUEST#</td></tr>
[end]


[pasteBackScript]
    <script type="text/javascript">
        window.parent.getResult("dt_infoItem", document.getElementById("result"));
        window.parent.doSubmit("", "admin/infos/info_viewData"); 
    </script>
[end]


[getInfoSQL]
    try: select i.ID
        , i.name as INFO_NAME, i.IS_EXTERNAL
        , ed.SRC_TYPE, ed.CONN_ID, ed.REQUEST
        , ec.DB_TYPE, ec.CONN_NAME, ec.DB as DB_SCHEMA
        , i.IS_TREE, i.IS_ACTIVE
        , ec.SERVER, ec.PORT, ec.PARAM, ec.USR as CONN_USR, ec.PW as CONN_PW
        , i.TABLE_NAME, i.CUSTOM_MODULE, i.CUSTOM_UPDATER
        , i.do_favorites, i.rpp as "irpp"
        , data_updated 
    from i_infos i
        left join i_external_data ed on ed.info_id=i.id
        left join i_ext_connections ec on ec.id=ed.conn_id
    where i.Id=#info_id#
[end]


================== Занесение данных в базу (cop=save) ====================
[process]
    ============= PROCESS ================
    $GET_DATA [updateInfoSQLs]  ??cop=save

    ============= SCRIPT ================
    #ERROR#
    <script type="text/javascript">
        alert("#ERROR#); ??ERROR
        alert("Не реализовано. cop=" + cop);   
          ??cop=new
    </script>
    ============= DONE ================
[end]

