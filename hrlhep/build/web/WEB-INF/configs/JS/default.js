// Заполняет массив sqlColNames названиями столбцов в выборке
function getColNames(resultSet) {
    var metaData = resultSet.getMetaData();
    var numCols = metaData.getColumnCount();
    var sqlColNames = [];
    for (var i = 0; i < numCols; i++) {
        sqlColNames.push(metaData.getColumnLabel(i + 1));
    }
    return sqlColNames;
}
;
// Делает выборку из данных. SQl берется из sqlSection 
// sqlSection будет парсится как в $GETDATA
// Для каждой строки быборки заполняет строку параметров значениями и вызывает секцию execSection
// Полный аналог обработки секции [SQL] секцией [ITEM] в TableServiceSpecial

function loopSQL(sqlSection, execSection) {
    $LOG(2,"loopSQL sqlSection = " + sqlSection + " execSection"+execSection +"\n", sectionLines, out);
    var sql = BT.getCustomSectionAsString(sqlSection);
    if (sql.length ===0 ) {
       BT.WriteLog(2 , "<font color=red> loopSQL:" + sqlSection + ": SECTION NOT FOUND OR EMPTY</font>");
       return;
    } 
    var r = dbUtil.getResults(sql);
    if (typeof r == "undefined") {
        return;
    }
    if (r == null) {
        return;
    }
    var headers = getColNames(r);
    var sumstr = "";
    while (r.next()) {
        for (i = 0; i < headers.length; i++) {
            var val = r.getString(i + 1);
            BT.addParameter(headers[i], val);
            sumstr += headers[i] + " = [" + val + "] ";
        }
        $LOG(2,"<br>Current row= " + sumstr + "\n", sectionLines, out);
        BT.getCustomSection("",execSection,out);
    }
    dbUtil.closeResultSet(r);
}
;
// Возвращает  параметр  по имени namr
function prm(name){
    return BT.getParameter(null,null,name);
}
// Ecnfyfdkbdftn   параметр  по имени namr
function setPrm(name,val){
    return BT.addParameter(name,val);
}
// исполняется аналогично $INCLUDE 
function $INCLUDE(sectionName) {
    BT._$INCLUDE("$INCLUDE "+sectionName,sectionLines,out);
}
function $GETDATA(sectionName) {
    BT._$GETDATA("$GETDATA "+sectionName,sectionLines,out);
}
function $LOG(lvl,msg) {
     BT.WriteLog(lvl,msg);
}



