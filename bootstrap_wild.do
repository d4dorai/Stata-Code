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


clear

log using $log\bootstrap_wild.log, replace



set seed 365476247 

cap prog drop runme 
prog def runme 

/* local hypothesis = `1' */ 
tempfile main bootsave 

clear
cd $data
use enroll_B2
drop if pilot == 1
drop if STATNAME == "KERALA"


di 
qui xi: reg `2' mdm public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public , cluster(statcd) 
global mainbeta = _b[mdm] 
global maint = (_b[mdm] /* -  `hypothesis' */) / _se[mdm] 
predict epshat , resid
predict yhat , xb 

di "main beta"

/* also generate "impose the null hypothesis" yhat and residual  BUT we DO NOT impose the hypothesis!!!*/
gen temp_y = `2' /* - mdm * `hypothesis' */
display "1"
qui xi: reg temp_y public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public 
display "2"
predict epshat_imposed , resid 
display "3"
predict yhat_imposed , xb 
display "4"
qui replace yhat_imposed = yhat_imposed + /* mdm * `hypothesis' */
 
display "generated the null, yhat and residual"


 sort statcd  /* self */
display "sorted"
qui save `main' , replace 
display "saved"

qui by statcd: keep if _n == 1 
qui summ 
global numstatcds = r(N) 

display "numbered"

cap erase `bootsave' 
qui postfile bskeep  t_wild using `bootsave' , replace 

forvalues b = 1/$bootreps { 

/* first do wild bootstrap */
use `main', replace 
qui by statcd: gen temp = uniform() 
qui by statcd: gen pos = (temp[1] < .5) 

qui gen wildresid = epshat_imposed * (2*pos - 1) 
qui gen wildy = yhat_imposed + wildresid 
qui xi: reg wildy mdm public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public  , cluster(statcd) 
local bst_wild = (_b[mdm] - /*`hypothesis'*/ $mainbeta) / _se[mdm] 
local 


/* next do nonparametric bootstrap */
/*
bsample , cluster(statcd) idcluster(newstatcd) 
qui xi: reg `2' public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public mdm , cluster(newstatcd) 
local bsbeta = _b[mdm] 
local bst = (_b[mdm] - $mainbeta) / _se[mdm] 
*/

post bskeep /*(`bsbeta') (`bst')*/ (`bst_wild') 
}  /* end of bootstrap reps */
 postclose bskeep 

 /*
qui drop _all 
qui set obs 1 
qui gen t_np = $maint 

qui gen t_wild = $maint 
qui append using `bootsave' 

qui gen n = . 
foreach stat in t_np  t_wild { 
qui summ `stat' 
local bign = r(N) 
sort `stat' 
qui replace n = _n 
qui summ n if abs(`stat' - $maint) < .000001 
local myp = r(mean) / `bign' 
global pctile_`stat' = 2 * min(`myp',(1-`myp')) 
} 

version 9

global mainp = norm($maint) 
global pctile_main = 2 * min($mainp,(1-$mainp)) 

local myfmt = "%7.5f" 



di 
di "Number BS reps = $bootreps, Null hypothesis = `hypothesis' " 

display "Main beta" _column(13) "main T"	_column(22) "Main %le" _column(33) "NP BS %le" _column(44) "fixX %le" _column(54) "wild %le" 

di 	%6.3f $mainbeta _column(13) %6.3f $maint  _column(23) `myfmt' $pctile_main _column(34) `myfmt' $pctile_t_np  _column(44) " " _column(55) `myfmt' $pctile_t_wild 
*/

end 

global bootreps = 3
runme lnC1


global bootreps = 999
/* global bootreps = 10 */

/* for lnC1 */
/* - 2 s.e. */
runme .067 lnC1  
/*  - 3 s.e. */
runme .02 lnC1 
/* - 1 s.e. */
runme .118 lnC1 

/* lnprimary */ 
runme .01 lnprimary


/*lnC2 */
runme .016 lnC2


/*lnC3 */
runme -0.016 lnC3

/* lnC4 */
runme -0.021 lnC4

/* lnC5 */
runme .037 lnC5



log close 

