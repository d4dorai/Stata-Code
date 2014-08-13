/* sample of public and private schools, matching between private and public schools, stratified by state */
cd $data

/* match on 2002 varibales */
use main_tg

keep if public != .

keep if t == 2



program matchstate1
clear
cd $data
use main_tg
keep if public != .
keep if t == 2


keep if STATNAME == "`1' `2'"

/* matching only on the common support */
psmatch2 public  CLROOMS othrooms primtch othstaff BLACKBOARD playground electricity water gtoilet ctoilet box vernacular primary , noreplacement common nowarnings  ate

drop if _n1 == .  /* keep only matched sample */

keep SCHCD 
gen matched = 1

save `1' , replace

end
