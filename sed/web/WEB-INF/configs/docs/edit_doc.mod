docs/edit_doc.ajm

[comments]
descr=U: Редактирование документа из списка моих документов

input=doc_id - ID документа
output=HTML форма редактирования документа, 
parents=tab_myDocs.cfg
childs=
test_URL=?c=docs/edit_doc&doc_id=1
author=Куняев
[end]


[parameters]
request_name=U:Редактирование документа
service=jinr.sed.ServiceEditDoc
LOG=ON
SYS_FIELDS=IS_ACTIVE
SYS_FIELDS_TYPES=int
SYS_FIELDS_UPDATE=is_active, modified, modifier_id
SYS_FIELDS_UPDATE_TYPES=int,sysdate,int
is_active=1
modifier_id=#USER_ID#
divider=<tr><td colspan=3 class="divider"></td></tr>
[end]

[getDocInfo]
$SET_PARAMETERS request=write; NUMBER=; DOC_DATE=;
$GET_DATA docs/view_doc.cfg[getDocInfo] ??!child=y
[end]

[report header]
    $INCLUDE dat/common.dat[check login] 
    $LOG ======= edit_doc ====== queryString=#queryString#; <br>INPUT_ERROR='#INPUT_ERROR#';<br>
    $CALL_SERVICE c=sys/getARUD;   ??USER_ID
    $SET_PARAMETERS AR_W=Y;  ??USER_ID=2309
    $SET_PARAMETERS AR_W=Y; ??USER_ID&cop=save
    $SET_PARAMETERS ERROR=Отказано в доступе; ??!AR_W=Y
    $LOG ======= edit_doc ====== ERROR='#ERROR#'; INPUT_ERROR='#INPUT_ERROR#'; AR_W=#AR_W#&USER_ID=#USER_ID#;
    $CALL_SERVICE c=sys/log_doc_access; access_type=#~doc_action_change#; rejected=1;   ??!AR_W=Y&USER_ID

    $INCLUDE [report header_]   ??AR_W=Y
[end]

[report header_]
    $LOG ======= начало запроса ====== INPUT_ERROR = '#INPUT_ERROR#'; div=#f_data_1_17#; id=#f_data_1_17_id#; <br>
    $INCLUDE JINR/colors.dat[set colors]

    <style>
    ==== список выбранного из справочников при редактировании документа - в строчку ====== ??
        table.edit_object_table ul.p0, li.nobull {display:inline; margin-right:10px;}
    </style>
    $GET_DATA docs/view_doc.mod[getDocInfo]  ??child=y_ZZZ
    $INCLUDE [process]  ??cop&!ERROR&!INPUT_ERROR
    $SET_PARAMETERS cop=; ??ERROR|INPUT_ERROR
    $LOG <b>**************** ERROR = #ERROR#</b><br> ??ERROR
    $LOG <b>**************** INPUT_ERROR = '#INPUT_ERROR#'</b><br> ??INPUT_ERROR
doc_id=#doc_id#; ??
    $CALL_SERVICE c=docs/edit_doc_form.cfg;  ??!cop|ERROR
[end]

[report footer]
    <script type="text/javascript" language="javascript">
        showDoc(true, "Редактирование документа"); ??!mode=ADMIN
        alert("Ошибка в данных!\n\rПроверьте правильность заполнения формы."); ??INPUT_ERROR
    </script>

    $INCLUDE [process footer]  ??cop&AR_W=Y
    $INCLUDE [start converter]  ??!ERROR&child=y
[end]


[start converter]
    <div id="converter_div" 
    style="display:none;"  ??!USER_ID=2309
    >...</div>
    <script type="text/javascript" language="javascript">
        AjaxCall("converter_div", "c=files/sys/convertDocFiles&doc_id=#doc_id#&child=y", true);
    </script>
[end]


[process]
    $LOG <b>======= Сохранение документа ===============</b>  number='#number#', doc_date='#doc_date#'; number_type=#number_type#; <br>  ??cop=save
    $GET_DATA [getDocTextFields4Index] ??cop=save

    $LOG ======= начало транзакции для всего этого запроса ====== div=#f_data_1_17#; id=#f_data_1_17_id#;<br>
    $GET_DATA [start transaction] ??cop

    $INCLUDE docs/custom_settings.cfg[before save] ??cop=save
    $LOG3 <b>======= update header ==========</b>  number='#number#', doc_date='#doc_date#'; number_type=#number_type#; <br>  ??cop=save
    $GET_DATA [update header SQL] ??cop=save
[end]


