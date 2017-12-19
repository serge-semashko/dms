/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var charts = {};
var Chart1;
function createChart(divId) {
    debugger;
    Chart1 = AmCharts.makeChart(divId, {
        "type": "serial",
        "theme": "light",
        "legend": {
            align: "right",
            valueWidth: 0,
            spacing: 10,
            markerSize: 14,
            fontSize: 12,
            //            "useGraphSettings": true
        },
        "dataProvider": chartData1,
        "synchronizeGrid": true,
        "graphs": graphs1[0],
        //        "chartScrollbar": {},
        "chartCursor": {
            "cursorPosition": "mouse"
        },
        "valueScrollbar": {
            "oppositeAxis": false,
            "offset": 50,
            "scrollbarHeight": 35
        },

        "categoryField": "time",
        "categoryAxis": {
            gridCount: 6,
            labelFrequency: 1,
            equalSpacing: true,
            "axisColor": "#DADADA",
            "minorGridEnabled": false
        },
        "export": {
            "enabled": true,
            "position": "top-right"
        }
    });
}




