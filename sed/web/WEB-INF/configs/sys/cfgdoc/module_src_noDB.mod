sys/cfgdoc/module_src_noDB.mod

[comments]
descr=A: Вывод исходного кода модуля
input=dir - путь к модулю; name - имя файла; sct - имя секции
output=HTML таблица папок модулей
parents=sys/cfgdoc/table_noDB.cfg
childs=
testURL=?c=sys/cfgdoc/module_src_noDB&dir=samples/&name=TableServiceSpecial_sample.cfg ??
author=Куняев
[end]

[description]
Модуль выводит информацию о выбранном модуле (если параметр sct отсутствует)<br>
или содержимое секии sct этого модуля
Вызывается из sys/cfgdoc/table_noDB.
service: <b>dubna.walt.cfgdoc.ServiceCfgDocModule.</b> Основную работу делает сервис. 
[end]


[parameters]
service=dubna.walt.cfgdoc.ServiceCfgDocModule   
clr=<div style="clear:both;"></div>
[end]


[report] 
$INCLUDE sys/cfgdoc/main_noDB[head]

<body>

<div class="title">Файл: /#dir##name#</div>
<h3 class="hasnocomments">  Файл не найден!</h3> ??!file_found
$INCLUDE [file details] ??file_found
$INCLUDE sys/cfgdoc/main_noDB[popup div] 
</body></html>
[end]

[file details]  *** Вывод разделов информации о модуле
#clr#

<div class="title">Описание :</div>#clr# <div class="desBlock"> 
$INCLUDE #dir##name#[description]
<br>
<a href="#cfg_test_url#" target="_blank">Выполнить пример</a>
</div>#clr#

<div class="title">Структура:</div>#clr# <div id="moduleStruct" class="desBlock">#cfg_sections_list#</div>#clr#

<div class="title pt" onClick="$('##moduleSrc').toggle();">Полный текст:</div>
#clr#
<div id="moduleSrc" class="desBlock" style="display:block;"><pre>#cfg_src_html#</pre></div> 

#clr#

<script>setStandardEvents();</script>
[end]


[section_item] *** вывод строки секции (заголовок)
<div class="pt" style="margin: 0 0 0px 0; padding: 5px 0 5px 0; border-bottom: dotted 1px gray;"
onClick="ShowDialog(false); AjaxCall('popupCont', 'c=#c#&dir=#dir#&name=#name#&sct=#cfg_section_name#');"
>#cfg_section_line#</div>
[end]


[sct header] *** открытие контейнера содержимого секции
<div class="desBlock" style="margin:0 0 10px 0; white-space:nowrap; overflow:auto;">
[end]

[sct footer] *** закрытие контейнера содержимого секции
<span>[end]</span>
</div>
<center>
<input type=button onClick="HideDialog();" value="Закрыть">
</center>

<script type="text/javascript">
window.parent.showMsg("##dialog_title", "Секция: #dir##name#[#sct#]");
centerDialog();
</script>
[end]



