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


log using $log\placebolaw_5.log, replace

/* Generate placebo laws to see the power of clustering s.e. at the state level */

clear
cd $data
use enroll_B2
capture drop tt
capture drop mdmpseudo
gen tt = t - 1
gen mdmpseudo = 0
replace mdmpseudo = . if public == .
save enroll_B2, replace

capture program drop placebolaw 

program placebolaw, rclass


/*define the placebo time of implementation for each state */

capture drop mdmpseudo
gen mdmpseudo = 0
replace mdmpseudo = . if public == .

scalar define meanps = 0

while meanps == 0 {
foreach statnr of numlist 2 5 6 8 9 10 18 21 22 23 24 27 28 29 33 {
capture scalar drop m`statnr'
scalar define m`statnr' = 1+int((4-1+1)*runiform())
replace mdmpseudo = 1 if statcd == `statnr' & tt >= m`statnr' & public == 1
}

/*check if there is some variation in mdmpseudo (not that all states have just 0) */

sum mdmpseudo if public == 1
scalar define meanps = r(mean)
}

quietly xi: reg lnC1 mdmpseudo public i.t i.statcd i.t*i.statcd i.t*public i.statcd*public , vce(cluster statcd)
test mdmpseudo = 0
return scalar reject = (r(p) < 0.05)  /* 5 percent confidence interval */
return scalar beta_t = _b[mdmpseudo]
return scalar se_t = _se[mdmpseudo]
/*
return scalar reject = (t_stat < -1.96 | t_stat > 1.96)
*/
end

global replications = 1000

clear
cd $data
use enroll_B2
drop if pilot == 1
drop if STATNAME == "KERALA"

set seed 10101

simulate rejectf = r(reject) betaf = r(beta_t) sef = r(se_t), reps($replications) : placebolaw

cd $data
save placebolaw, replace

quietly sum rejectf
scalar reject_procent = r(sum) / $replications

di reject_procent

log close
