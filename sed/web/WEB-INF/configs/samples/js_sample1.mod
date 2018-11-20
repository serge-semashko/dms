samples/js_sample1.cfg

[comments]
testURL=?c=samples/js_sample1
author:Semashko S
[end]

[description]
    Пример использования javascript на стороне сервера
    <p>Выводит таблице </p>
        В javascript доступны объекты : 
        rm  
        BT
        dbUtil
        out
        sectionLines - sectionLines обрабатываемой секции
    
[end]

[parameters]
    service=dubna.walt.service.Service
    tableCfg=table_no
[end]

[head]
    <head>
    <meta charset="utf-8">
    <title>js_sample1</title>
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
[end]
tab_personal_table.cfg

[comments]
    descr=Таб "Шкала повышения зарплаты"
    input=none
    output=HTML таблица объектов
    childs=
    testURL=?c=samples/js_sample1
    author:Semashko
[end]

[parameters]
    service=dubna.walt.service.Service
    LOG=ON 
    tableCfg=table_no
[end]

[report]
        Использование javascript 
        $JS out.println("UID:"+BT.parseString("#USER_ID#"));
        $JS BT._$PRINT(" TEST $PRINT ", sectionLines, out);
        $JS BT._$LOG(" TEST $LOG ", sectionLines, out);
        $JS_BEGIN
            //Определяем функцию. Переменные и ункции сохряняются для этого экземпляра basciTuner
            function addCell(celltxt, colspan   , rowspan ,cellType){
                
                if(typeof cellType == "undefined")
                  var sectName = "simple cell";
                else
                  var sectName = cellType+" cell";
                if(typeof colspan == "undefined")
                  var colspan = 1;
                if(typeof row == "undefined")
                  var rowspan = 1;

                BT.addParameter("colspan",colspan);
                BT.addParameter("rowspan",rowspan);
                BT.addParameter("txt",celltxt);
                
                BT.getCustomSection("",sectName,out);
//                out.println("sectname = "+sectName+" ;")

            }
        $JS_END
    <table class="tlist tgreen" cellspacing=0" border=1>
    
    <tr>

        

        $JS_BEGIN
            r = dbUtil.getResults("select  cat, base, step, id from samples_js order by id");
            BT.WriteLog(1, "select  cat, base, step, id from samples_js order by id");
BT._$LOG ("HERE!", null, null);
            // r - объект recordset java - все его паблик методы доступны как и для всех объектов java
            var cats = [];
            var bases = [];
            var steps = [];
            // Заносим в массивы cats: названия категорий, bases: базовая ставка для категории, steps: шаг повышения с уровнем
            while (r.next()) {
                cats.push(r.getString(1));
                bases.push(r.getString(2));
                steps.push(r.getString(3));
           }
           addCell("");
            cats.forEach(function(item, i, arr) {
                addCell(item,6,1,"head");
                addCell(" " ,1,1,"head");
            });
            BT.getCustomSection("","new row",out);
            addCell("Уровень");
            cats.forEach(function(item, i, arr) {
                BT.addParameter("BaseStep",bases[i]+"<br>"+steps[i]);
                BT.getCustomSection("","category header",out);
                addCell(" " ,1,1,"head");
            });
            for (var lvl=0;lvl<16;lvl++){
               BT.getCustomSection("","new row",out);
               addCell(lvl+1);
                for (var grade = 0;grade<bases.length;grade++) {
                    
                     addCell(+bases[grade]+steps[grade]*lvl);
                     addCell("");
//                     addCell(""); 
  //                   addCell("");  
                     addCell("");
                     addCell("");
                     addCell("");
                    
                }
            }

        $JS_END

    </tr>
    
[end]

[head cell]
        <th colspan=#colspan# rowspan=#rowspan#>
            #txt#
        </th>
[end]
[simple cell]
        <td colspan=#colspan# rowspan=#rowspan#>
            #txt#
        </td>
[end]

[category header]
    <th>
       Обычный #BaseStep#
    </td>
    <th>
       Надбавка<br>за<br>РВУ 
    </th>
    <th>
       Надбавка<br>за<br>степень
    </th>
    <th>
       Квалификация<br>адм. деятельность<br>надбавка до
    </th>
    <th>
       Занятый в<br>выделенном<br>проекте<br>надбавка до
    </th>
    <th>
       Итого<br>максимум
    </th>


[end]

[new row]
        </tr><tr>
[end]


        <th colspawn=6>
            Стажеры и приравненные					
        </th>
        <th colspawn=6>
            МНС и приравненные					
        </th>
        <th colspawn=6>
            НС и приравненные					
        </th>
        <th colspawn=6>
            ВНС и приравненные					
        </th>
        <th colspawn=6>
            ВНС и приравненные					
        </th>
        <th colspawn=6>
            Нач. самостоятельного сектора + приравненные					
        </th>
        <th colspawn=6>
            ГНС + нач. отдела+ приравненные					
        </th>
        <th colspawn=6>
            Нач. отделения + приравненные					
        </th>
        <th colspawn=6>
            Зам. дир. по науке+ приравненные					
        </th>
        <th colspawn=6>
            Директора Лабораторий и приравненные					
        </th>


[head cell]
        <th colspawn=6>
            alert("#txt#");
            #txt#
        </th>
[end]

[fill scale values]
    $JS_BEGIN
        r = dbUtil.getResults("select  cat, base, step, srt from grade_scale order by srt");
        var wcats = [];
        var bases = [];
        var steps = [];
        if (r.next()) {
            acats.push(r.getString(2));
            bases.push(r.getString(2));
            steps.push(r.getString(3));
       } else {
           out.println("end")
       };
    $JS_END

[end]

[item]
[end]

[sql]
    
[end]

[report footer]
</tr>
[end]

