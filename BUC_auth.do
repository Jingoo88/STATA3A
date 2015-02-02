ivar is the individual identier,
yvar is the ordered dependent variable, and
xvars is the list of explanatory variables.
capture program drop feologit_buc
program feologit_buc, eclass
version 10
gettoken gid 0: 0
gettoken y x: 0
tempvar iid id cid gidcid dk
qui sum `y'
local lk= r(min)
local hk= r(max)
bys `gid': gen `iid'=_n
gen long `id'=`gid'*100+`iid'
expand `=`hk'-`lk''
bys `id': gen `cid'=_n
qui gen long `gidcid'= `gid'*100+`cid'
qui gen `dk'= `y'>=`cid'+1
clogit `dk' `x', group(`gidcid') cluster(`gid')
end
feologit_buc ivar yvar xvars
21
