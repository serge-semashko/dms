function aaa () {
    c = 1 + 5;
    return "aaaa"; 
};
var prm = {
    set: function (name, value) {
      BT.addParameter(name, value);
    },
    set_session: function (name, value) {
      BT.setParameterSession(name, value);
    },
    set_global: function (name, value) {
      rm.setParam(name, value, true);
    },
    get: function (name) {
      return BT.getParameter(name);
    }
};
function sql(reqtxt){
    return dbUtil.getResults(reqtxt);
}
function sql2prm(reqtxt){
    return dbUtil.getResults(reqtxt);
}
function sql2section(reqtxt,sectname){
    var r =sql(reqtxt);
       
}



