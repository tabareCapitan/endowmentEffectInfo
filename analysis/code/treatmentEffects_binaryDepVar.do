/*******************************************************************************
Project:        Expecting to get it: An Endowment Effect for Information

Authors:        TabareCapitan.com

Description:    Estimate treatment effects


Created: 20191229 | Last modified: 20200719
*******************************************************************************/
version 14.2

*** MACROS *********************************************************************

* VAR LISTS --------------------------------------------------------------------

#delimit ;

global DIFS_NOINFO
  "
  collegeDegree
  exp_cat
  riskPref
  beta
  healthStatus
  wishEatBetterOut
  calNeedsKnowledge
  prevExp
  "
  ;


global DIFS_INFO
  "
  age
  exp_cat
  hungry
  healthStatus
  exerciseImportant
  weightImportant
  calNeedsKnowledge
  prevExp
  chain
  "
  ;

#delimit cr

* RITEST PARAMETERS ------------------------------------------------------------

global REPS = 5000

global SEED = 0.5

*** HYPOTHETICAL CHOICES: NO INFO **********************************************

* LOAD DATA --------------------------------------------------------------------

use "$RUTA/results/endowmentEffectInfo.dta" if prime == 0, clear

* UNCONDITIONAL ESTIMATOR ------------------------------------------------------

reg  wantCalInfo endow // b = .188 pvalue = 0.41 (two-sided)

ritest endow _b[endow], right seed($SEED) nodots reps($REPS):                   ///
                                                    reg wantCalInfo endow
  // FEP: 0.0512 (two-sided)
  // FEP: 0.0308 (one-sided)

* GRAPH: ALL ESTIMATES ---------------------------------------------------------

// Run all possible regressions

gsreg wantCalInfo $DIFS_NOINFO , fixvar(endow) cmdoptions(robust) nocount       ///
                           replace   resultsdta("$RUTA/temp/data/difs_noInfo")


// Load data of all estimates

use "$RUTA/temp/data/difs_noInfo", clear


// Rename bars

gen stringUncond = "Unconditional"

rename v_1_b endow_c

rename v_1_t endow_t


// Calculate p-values

gen df = obs - nvar

gen endow_p1T = ttail(df,abs(endow_t))

gen endow_p2T = 2*ttail(df,abs(endow_t))

  order endow_p*, after(endow_t)


// Get frequencies

count

count if endow_c > 0

count if endow_c > 0.05

count if endow_c > 0.1

count if endow_c > 0.15

count if endow_c > 0.2

count if endow_p1T < 0.01

count if endow_p1T < 0.05

count if endow_p1T < 0.1


// PREPARE GRAPH

sum endow_c if nvar == 2  // unconditional estimate

local yline = `r(mean)'

sum endow_p1T if nvar == 2

local xline = `r(mean)'

#delimit ;

// CENTER GRAPH: SCATTER PLOT

