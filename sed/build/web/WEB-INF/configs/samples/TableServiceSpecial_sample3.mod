samples/TableServiceSpecial_sample3.cfg

[comments]
testURL=?c=samples/TableServiceSpecial_sample3
author:Фуряева
[end]

[description]
    Пример применения сервиса TableServiceSpecial.
    <ol>
        <li>Создает форму с фильтрами, получает данные из базы для формирования выпадающих списков</li>
        <li>Выводит заголовок таблицы </li>
        <li>Выполняет запрос в БД</li>
        <li>Выводит тело таблицы</li>
        <li>Сортировка таблицы</li>
        <li>Создает навигацию по страницам</li>
    </ol>
[end]

[parameters]
    service=dubna.walt.service.TableServiceSpecial
    tableCfg=table_no
    ++++++++ Установка текущей страницы +++++++??
    rowLink=|<span class="page" onClick="goToRow(#srn_i#);">#srn_i#-#ern_i#</span> ??!currentPage
    rowLink=|<span class="currPage">#srn_i#-#ern_i#</span> ??currentPage
[end]

[head]
    <head>
    <meta charset="utf-8">
    <title>TableServiceSpecial_sample3</title>
    <script type="text/javascript" src="#jsPath#jquery-1.11.0.min.js"></script>
    <style>
    td {border:1px solid white}
    .oddRow {background: #FFFFFF;}
    tr:nth-child(2n) {
        background: #E0FFFF;
       } 
    tr:nth-child(1) {
       background: #B0E0E6; 
       }

    .sel {background-color: #FFFF80;}
    .srh {cursor:pointer;}

    th.srh {padding: 1px 0 1px 14px;}
    th.sup { background: url(/hrlhep/images/sortUp.gif) no-repeat scroll left center; }
    th.sdown {background: url(/hrlhep/images/sortDown.gif) no-repeat scroll left center;}

    td.pager .page {color:##0000d0; text-decoration: none; font-size:8pt; cursor:pointer;}
    td.pager .currPage {color:##000000; font-weight:bold; font-size:9pt;}
    </style>
    <script>
    ============== Сортировка таблиц ================== ??
    /**
     * Вызывается по клику на <th class="srh"> для сортировки таблицы по этой колонке
     * Берет из атрибута sr поле (или выражение), по которому необходимо отсортировать 
     * Если поле сортировки не изменилось, то инвертирует параметр desc
     * иначе - ставится новое значение поля сортировки в input srt формы theForm
     * Далее делает document.theForm.submit();
     */
    var setSrt = function(ev) {
        var s_new = $(this).attr("sr");
        var s_old = document.theForm.srt.value;
        if (s_new == s_old)
        { if(document.theForm.desc.value == 'desc') document.theForm.desc.value = '';
            else document.theForm.desc.value = 'desc';
        }
        else {
            document.theForm.srt.value = s_new;
        }
        document.theForm.submit();
        return false;
    }
    /**
     * Отображает порядок сортировки 
     * Добавляет класс к тегу <th class="srh">
     */
    var showSrt = function(srt, cl) { 
        $("th[sr='" + srt + "']").addClass(cl); 
    }
    /**
     * Навигация по страницам
     * nr - начальный номер строки
     */
    function goToRow(nr)
    { 
      document.theForm.srn.value=nr;  
      document.theForm.submit();
    }
    /**
     * Добавление/удаление класса по событиям mouseover/mouseout
     */
    var sel = function(ev) {
            if(ev.type == "mouseover") $(this).addClass("sel");
            else if(ev.type == "mouseout")	$(this).removeClass("sel");
            return true;
    }
    /**
     * Установка обработчиков событий mouseout, mouseover, click
     */ 
    $( document ).ready(function() {
            $('.srh').mouseout(sel);
            $('.srh').mouseover(sel); 
            $('.srh').click(setSrt);
    } )
    </script>
    </head>
[end]

[report header]
<html>
$INCLUDE [head] 
<body>
+++++ Форма (фильтры, сортировка, и др.) +++++ ??
<form name="theForm" method="post">
+++++++ Начальная строка и кол-во строк на странице по умолчанию ++++ ??
$SET_PARAMETERS srn=1; rpp=10;  ??!srn|!rpp
<input type="hidden" name="srn" value="#srn#">
+++++++ Сортировка по умолчанию (по ФИО) +++++ ??
$SET_PARAMETERS srt=concat(test_persons.F, test_persons.I, test_persons.O); desc=; ??!srt
+++++++ Параметры сортировки в запросе +++++ ??
<input type="hidden" name="srt" value="#srt#">
<input type="hidden" name="desc" value="#desc#">
<center>
+++++++ с - путь к текущему модулю +++++ ??
<input type=hidden name="c" value="#c#">
<table border="0" cellpadding="7">
<tbody>
<tr> 
<td>Фамилия: <input size=15 name="f" value="#f#"></td>
<td>Имя:<input size=15 name="i" value="#i#"></td>
<td>Отчество:<input size=15 name="o" value="#o#"></td>
</tr>
<tr>
+++++++ Директива выполнения запроса в бд +++++++++ ??
$GET_DATA [get dropdowns]
<td>Страна: 
<select name=country class=norm>
<option value="">любая</option>
#COUNTRIES#
</select>
<td>
    Город: 
    <select name=city class=norm>
    <option value="">любой</option>
#CITIES#
</select>
</td>
<td>
<input type="submit" style="width:130;" value="Выполнить"> </br>
</td>
</tr>
</tbody>
</table>
$SET_PARAMETERS srt=dh.STATUS; desc=; ??!srt
+++++++ Шапка таблицы +++++ ??
<table class="tlist tgreen" cellspacing=0 border="1">
<tr>
<th class="srh" sr="test_persons.id">ID</th>
<th class="srh" sr="concat(test_persons.F, test_persons.I, test_persons.O)">ФИО</th>
<th class="srh" sr="test_persons.country">Страна</th>
<th class="srh" sr="test_persons.city">Город</th> 
<th class="srh" sr="test_persons.profession">Профессия</th> 
</tr>
</center>
[end]

[get dropdowns] ***** Получение данных из базы в выпадающий список
select distinct concat('<option value="', country, '" '
, case when country='#country#' then 'selected' else '' end
, '>' , country, '</option>') as COUNTRIES
from test_persons
;
select distinct concat('<option value="', city, '" '
, case when city='#city#' then 'selected' else '' end
, '>' , city, '</option>')as CITIES
from test_persons
[end]

[item] ***** Cоздание строки таблицы - 1 записи
<tr class="pt
oddRow ??oddRow=1
" >
<td>#id#</td> 
<td>#F# #I# #O#</td> 
<td>#country#</td>
<td>#city#</td>
<td>#profession#</td>
</tr>
[end]


[report footer]
+++++++ Кол-во столбцов в таблице +++++ ??
$SET_PARAMETERS NumTableCols=5;
<tr><td colspan=#NumTableCols# class="pager last">
$INCLUDE [rpp]  ??!NumTableRows=0
<input type=hidden name="rpp" value="#rpp#"> ??NumTableRows=0
</td></tr>
</table>
</form>
<script type="text/javascript">
showSrt("#srt#","sup"); ??!desc
showSrt("#srt#","sdown"); ??desc
</script>
</body>
</html>
[end]

[SQL]  ****** Шаблон SQL запроса 
select id, F, I, O, country, city, profession
from test_persons
where 1=1
and F like '#f#%' ??f
and I like '#i#%' ??i
and O like '#o#%' ??o
and city like '#city#%' ??city
and country like '#country#%' ??country
order by #srt# #desc# ??srt
[end]

[rowLinks]
rowLink=|<a class=page href="javascript:#execute#; goToRow(#srn_i#);">#srn_i#-#ern_i# </a> ??!currentPage
rowLink=|<span class=actPage>#srn_i#-#ern_i#</span> ??currentPage
prevSetLink=<a class=page href="javascript:#execute#; goToRow(#srn_i#);"> <<< предыд. </a> 
nextSetLink=| <a class=page href="javascript:#execute#; goToRow(#srn_i#);"> следующие >>> </a>
[end]

[rpp]  ****** Вывод кол-ва строк на странице и навигации по страницам
Строк на странице:
<SELECT NAME="rpp" class=small onChange="goToRow(1);">
<OPTION value="10">10
<OPTION value="20"
selected ??rpp=20
>20 <OPTION VALUE="9999"
selected ??rpp=9999
> не огр.  
 ??user_group=sys
</SELECT> &nbsp; &nbsp; &nbsp; Строки: #rowLinks# |
[end]