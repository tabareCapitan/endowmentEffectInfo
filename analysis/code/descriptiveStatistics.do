/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  (LaTeX) Table with descriptive statistics

Created: 20200719 | Last modified: 20200719
*******************************************************************************/
version 14.2

*** LOAD DATA ******************************************************************

use "$RUTA/results/endowmentEffectInfo.dta", clear

*** LIST OF COVARIATES *********************************************************

#delimit ;

global COVS

 "
 female
 age
 collegeDegree
 exp_cat
 inc_cat
 bmi
 underWeight
 normal
 overWeight
 obese

 riskPref
 esc
 beta
 delta
 hungry

 healthStatus
 benefitEatHealthier
 wishEatBetterHome
 wishEatBetterOut

 healthImportant
 exerciseImportant
 weightImportant

 calNeedsKnowledge
 prevExp
 chain
 "
 ;

#delimit cr

*** GET SUMMARY STATISTICS *****************************************************

tabstat $COVS, columns(statistics) stats(n mean sd min max) format(%9.2g) save

*** SAVE STATS TO DTA **********************************************************

matrix m = r(StatTotal)'

// svmatf appends, so must ensure there is nothing there
cap erase "$RUTA/temp/data/matrix_descriptiveStats.dta"

svmatf , mat(m) fil("$RUTA/temp/data/matrix_descriptiveStats.dta")

*** CREATE LATEX TABLE *********************************************************

use "$RUTA/temp/data/matrix_descriptiveStats.dta", clear

* ROUND TO TWO DECIMAL POINTS --------------------------------------------------

foreach cov of varlist mean sd min max{

    replace `cov' = round(`cov', 0.01)
}

* HEADER -----------------------------------------------------------------------

label var N     "N"
label var mean  "Mean"
label var sd    "Std. Dev."
label var min   "Min."
label var max   "Max."

* SIDE BAR ---------------------------------------------------------------------

order row

rename row var

replace var = "Female"           if var == "female"
replace var = "Age"              if var == "age"
replace var = "College degree"   if var == "collegeDegree"
replace var = "Expenses level"   if var == "exp_cat"
replace var = "Income level"     if var == "inc_cat"
replace var = "Body-Mass Index"  if var == "bmi"
replace var = "Underweight"      if var == "underWeight"
replace var = "Proper weight"    if var == "normal"
replace var = "Overweight"       if var == "overWeight"
replace var = "Obese"            if var == "obese"

replace var = "Risk preferences"              if var == "riskPref"
replace var = "Food self-control"             if var == "esc"
replace var = "Present-bias (\(\beta\))"      if var == "beta"
replace var = "Discount factor (\(\delta\))"  if var == "delta"
replace var = "Hunger level"                  if var == "hungry"

replace var = "Health assessment"                                                ///
    if var == "healthStatus"
replace var = "Would benefit from eating healthier"                             ///
    if var == "benefitEatHealthier"
replace var = "Wish could eat healthier at home"                                ///
    if var == "wishEatBetterHome"
replace var = "Wish could eat healthier out"                                    ///
    if var == "wishEatBetterOut"
replace var = "Importance of eating healthy food"                               ///
    if var == "healthImportant"
replace var = "Importance of exercising regularly"                              ///
    if var == "exerciseImportant"
replace var = "Importance of healthy body weight"                               ///
    if var == "weightImportant"

replace var = "Knows calorie needs"                                             ///
    if var == "calNeedsKnowledge"
replace var = "Experience with calorie information"                             ///
    if var == "prevExp"
replace var = "Frequency visits to chain restaurants"                           ///
    if var == "chain"

* EXPORT TO TEX ----------------------------------------------------------------

texsave using "$RUTA/results/tables/tab_descriptiveStatistics.tex",  replace    ///
                                                                                ///
        title("Descriptive statistics")                                         ///
        marker(tab:descriptiveStatistics)                                       ///
        varlabels                                                               ///
        hlines(10 15 22 )                                                       ///
        location(h)                                                             ///
        frag

*** END OF FILE ****************************************************************
********************************************************************************