[process footer]
    $SET_PARAMETERS PARENT_DOC_ID=#doc_id#;  ??
    $SET_PARAMETERS PARENT_DOC_ID=;

    $LOG ======= конец транзакции ======??
    $GET_DATA [commit]
    $LOG ======= начало транзакции для custom fields ======??
    $GET_DATA [start transaction]
    $INCLUDE [process custom fields] ??cop=save&!ERROR
    $CALL_SERVICE c=docs/set_doc_divs; ??!ERROR
    $LOG ======= конец транзакции ======??
    $GET_DATA [commit]
    $CALL_SERVICE c=sys/ar/set_doc_attrs; setPermit=Y; 
    $CALL_SERVICE c=sys/log_doc_access; doc_id=#doc_id#; access_type=2; ??!ERROR
    $SET_PARAMETERS cop=; ??ERROR

    $CALL_SERVICE c=wf/create_wf_for_doc;  ??!ERROR&HAS_WF=1&DOC_STATUS=#~doc_status_draft#&!saveColl
    $CALL_SERVICE c=docs/custom_settings.cfg; defaults=clear; ??!ERROR
    $CALL_SERVICE c=docs/doc_out_files; doc_id=#doc_id#;  ??!ERROR&cop=save&!saveColl
    $INCLUDE [processed js] ??!saveColl
    
    $LOG_ERROR ERROR: #ERROR#;   ??ERROR
    $SET_PARAMETERS ERROR=Ошибка сохранения данных документа; ??ERROR
    $CALL_SERVICE c=docs/edit_doc_form.cfg;  ??ERROR

[end]

[processed js]
<script type="text/javascript">
    jAlert("Документ сохранён.", "OK");  ??!ERROR&cop=save
    AjaxCall("doc_content", "c=docs/view_doc&doc_id=#doc_id#&mode=popup"); ??!ERROR&cop=save&!mode=ADMIN
    jAlert('Ошибка сохранения данных документа','ОШИБКА!'); ??ERROR
    AjaxCall("c_settings", "c=gateway/post_doc&doc_id=#doc_id#", true); ??!ERROR&POST_DOC_AT_STEP=1&cop=save&NUMBER&!mode=ADMIN
    AjaxCall('c_myDocs', 'c=tab_myDocs');  ??!ERROR&cop=save&!mode=ADMIN&!user_id=2309
</script>
[end]



***************************** Шаблоны SQL запросов ***************************
    Запрос на выборку и обновление собственно данных документа 
    формируется в сервисе ServiceEditDocData
==============================================================================
[start transaction]
    START TRANSACTION;
[end]

[commit]
    COMMIT;   ??!ERROR
    ROLLBACK;  ??ERROR
[end]


[getDocTextFields4Index]
    select /* doc data text fields */ 
       concat(replace(dtf.name,',',' '), ',') as DOC_TEXT_NAMES
     , concat(dtf.field_db_name, ',') as DOC_TEXT_FIELDS
    from d_fields dtf
        left join d_list dh on dtf.type_id = dh.type_id
    where dh.Id = #doc_id# and dtf.type='varchar'
        and dtf.is_visible>0 and dtf.is_active=1 
    order by nr
    ;
[end]

[SQL]
$INCLUDE docs/view_doc.mod[SQL_] ??AR_W=Y
[end]


[update header SQL]
    update d_list set title='#title#'
        , number='#number#' ??number&number_type=2|number_type=4
        , number=null       ??!number&number_type=2
        , doc_date=STR_TO_DATE('#doc_date#', '#dateFormat#')  ??doc_date&number_type=2|number_type=4
        , doc_date=null ??!doc_date&number_type=2
        , is_confidential=0 ??!is_confidential=1
        , is_confidential=1 ??is_confidential=1
        , is_deleted=0, comment='#comment#'
        , modified=now(), modifier_id=#USER_ID#
    where id=#doc_id#
[end]

        , status=0 ??!DOC_STATUS=#~doc_status_signed#&!CURR_STEP_TYPE=#~wf_step_preparation#


=============== ОБРАБОТКА CUSTOM FIELDS (определяются в d_form_fields_types.section.s) ========

[process custom fields]
    $GET_DATA docs/edit_doc.cfg[get custom fields]
    $EXECUTE_LOOP cf_id; #CUSTOM_FIELD_ID#; docs/edit_doc.cfg[save custom field]
[end]

[get custom fields]
    select concat(dtf.id,',')  as "CUSTOM_FIELD_ID"
    from d_fields dtf 
    join d_form_fields_types df on df.id=dtf.form_field_type 
    where
        dtf.type_id=#DOC_TYPE_ID#
        and dtf.is_visible in(1,3)
        and dtf.is_visible=1  ??
        and dtf.is_active=1 
        and dtf.min_doc_type_version <= #DOC_TYPE_VERSION#  
        and dtf.max_doc_type_version >= #DOC_TYPE_VERSION#  
        and length(df.section_s)>0
[end]


[save custom field]
    $GET_DATA docs/edit_doc.cfg[get custom field param]
    $INCLUDE #CUSTOM_FILE#[#SAVE_SECTION#]
[end]

[get custom field param]
    select field_db_name  as "CUSTOM_FIELD_DB_NAME"
     , df.src_file as "CUSTOM_FILE" , df.section_s as "SAVE_SECTION"
    from d_fields dtf 
    join d_form_fields_types df on df.id=dtf.form_field_type 
    where dtf.id=#cf_id#
[end]


==============================================================================

