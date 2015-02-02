clear

program bucologit
	version 13.0
	syntax varlist [if] [in], Id(varname)
	preserve
	marksample touse
	markout `touse' `id'
	gettoken yraw x : varlist
	tempvar y
	qui egen int `y' = group(`yraw')
	qui keep `y' `x' `id' `touse'
	qui keep if `touse'
	qui sum `y'
	local ymax = r(max)
	forvalues i = 2(1)`ymax' {
	qui gen byte `yraw'`i' = `y' >= `i'
	}
	drop `y'
	tempvar n cut newid
	qui gen long `n' = _n
	qui reshape long `yraw', i(`n') j(`cut')
	qui egen long `newid' = group(`id' `cut')
	sort `newid'
	clogit `yraw' `x', group(`newid') cluster(`id')
	restore
	end
exit



use "C:\Users\thomas\Documents\Ensae\AEQV\data.dta"

gen age_2 = age*age
gen lhhninc = log(hhninc)

local y hsat 
local x lhhninc age age_2 hhkids married working handdum educ
local id id 

*Run BUC model using the bucologitcommand
bucologit `y' `x', i(`id')
*Note: the i() option is equivalent to group() in the clogitsyntax
*Compare results with standard ordered logit
ologit `y' `x'

