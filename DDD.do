capture log close
capture macro drop _all
capture program drop _all
capture clear matrix
set more off
set matsize 800
set mem 10000m



/****declare globals*********/
global prg D:\Research-Server\dise\prg
global temp D:\Research-Server\dise\temp
global data D:\Research-Server\dise\data
global raw D:\Research-Server\dise\raw
global out D:\Research-Server\dise\out
global log D:\Research-Server\dise\log


log using $log\main_tg6_DDD.log, replace


program DDDcls

quietly: xi: reg lnprimary`1' mdm public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public , vce(cluster statcd)
est store modelp


quietly: xi: reg lnC1`1' mdm public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public , vce(cluster statcd)
est store model1



quietly: xi: reg lnC2`1' mdm public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public , vce(cluster statcd)
est store model2



quietly: xi: reg lnC3`1' mdm public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public , vce(cluster statcd)
est store model3



quietly: xi: reg lnC4`1' mdm public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public , vce(cluster statcd)
est store model4



quietly: xi: reg lnC5`1' mdm public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public , vce(cluster statcd)
est store model5



set linesize 255
esttab  model1 model2 model3 model4 model5 modelp,  b(%12.3f) se(%12.3f) star(* 0.10 ** 0.05 *** 0.01) ar2(%3.2f) mtitles("Grade 1" "Grade 2"  "Grade 3" "Grade 4" "Grade 5" "Primary" ) title(Triple Difference `1' Logs) booktabs noconstant

end


clear
cd $data
use main_tg

DDDcls
