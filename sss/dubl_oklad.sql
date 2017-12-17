select * from oklad where tab_n in 
(select tabn from 
(select fio, oklad.tab_n tabn, count(oklad.tab_n) as vvv from oklad  join sotrudniki sotr on sotr.tab_n = oklad.tab_n 
group by oklad.tab_n) str
where str.vvv >1)
order by tab_n;
#select * from 
