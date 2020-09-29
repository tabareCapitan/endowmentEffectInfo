/*******************************************************************************
Project:      Reference-Dependent Preferences for Information

Author:       TabareCapitan.com

Description:  WTA figures for Klaas' presentation

Created: 20200109 | Last modified: 20200109
*******************************************************************************/
version 14.2

*** SET UP *********************************************************************

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

reg  valinfoim endow // b = .46 pvalue = 0.22 (two-sided)


ritest endow _b[endow], right seed($SEED) nodots reps($REPS):                   ///
                                                    reg valinfoim endow
  // FEP: 0.11 (one-sided)

* GRAPH: ALL ESTIMATES ---------------------------------------------------------

// Run all possible regressions

gsreg valinfoim $DIFS_NOINFO , fixvar(endow) cmdoptions(robust) nocount         ///
                         replace resultsdta("$RUTA/temp/data/difs_noinfoValue")


// Load data of all estimates

use "$RUTA/temp/data/difs_noinfoValue", clear


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

count if endow_c > 0.1

count if endow_c > 0.15

count if endow_c > 0.25

count if endow_c > 0.5

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
        ylabel(0(0.25)1, ang(horizontal) )
        xscale(alt)
        xlabel(0.01 "0.01" 0.05 "0.05" 0.1 "0.1", grid gextend)
        xtitle("pvalue")
        ytitle("Treatment effect", orientation(rvertical))
        saving("$RUTA/temp/figures/middle.dta", replace);

// LEFT: HISTOGRAM OF COEFFICIENTS;

twoway  hist endow_c ,
        ytitle("Treatment effect")
        yline(`yline', lcolor(red) lwidth(vthin) )
        fraction
        xsca(alt reverse)
        horiz
        fxsize(25)
        xlabel( #3, ang(h))
        ylabel(0(0.25)1, ang(h))
        saving("$RUTA/temp/figures/left.dta", replace);


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
        saving("$RUTA/temp/figures/bottom.dta", replace);

// COMBINE ALL THREE GRAPHS

graph combine   "$RUTA/temp/figures/left.dta"
                "$RUTA/temp/figures/middle.dta"
                "$RUTA/temp/figures/bottom.dta"
                ,
                hole(3)
                imargin(0 0 0 0)
                graphregion(margin(l=22 r=22));

graph export "$RUTA/results/figures/hypotheticalChoices_NoInfoValue.png",
                                    replace width(11000) height(8000);

#delimit cr


*** HYPOTHETICAL CHOICES: INFO *************************************************

* LOAD DATA --------------------------------------------------------------------

use "$RUTA/results/endowmentEffectInfo.dta" if prime == 1, clear

* UNCONDITIONAL ESTIMATOR ------------------------------------------------------

reg  valinfoim endow // b = .262 pvalue = 0.408 (two-sided)

ritest endow _b[endow], right seed($SEED) nodots reps($REPS):                   ///
                                                    reg valinfoim endow
  // FEP: 0.213 (one-sided)

* GRAPH: ALL ESTIMATES ---------------------------------------------------------

// Run all possible regressions

gsreg valinfoim $DIFS_INFO , fixvar(endow) cmdoptions(robust) nocount           ///
                          replace resultsdta("$RUTA/temp/data/difs_infoValue")


// Load data of all estimates

use "$RUTA/temp/data/difs_infoValue", clear

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

count if endow_c > 0.1

count if endow_c > 0.2

count if endow_c > 0.25

count if endow_c > 0.5


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
        ylabel(0(0.25)1, ang(horizontal) )
        xscale(alt)
        xlabel(0.01 "0.01" 0.05 "0.05" 0.1 "0.1", grid gextend)
        xtitle("pvalue")
        ytitle("Treatment effect", orientation(rvertical))
        saving("$RUTA/temp/figures/middle.dta", replace);

// LEFT: HISTOGRAM OF COEFFICIENTS;

twoway  hist endow_c ,
        ytitle("Treatment effect")
        yline(`yline', lcolor(red) lwidth(vthin) )
        fraction
        xsca(alt reverse)
        horiz
        fxsize(25)
        xlabel( #3, ang(h))
        ylabel(0(0.25)1, ang(h))
        saving("$RUTA/temp/figures/left.dta", replace);


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
        saving("$RUTA/temp/figures/bottom.dta", replace);

// COMBINE ALL THREE GRAPHS

graph combine   "$RUTA/temp/figures/left.dta"
                "$RUTA/temp/figures/middle.dta"
                "$RUTA/temp/figures/bottom.dta"
                ,
                hole(3)
                imargin(0 0 0 0)
                graphregion(margin(l=22 r=22));

graph export "$RUTA/results/figures/hypotheticalChoices_InfoValueWTA.png",
                                    replace width(11000) height(8000);

#delimit cr


*** END OF FILE ****************************************************************
********************************************************************************
