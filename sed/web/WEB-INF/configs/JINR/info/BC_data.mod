JINR/info/BC_data.mod


[comments]
descr=Модуль вывода данных справочника бюджетных кодов ОИЯИ (непосредственно вывод таблицы)
input=requesterId - ID элемента для результата, info_id - ID справочника; view - № представления. По умолчанию - 1; searchFor - строка поиска.
output=html-таблица заданного представления справочника. По клику возвращает 1-е (код записи или ID) и 2-е (текст) поля представления. 
parents=JINR/info/BC.cfg
childs=
testURL=?c=JINR/info/BC_data&info_id=1005&view=1
author=Куняев
[end]

[description]
Вызывается через Post формы из JINR/info_BC.cfg
[end]

[parameters]
request_name=U:вывод данных справочника БК
service=dubna.walt.service.TableServiceSpecial
tableCfg=table_no
KeepLog=true
ClearLog=false
info_src=false
[end]



[report header]
    $SET_PARAMETERS is_prikaz=; ??f_prikaz
    $SET_PARAMETERS f_sbj=; ??is_prikaz=v
    $SET_PARAMETERS f_bc_div_id=; f_resp=; f_sbj=; f_prikaz=; is_prikaz=; f_bc_project_id=;  ??f_code

    $GET_DATA [get num records]

    $SET_PARAMETERS callback=pasteInfoResult; ??!callback
    $SET_PARAMETERS f_bc_div_id=900000; ??f_bc_div_id={{^6000$|^9000$|^35000$|^55000$|^60000$|^70000$|^80000$}}
    $SET_PARAMETERS f_bc_div_id=900000; ??f_bc_div_id={{^950000$|^960000$|^970000$|^999998$}}
    <div id="result_table">
    <center>
    ============ Начало таблицы =============== ??
    irpp=#irpp#; isrn=#isrn#; ??
    <table border=0 class="tlist dd_info" id = "#requesterId#_info_table" cellpadding=0 cellspacing=0>
        <tr>
        <th></th> ??
        <th>Лаб.</th><th>Тема</th><th>Код</th><th>Ответственные</th><th>Описание</th></tr>
[end]


============ Строка таблицы =============== ??
[item]
    $SET_PARAMETERS DIV=Упр.; ??DIV_CODE=990000

    $SET_PARAMETERS returnValue=#CODE#, #DIV# ??
    $SET_PARAMETERS returnValue=#returnValue#, т.#SBJ# ??SBJ_ZZZ
    $SET_PARAMETERS returnValue=#returnValue#, #DES# ??ZZZ&PRIKAZ_N|!SBJ
    $SET_PARAMETERS returnValue=<span class=#CLASS#>#returnValue#</span>  ??CLASS
    <tr class="pt" onClick="selectInfoItem(this,'#returnValue#'); hideSprav();"
        info_id=#info_id# view=3 returnId="#CODE#" recordId="#CODE#"
        onMouseOver="showInfoToolTip(event, $(this));" onMouseOut="hideToolTip();" ??
    >
        <td class="marked-cell"></td> ??
        <td>#DIV#</td>
        <td>#SBJ#</td>
        <td>#CODE#</td>
        <td>#RESP#</td>
        <td
            class=#CLASS#  ??CLASS
        >#DES#</td>
    </tr>
[end]

[prevLink]
    <span class="pt" onClick="showNext(-1);"> << </span>
[end]

[nextLink]
    <span class="pt" onClick="showNext(1);"> >> </span>
[end]


[report footer]
        $SET_PARAMETERS HAS_PREV=Y; ??START_REC>1
        $SET_PARAMETERS HAS_NEXT=Y; ??END_REC<#TOT_NUM_RECS#
        <tr><td colspan=3 class="divider"></td><td colspan=2 class="divider">
                $INCLUDE [prevLink] ??HAS_PREV=Y
                строки #START_REC#-#END_REC# из #TOT_NUM_RECS#  ??TOT_NUM_RECS>0
                #TOT_NUM_RECS#: <b>Нет данных</b>  ??!TOT_NUM_RECS>0
                $INCLUDE [nextLink] ??HAS_NEXT=Y
                </center>
                <b>ОШИБКА:</b> #ERROR# ??ERROR
            </td>
        </tr>
    </table>
    </div>

    <script type="text/javascript">
        window.parent.getResult("info_result_data", document.getElementById("result_table"));
        window.parent.infoForm.f_sbj.value=""; ??is_prikaz=v
    </script>
[end]


==============================================================
==============================================================
==============================================================

[preSQLs]
    select #START_REC#-1 as "isrn", #START_REC#+#irpp#-1 as END_REC, extract(year from now()) -2000 as "CURR_YR"
[end]

[get num records]
    select count(*) as TOT_NUM_RECS
    $INCLUDE [criteria]
[end]

[SQL]
    select bc.id as "CODE", l.short_name as "DIV", bc.DIV_CODE, bc.SBJ, bc.RESP
        , bc.DES, PRIKAZ_N, bc.CLASS
        , bc.DES_ALL as "returnValue" 
    $INCLUDE [criteria]
    order by bc.dir, ifnull(bc.SBJ,10000)
    LIMIT #isrn#,#irpp#
[end]

[criteria]
    from i_jinr_bc bc
    left join info_10 l on l.id=bc.div_code
    where 1=1
        and bc.id<400 ??
        and bc.is_deleted=0
        and bc.YR<=#CURR_YR# 
        and bc.LY>=#CURR_YR# 
        and div_code=#f_bc_div_id# ??f_bc_div_id&!f_bc_div_id=900000
        and div_code=990000 ??f_bc_div_id=900000
        and resp like '%#f_resp#%' ??f_resp
        and sbj=#f_sbj#  ??f_sbj
        and bc.id=#f_code#  ??f_code
        and des like 'пр.#f_prikaz# от %' ??f_prikaz
        and prikaz_n is null  ??is_prikaz=n
        and not prikaz_n is null  ??is_prikaz=y
        and dir='Внебюджет'  ??is_prikaz=v
        and project_id=#f_bc_project_id#  ??f_bc_project_id
[end]


