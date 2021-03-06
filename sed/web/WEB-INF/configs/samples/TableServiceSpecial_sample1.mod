samples/TableServiceSpecial_sample1.cfg

[comments]
testURL=?c=samples/TableServiceSpecial_sample1
author:Фуряева М.Т.
[end]

[description]
Пример применения сервиса TableServiceSpecial.
<ol>
    <li>Выводит заголовок таблицы </li>
    <li>Выполняет запрос в БД</li>
    <li>Выводит результат в виде таблицы</li>
</ol>
[end]

[parameters]
service=dubna.walt.service.TableServiceSpecial
tableCfg=table_no
[end]


[report header]
    <html>
    <head>
        <meta charset="utf-8">
        <title>TableServiceSpecial_sample1</title>
        <style>
        td {border:1px solid white}
        tr:nth-child(2n) {
            background: #E0FFFF;
           } 
        tr:nth-child(1) {
           background: #B0E0E6; 
           }
        </style>
    </head>

    <center>
    +++++++ Шапка таблицы +++++ ??
    <table class="tlist tgreen" cellspacing=0 border="1">
    <tr>
    <th>ID</th>
    <th>ФИО</th>
    <th>Страна</th>
    <th>Город</th> 
    <th>Профессия</th> 
    </tr>
    </center>
[end]


[item] ***** Cоздание строки таблицы - 1 записи
    <tr>
        <td>#id#</td> 
        <td>#F# #I# #O#</td> 
        <td>#country#</td>
        <td>#city#</td>
        <td>#profession#</td>
    </tr>
[end]


[SQL]  ***** Шаблон SQL запроса 
    select id, F, I, O, country, city, profession
    from test_persons
[end]

[report footer]
    </table>
    </body>
    </html>
[end]
