clear


use "C:\Users\thomas\Documents\Ensae\AEQV\data.dta"

gen age_2 = age*age
gen lhhninc = log(hhninc)

local y hsat 
local x lhhninc age age_2 hhkids married working handdum educ
local id id 


marksample touse
markout `touse' `y' `x' `id'



qui sum `y' if `touse'
local ymax = r(max)
tempvar esample
gen `esample' = 0
tempname BMAT
forvalues i = 2(1)`ymax' {
	
	tempvar y`i'
	qui gen `y`i'' = `y' >= `i' if `touse'
	qui clogit `y`i'' `x' if `touse', group(`id')
	qui replace `esample' = 1 if e(sample)
	estimates store `y`i''
	local suest `suest' `y`i''
	capture matrix `BMAT' = `BMAT', e(b)
	if (_rc != 0) matrix `BMAT' = e(b)
}
qui suest `suest'


set matsize 800, permanently


tempname VMAT A B COV
local k : word count `x'
matrix `VMAT' = e(V)


matrix `A' = J((`ymax'-1),1,1)#I(`k')



matrix `B' = (invsym(`A''*invsym(`VMAT')*`A')*`A''*invsym(`VMAT')*`BMAT'')'
matrix `COV' = invsym(`A''*invsym(`VMAT')*`A')


matrix colnames `B' = `x'
matrix coleq `B' = :
matrix colnames `COV' = `x'
matrix coleq `COV' = :
matrix rownames `COV' = `x'
matrix roweq `COV' = :
qui cou if `esample'
local obs = r(N)
ereturn post `B' `COV', depname(`y') obs(`obs') esample(`esample')
ereturn display


tempvar last
bysort `id': gen `last' = _n==_N if e(sample)
cou if `last'==1
