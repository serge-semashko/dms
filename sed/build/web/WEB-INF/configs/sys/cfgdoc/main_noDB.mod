sys/cfgdoc/main_noDB.cfg

[comments]
descr=A: Вывод структуры модулей и их описания
input=
output=HTML таблица папок и модулей
parents=dat/debugTools.dat, main.cfg
childs=sys/cfgdoc/table_noDB.cfg
testURL=?c=sys/cfgdoc/main_noDB
[end]

[description]
Начальный модуль вывода cfgDoc.<br>
Вызывает table_noDB для вывода списка папок и модулей,<br>
который, в свою очередь вызывает module_noDB для вывода информации о выбранном модуле
[end]

[parameters]
title=SED-cfgdoc
[end]

[report]
    $INCLUDE dat/common.dat[check login]
    $SET_PARAMETERS AR_SYS_ADMIN=1;
    $SET_PARAMETERS_SESSION AR_SYS_ADMIN=1; ??USER_ID=10794
    AR_SYS_ADMIN=#AR_SYS_ADMIN# ??
    $INCLUDE [report_]  ??AR_SYS_ADMIN=1
[end]


[head]
    $SET_PARAMETERS debug=off
    $INCLUDE dat/common.dat[head]
    <style type="text/css">
    body { color:##000; background-color: ##F0F0F0; padding:10px;}

    table.tlist {border:solid 1px 0080a0;}
    table.tlist .title a, .title a {background-color: ##1f697d; color:##e0f4ff; font-weight:normal; font-size:14pt; }
    table.tlist td {font-size: 9pt; border-bottom:solid 1px gray; }
    table.tlist .hasnocomments{ color:##f00000;}
    table.tblue tr.oddRow {background-color: #e0f4ff;}
    table.tblue tr.active {background-color: ##FFFFa0;}
    table.tblue tr.sel {background-color: ##FFF8b0;}
    tr {background-color: white ; color:##000406;}

    .title {float:left; padding:0 10px 0 10px; margin-top:10px; border:solid 1px ##0080a0; border-radius:4px; color:##e0f4ff; font-size:14pt; background-color: ##1f697d;}
    .desBlock {background-color:white; padding:10px; float:left; width:800px; margin-right:20px; border:solid 1px gray;}

    .hasnocomments{ color:##f00000;}
    td.dat {background-color:white;}

    ##moduleSrc {border:ridge 3px gray; height:500px; overflow:auto;
        font-family: monospace; white-space: nowrap; padding:10px; background-color: white;} 
    ##formData {padding:0 0 10px 0;}
    ##popupCont {padding:1px 3px 15px 3px; background-color:##c0c0c0;}

    ol li {margin:0 0 7px 0;}
    ul li {margin:3px 0 0 -5px;}
    </style></head>
[end]



[report_]
    $SET_PARAMETERS debug=off
    $INCLUDE dat/common.dat[head]
    <style type="text/css">
        body { color:##000; background-color: ##F0F0F0; padding:10px;}

        table.tlist {border:solid 1px 0080a0;}
        table.tlist .title a, .title a {background-color: ##1f697d; color:##e0f4ff; font-weight:normal; font-size:14pt; }
        table.tlist td {font-size: 9pt; border-bottom:none 1px gray; }
        table.tlist .hasnocomments{ color:##f00000;}
        table.tblue tr.oddRow {background-color: #e0f4ff;}
        table.tblue tr.active {background-color: ##FFFFa0;}
        table.tblue tr.sel {background-color: ##FFF8b0;}
        tr {background-color: white ; color:##000406;}

        .title {float:left; padding:0 10px 0 10px; margin-top:10px; border:solid 1px ##0080a0; border-radius:4px; color:##e0f4ff; font-size:14pt; background-color: ##1f697d;}
        .desBlock {background-color:white; padding:10px; max-width:98%; width_:800px; margin-right:20px; border:solid 1px gray;}

        td.dat {background-color:white;}
        .hasnocomments{ color:##f00000;}
        i.mod {color:##0000ff;}
        i.ajm {color:##008800;}
        i.cfg, i.dat {color:##A0A0A0;}
        ##moduleSrc {border:ridge 3px gray; float:left; max-width:60%; height:700px; overflow:auto;
            font-family: monospace; white-space: nowrap; padding:10px; background-color: white;} 
        ##formData {padding:0 0 10px 0;}
        ##dialog {max-width:80%;}
        ##popupCont {padding:1px 3px 15px 3px; background-color:##c0c0c0;}

        ol li {margin:0 0 7px 0;}
        ul li {margin:3px 0 0 -5px;}
    </style></head>

    <body>
        <a class="reload" href="?c=#c#&reload=y">reload</a> ??
        <table border=0 cellspacing=0><tr style="background-color: ##F0F0F0;" >
        <td id="dirList" style="width:40%"></td>
        <td id="moduleInfo" style="width:60%; padding-left:10px;"></td>
        </tr><table>
        $INCLUDE [popup div] 

<br><div style="float:left; background-color:white; padding:5px;">

    <i class='fa fa-cube' aria-hidden='true' style="color:##206090; font-size:11pt;"></i>.mod &nbsp;
    <i class='fa fa-cube' aria-hidden='true' style="color:##205080; font-size:11pt;"></i>.mod &nbsp;
        <i class='fa fa-cube mod' aria-hidden='true'></i>.mod &nbsp;
    <i class='fa fa-cube ajm' aria-hidden='true'></i>.ajm  &nbsp;
    <i class='fa fa-cube cfg' aria-hidden='true'></i>.cfg &nbsp;
    <i class='fa fa-file-o dat' aria-hidden='true'></i>.dat
</div><br><br>
        <script>
            AjaxCall('dirList', 'c=sys/cfgdoc/table_noDB&dir=#dir#');
        </script>
    </body></html>
[end]

[popup div]
============================= POP-UP DIV =============================== ??
    ----------------- Тень под диалогом --------------- ??
    <div id="overlay" class="dialog_overlay"></div>   

    ----------------- POP-UP диалог --------------- ??
    <div id="dialog" class="dialog">
    <div class="dialog_title right" >
    <div id="dialog_title" style="float:left;"></div>
    <div class="btn" onClick="HideDialog();" style="width:20px; height:15px; float:right;">
    <img src="#imgPath#close.png" width="16" height="14" border="0" >
    </div>
    <div style="clear:both;"></div>
    </div>
    <div id="popupCont"></div>
    </div>

    $INCLUDE dat/debugTools.dat[debug links] ??
[end]