twoway  (scatter endow_c endow_p1T,  msymbol(o) msize(small)  mcolor(gs10) )
        (scatter endow_c endow_p1T if nvar == 2,
        msymbol(s) msize(small)  mcolor(red) mlabel(stringUncond) mlabpos(6)  )
        ,
        xline(`xline', lcolor(red) lwidth(vthin) )
        yline(`yline', lcolor(red) lwidth(vthin) )
        legend(off)
        yscale(alt,)
        ylabel(0(0.05)0.25, ang(horizontal) )
        xscale(alt)
        xlabel(0.01 "0.01" 0.05 "0.05" 0.1 "0.1", grid gextend)
        xtitle("pvalue")
        ytitle("Treatment effect", orientation(rvertical))
        saving("$RUTA/temp/figures/middle.gph", replace);

// LEFT: HISTOGRAM OF COEFFICIENTS;

twoway  hist endow_c ,
        ytitle("Treatment effect")
        yline(`yline', lcolor(red) lwidth(vthin) )
        fraction
        xsca(alt reverse)
        horiz
        fxsize(25)
        xlabel( #3, ang(h))
        ylabel(0(0.05)0.25, ang(h))
        saving("$RUTA/temp/figures/left.gph", replace);


// BOTTOM: HISTOGRAM OF PVALUES;

twoway  histogram endow_p1T,
        xtitle("pvalue")
        xline(`xline', lcolor(red) lwidth(vthin) )
        fysize(25)
        fraction
        yscale(alt reverse)
        ylabel(0(0.07)0.21,nogrid ang(h))
        ytitle(,orientation(rvertical))
        xlabel(0.01 "0.01" 0.05 "0.05" 0.1 "0.1", grid gextend)
        saving("$RUTA/temp/figures/bottom.gph", replace);

// COMBINE ALL THREE GRAPHS

graph combine   "$RUTA/temp/figures/left.gph"
                "$RUTA/temp/figures/middle.gph"
                "$RUTA/temp/figures/bottom.gph"
                ,
                hole(3)
                imargin(0 0 0 0)
                graphregion(margin(l=22 r=22));

graph export "$RUTA/results/figures/hypotheticalChoices_noInfo.png",
                                    replace width(11000) height(8000);

#delimit cr

*** HYPOTHETICAL CHOICES: INFO *************************************************

* LOAD DATA --------------------------------------------------------------------

use "$RUTA/results/endowmentEffectInfo.dta" if prime == 1, clear

* UNCONDITIONAL ESTIMATOR ------------------------------------------------------

reg  wantCalInfo endow // b = .058 pvalue = 0.537 (two-sided)

ritest endow _b[endow], right seed($SEED) nodots reps($REPS):                   ///
                                                    reg wantCalInfo endow
  // FEP: 0.3388 (one-sided)

* GRAPH: ALL ESTIMATES ---------------------------------------------------------

// Run all possible regressions

gsreg wantCalInfo $DIFS_INFO , fixvar(endow) cmdoptions(robust) nocount         ///
                           replace   resultsdta("$RUTA/temp/data/difs_info")


// Load data of all estimates

use "$RUTA/temp/data/difs_info", clear

// Rename vars

gen stringUncond = "Unconditional"

rename v_1_b endow_c

rename v_1_t endow_t

// Calculate p-values

gen df = obs - nvar

gen endow_p1T = ttail(df,abs(endow_t))

gen endow_p2T = 2*ttail(df,abs(endow_t))

  order endow_p*, after(endow_t)

* Get frequencies

count

count if endow_c > 0

count if endow_c > 0.05

count if endow_c > 0.1

count if endow_c > 0.15

count if endow_c > 0.2


count if endow_p1T < 0.01

count if endow_p1T < 0.05

count if endow_p1T < 0.1

// PREP GRAPH

sum endow_c if nvar == 2  // unconditional estimate

local yline = `r(mean)'

sum endow_p1T if nvar == 2

local xline = `r(mean)'

#delimit ;

// CENTER GRAPH: SCATTER PLOT

twoway  (scatter endow_c endow_p1T,  msymbol(o) msize(small)  mcolor(gs10) )
        (scatter endow_c endow_p1T if nvar == 2,
        msymbol(s) msize(small)  mcolor(red) mlabel(stringUncond) mlabpos(7)  )
        ,
        xline(`xline', lcolor(red) lwidth(vthin) )
        yline(`yline', lcolor(red) lwidth(vthin) )
        legend(off)
        yscale(alt,)
        ylabel(0(0.05)0.25, ang(horizontal) )
        xscale(alt)
        xlabel(0.01 "0.01" 0.05 "0.05" 0.1 "0.1", grid gextend)
        xtitle("pvalue")
        ytitle("Treatment effect", orientation(rvertical))
        saving("$RUTA/temp/figures/middle.gph", replace);

// LEFT: HISTOGRAM OF COEFFICIENTS;

twoway  hist endow_c ,
        ytitle("Treatment effect")
        yline(`yline', lcolor(red) lwidth(vthin) )
        fraction
        xsca(alt reverse)
        horiz
        fxsize(25)
        xlabel( #3, ang(h))
        ylabel(0(0.05)0.25, ang(h))
        saving("$RUTA/temp/figures/left.gph", replace);


// BOTTOM: HISTOGRAM OF PVALUES;

twoway  histogram endow_p1T,
        xtitle("pvalue")
        xline(`xline', lcolor(red) lwidth(vthin) )
        fysize(25)
        fraction
        yscale(alt reverse)
        ylabel(0(0.07)0.21,nogrid ang(h))
        ytitle(,orientation(rvertical))
        xlabel(0.01 "0.01" 0.05 "0.05" 0.1 "0.1", grid gextend)
        saving("$RUTA/temp/figures/bottom.gph", replace);

// COMBINE ALL THREE GRAPHS

graph combine   "$RUTA/temp/figures/left.gph"
                "$RUTA/temp/figures/middle.gph"
                "$RUTA/temp/figures/bottom.gph"
                ,
                hole(3)
                imargin(0 0 0 0)
                graphregion(margin(l=22 r=22));

graph export "$RUTA/results/figures/hypotheticalChoices_info.png",
                                    replace width(11000) height(8000);

#delimit cr

*** END OF FILE ****************************************************************
********************************************************************************
