******************* Linear Effect *************

log using "$logs\phd2_maintable.log", replace


quietly xi: probit evertried_setup_bus fract_religion_psu    $indivcontrols   $psucontrols i.country   [pweight = weight_2],  vce(cluster country)  
estadd margins, dydx(*)
eststo model5

 quietly xi: probit suc_setup_bus fract_religion_psu    $indivcontrols borrowsucyes borrowsucno   $psucontrols i.country   [pweight = weight_2],  vce(cluster country)  
estadd margins, dydx(*)
eststo model6

 quietly xi: probit evertried_setup_bus fract_religion_psu    $indivcontrols    i.country   [pweight = weight_2],  vce(cluster country)  
estadd margins, dydx(*)
eststo model3


 quietly xi: probit suc_setup_bus fract_religion_psu    $indivcontrols borrowsucyes borrowsucno   i.country   [pweight = weight_2],  vce(cluster country)  
estadd margins, dydx(*)
eststo model4


 quietly xi: probit evertried_setup_bus fract_religion_psu       i.country   [pweight = weight_2],  vce(cluster country)  
estadd margins, dydx(*)
eststo model1

 quietly  xi: probit suc_setup_bus fract_religion_psu      i.country   [pweight = weight_2],  vce(cluster country)  
estadd margins, dydx(*)
eststo model2

 


set linesize 255
esttab model1  model3  model5  ,  cells( "margins_b(fmt(2)star)" " margins_se(fmt(2)par)" ) nocons /*
  */  label stats(N r2_p ll, fmt(0 2)  labels(`"Obs."' `"Pseudo \(R^{2}\)"' `"Log Likelihood"')) /* 
  */   star(* 0.10 ** 0.05 *** 0.01) drop( _cons *country* )  title(Main Table: Trial) booktabs
  
set linesize 255
esttab model2 model4  model6  ,  cells(" margins_b(fmt(2)star)" " margins_se(fmt(2)par)" ) nocons /*
  */  label stats(N r2_p ll, fmt(0 2)  labels(`"Obs."' `"Pseudo \(R^{2}\)"' `"Log Likelihood"')) /* 
  */   star(* 0.10 ** 0.05 *** 0.01) drop( _cons *country* )  title(Main Table: Startup) booktabs
  
  /* 
  mtitles("Trial" "Startup" "Trial" "Startup" "Trial" "Startup" ) 
  */


capture eststo clear 

log close





*************************** Interaction terms graphs
**plot the marginal effect of the interaction term at each unit of diversity
xi: probit evertried_setup_bus fract_religion_psu  c.fract_religion_psu#help_weak    $indivcontrols   $psucontrols i.country   [pweight = weight_2],  vce(cluster country)  

margins, dydx(help_weak) at(fract_religion_psu = (0 .1 .2 .3 .4 .5 .6 .7)) vsquish
marginsplot, yline(0) level(90) title("") ytitle("Effects on Pr(Trial)") 
graph save "$graphs\fract_religion_weak", replace


xi: probit evertried_setup_bus fract_religion_psu  c.fract_religion_psu#internal    $indivcontrols   $psucontrols i.country   [pweight = weight_2],  vce(cluster country)  

margins, dydx(internal) at(fract_religion_psu = (0 .1 .2 .3 .4 .5 .6 .7)) vsquish
marginsplot, yline(0) level(90) title("") ytitle("Effects on Pr(Trial)") 
graph save "$graphs\fract_religion_internal", replace



*************** Heckman Selection Model
 
  xi: heckprob suc_setup_bus  fract_religion_psu $indivcontrols borrowsucyes borrowsucno $psucontrols i.country   [pweight = weight_2],  /* 
*/  select( evertried_setup_bus = fract_religion_psu  pref_selfemp  $indivcontrols $psucontrols i.country   )  difficult vce(cluster country) 
est store model9
