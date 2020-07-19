/*******************************************************************************
              | DEPRECATED -> Use identifyLargeDifferences.do |
********************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  (Excel) Tables and distribution graphs to identify large
              differences in covariates between groups

Created: 20190206 | Last modified: 20200719
*******************************************************************************/
version 14.2

run "$RUTA/code/programs/balanceMeasures.ado"

*** LOAD DATA ******************************************************************

use "$RUTA/results/endowmentEffectInfo.dta", clear

*** MACROS: ********************************************************************

* FORMAT: TABLES ---------------------------------------------------------------

global HEADER "bold vcenter hcenter font(timesnewroman, 12)"

global SIDE_VAR "nobold italic right font(timesnewroman, 12)"

global DATA "nobold vcenter hcenter font(timesnewroman, 12)"

global T_BORDER "border(top, thick black)"

* FORMAT: GRAPHS ---------------------------------------------------------------

global SCATTER "sort msize(small) msymbol(circle_hollow) mlcolor(black) jitter(5)"

global HIST = "discrete fraction"

* LISTS: COVARIATES ------------------------------------------------------------

#delimit ;

global COV_DISC

  "
  hungry
  female
  collegeDegree
  exp_cat
  inc_cat
  weightDesc

  riskPref

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

global COV_CONT "age bmi esc beta delta"

global COV "$COV_DISC $COV_CONT"

* OTHER ------------------------------------------------------------------------

global BALANCE = "c_mean c_sd t_mean t_sd"

*** TABLE: BALANCE BETWEEN EXPERIMENTS *****************************************

putexcel set "$RUTA/results/tables/covBalanceExp.xlsx", sheet(results) replace

* HEADER -----------------------------------------------------------------------

#delimit ;

putexcel  B1:C1 = "Hypothetical: No info"
          D1:E1 = "Hypothetica: Info"
          F1:F3 = "Normalized differences"
          G1:G3 = "Log ratio of S.D."
          ,
          $HEADER merge txtwrap;

putexcel  A3 = "Variable"
          B3 = "Mean"
          C3 = "Std. dev."
          D3 = "Mean"
          E3 = "Std. dev."
          ,
          $HEADER;

#delimit cr

* ADD # OF OBSERVATIONS --------------------------------------------------------

count if prime == 0

  putexcel B2:C2 = `r(N)' , merge $DATA

count if prime == 1

  putexcel D2:E2 = `r(N)', merge $DATA

* ADD MEANS AND SDs ------------------------------------------------------------

local row = 4

foreach cov of varlist $COV {

  putexcel A`row' = "`cov'", $SIDE_VAR

  sum `cov' if prime == 0

    putexcel B`row' = `r(mean)', $DATA

    putexcel C`row' = `r(sd)', $DATA


  sum `cov' if prime == 1

    putexcel D`row' = `r(mean)', $DATA

    putexcel E`row' = `r(sd)', $DATA


  local ++row

}

* ADD NORM DIFFs AND LOG RATIO OF SD -------------------------------------------

local row = 4

foreach cov of varlist $COV {

  sum `cov' if prime == 0

    scalar c_mean   = `r(mean)'

    scalar c_sd     = `r(sd)'


  sum `cov' if prime == 1

    scalar t_mean   = `r(mean)'

    scalar t_sd   = `r(sd)'


  balanceMeasures $BALANCE

  scalar list

  putexcel   F`row' = normDif  G`row' = logRatioSD, $DATA


  local ++row

}

* ADD MULTIVAR DIFF IN COV DISTRIBUTIONS ---------------------------------------

  putexcel A`row' = "Multivariate diff", $SIDE_VAR $T_BORDER


  tabstat $COV if prime == 0, statistics(mean) save

    mat M_c = r(StatTotal)


  tabstat $COV if prime == 1, statistics(mean) save

    mat M_t = r(StatTotal)


  covariancemat $COV if prime == 0, covarmat(CV_c)

  covariancemat $COV if prime == 1, covarmat(CV_t)

  // Imbens & Rubin (2015), page 314
  mat MV = (M_t - M_c) * inv((CV_c + CV_t)/2) * (M_t - M_c)'

  scalar MV_balance = sqrt(MV[1,1])

    putexcel B`row':G`row' = MV_balance, $T_BORDER $DATA merge

*** GRAPHS: BALANCE BETWEEN EXPERIMENTS ****************************************

* DISCRETE VARIABLES -----------------------------------------------------------

foreach cov of varlist $COV_DISC {

  // PREP SUBTITLE (NORM DIF AND LOG RATIO OF SD)

  sum `cov' if prime == 0

    scalar c_mean = `r(mean)'

    scalar c_sd = `r(sd)'

  sum `cov' if prime == 1

    scalar t_mean = `r(mean)'

    scalar t_sd = `r(sd)'

  balanceMeasures $BALANCE

  local dif =  "Norm. diff. = "   + string(normDif, "%05.3f") +                 ///
         " | Log ratio = " + string(logRatioSD, "%05.3f")


  // HISTOGRAMS BY COVARIATE

  tab `cov', nofreq

  local uniqueValues = r(r)

  #delimit ;

  twoway   (hist `cov' if prime == 0,
                            $HIST fcolor(none) lcolor(black) lpattern(solid) )
          (hist `cov' if prime == 1,
                            $HIST fcolor(none) lcolor(red) lpattern(dash) )
          ,
          xtitle("")
          xlabel(#`uniqueValues')
          title(`cov')
          subtitle("`dif'")
          ytitle("Fraction")
          ylabel(0(0.25)1,angle(horizontal))
          legend(order(1 "No info" 2 "Info")
                                textfirst rows(2) region(lpattern(blank)))
          saving("$RUTA/temp/figures/temp_`cov'.gph", replace);

  #delimit cr

} // end of foreach

* CONTINUOUS VARIABLES ---------------------------------------------------------

foreach cov of varlist $COV_CONT {

// PREP SUBTITLE (NORM DIF AND LOG RATIO OF SD)

  sum `cov' if prime == 0

    scalar c_mean = `r(mean)'

    scalar c_sd = `r(sd)'

  sum `cov' if prime == 1

    scalar t_mean = `r(mean)'

    scalar t_sd = `r(sd)'

  balanceMeasures $BALANCE

  * PREP SUBTITLE

  local dif =  "Norm. diff. = "   + string(normDif, "%05.3f") +                   ///
         " | Log ratio = " + string(logRatioSD, "%05.3f")

  // KDENSITY BY COVARIATE

  #delimit ;

  twoway   (kdensity `cov' if prime == 0,
                                  fcolor(none) lcolor(black) lpattern(solid) )
          (kdensity `cov' if prime == 1,
                                  fcolor(none) lcolor(red) lpattern(dash) )
          ,
          xtitle("")
          xlabel(#5)
          subtitle("`dif'")
          title("`cov'")
          ytitle("Density")
          ylabel(,angle(horizontal))
          legend(order(1 "No info" 2 "Info")
                    textfirst rows(2) region(lpattern(blank)))
          saving("$RUTA/temp/figures/temp_`cov'.gph", replace);

  #delimit cr

} // end of foreach

#delimit ;

* COMBINE GRAPHS OF DEMOGRAPHICS ----------------------------------------------;

grc1leg "$RUTA/temp/figures/temp_female.gph"
        "$RUTA/temp/figures/temp_age.gph"
        "$RUTA/temp/figures/temp_collegeDegree.gph"
        "$RUTA/temp/figures/temp_exp_cat.gph"
        "$RUTA/temp/figures/temp_inc_cat.gph"
        "$RUTA/temp/figures/temp_weightDesc.gph"
        "$RUTA/temp/figures/temp_bmi.gph"
        ,
        cols(3) holes(7) altshrink position(5) ring(0);

graph export "$RUTA/results/figures/covDifExp_demographics.png",
                                    replace width(6000) height(8000);

* COMBINE GRAPHS OF ATTITUDES -------------------------------------------------;

grc1leg "$RUTA/temp/figures/temp_riskPref.gph"
        "$RUTA/temp/figures/temp_delta.gph"
        "$RUTA/temp/figures/temp_beta.gph"
        "$RUTA/temp/figures/temp_esc.gph"
        "$RUTA/temp/figures/temp_hungry.gph"
        ,
        cols(3) altshrink position(5) ring(0);

graph export "$RUTA/results/figures/covDifExp_attitudes.png",
                                    replace width(6000) height(5000);

* COMBINE GRAPHS OF HEALTH STATUS AND IMPORTANCE ------------------------------;

grc1leg "$RUTA/temp/figures/temp_healthStatus.gph"
        "$RUTA/temp/figures/temp_benefitEatHealthier.gph"
        "$RUTA/temp/figures/temp_wishEatBetterHome.gph"
        "$RUTA/temp/figures/temp_wishEatBetterOut.gph"
        "$RUTA/temp/figures/temp_healthImportant.gph"
        "$RUTA/temp/figures/temp_exerciseImportant.gph"
        "$RUTA/temp/figures/temp_weightImportant.gph"
        ,
        cols(3) holes(5 6) altshrink position(3) ring(0);

graph export "$RUTA/results/figures/covDifExp_health.png",
                                    replace width(6000) height(8000);

* COMBINE GRAPHS OF KNOWLEDGE OF CALORIES -------------------------------------;

grc1leg "$RUTA/temp/figures/temp_calNeedsKnowledge.gph"
        "$RUTA/temp/figures/temp_prevExp.gph"
        "$RUTA/temp/figures/temp_chain.gph"
        ,
        cols(2) altshrink position(5) ring(0);

graph export "$RUTA/results/figures/covDifExp_calorieKnow.png",
                                    replace width(6000) height(5000);

#delimit cr

*** TABLE: BALANCE BETWEEN TREATMENTS ******************************************

putexcel set "$RUTA/results/tables/covBalanceTreat.xlsx", sheet(results) replace

* HEADER -----------------------------------------------------------------------

#delimit ;

putexcel  B1:G1 = "Hypothetical: No info"
          H1:M1 = "Hypothetical: Info"
          ,
          $HEADER merge;

putexcel  B2:C2 = "Real: No info"
          D2:E2 = "Real: Info"
          F2:F4 = "Norm diff"
          G2:G4 = "Log ratio of SD"
          H2:I2 = "Real: No info"
          J2:K2 = "Real: Info"
          L2:L4 = "Norm diff"
          M2:M4 = "Log ratio of SD"
          ,
          $HEADER merge txtwrap;

putexcel  A4 = "Variable"
          B4 = "Mean"
          C4 = "Std. dev."
          D4 = "Mean"
          E4 = "Std. dev."
          H4 = "Mean"
          I4 = "Std. dev."
          J4 = "Mean"
          K4 = "Std. dev."
          ,
          $HEADER;

#delimit cr

* SIDE BAR ---------------------------------------------------------------------

putexcel A3 = "Observations", $SIDE_VAR

local row = 5

foreach name in $COV{

  putexcel A`row' = "`name'", $SIDE_VAR

  local ++row
}

putexcel A`row' = "Multivar diff", $SIDE_VAR $T_BORDER

* # OF OBS ---------------------------------------------------------------------

count if treatment == "nN"

  putexcel  B3:C3 = `r(N)', merge $DATA

count if treatment == "nE"

  putexcel  D3:E3 = `r(N)', merge $DATA

count if treatment == "pN"

  putexcel  H3:I3 = `r(N)', merge $DATA

count if treatment == "pE"

  putexcel  J3:K3 = `r(N)', merge $DATA

*ADD MEANS AND SDs -------------------------------------------------------------

local treatments = "nN nE pN pE"

local nCol = 1

foreach treat of varlist `treatments'{

  local row = 5

  foreach cov of varlist $COV {

    local col = char(65 + `nCol')  // char(65) = "A"

    sum `cov' if treatment == "`treat'"

      putexcel `col'`row' = `r(mean)', $DATA


    local col = char(65 + 1 + `nCol')

    sum `cov' if treatment == "`treat'"

      putexcel `col'`row' = `r(sd)', $DATA


    local ++row

  }

  if(`nCol' == 3){        // Skip 2 columns to
    local ++nCol          // report results of
    local ++nCol          // the 2nd experiment
  }

  local ++nCol
  local ++nCol

} // end of foreach treat

* ADD NORM DIFFs AND LOG RATIO OF SDs ------------------------------------------

local row = 5

foreach cov of varlist $COV {

  // UNEXPERIENCED

  sum `cov' if prime == 0 & endow == 0

    scalar c_mean   = `r(mean)'

    scalar c_sd   = `r(sd)'

  sum `cov' if prime == 0 & endow == 1

    scalar t_mean   = `r(mean)'

    scalar t_sd   = `r(sd)'


  balanceMeasures $BALANCE

    putexcel F`row' = normDif, $DATA

    putexcel G`row' = logRatioSD, $DATA


  // EXPERIENCED

  sum `cov' if prime == 1 & endow == 0

    scalar c_mean   = `r(mean)'

    scalar c_sd   = `r(sd)'

  sum `cov' if prime == 1 & endow == 1

    scalar t_mean   = `r(mean)'

    scalar t_sd   = `r(sd)'


  balanceMeasures $BALANCE

    putexcel L`row' = normDif, $DATA

    putexcel M`row' = logRatioSD, $DATA

  local ++row
}

* ADD MULTIVAR DIFF IN COV DISTRIBUTIONS ---------------------------------------

* UNEXPERIENCED

tabstat $COV if prime == 0 & endow == 1, statistics(mean) save

  mat M_c = r(StatTotal)

tabstat $COV if prime == 0 & endow == 0, statistics(mean) save

  mat M_t = r(StatTotal)


covariancemat $COV if prime == 0 & endow == 0, covarmat(CV_c)

covariancemat $COV if prime == 0 & endow == 1, covarmat(CV_t)

// Imbens & Rubin (2015), page 314
mat MV = (M_t - M_c) * inv((CV_c + CV_t)/2) * (M_t - M_c)'

scalar MV_balance = sqrt(MV[1,1])

  putexcel B`row':G`row' = MV_balance, $T_BORDER $DATA merge


* EXPERIENCED

tabstat $COV if prime == 1 & endow == 1, statistics(mean) save

  mat M_c = r(StatTotal)


tabstat $COV if prime == 1 & endow == 0, statistics(mean) save

  mat M_t = r(StatTotal)


covariancemat $COV if prime == 1 & endow == 0, covarmat(CV_c)

covariancemat $COV if prime == 1 & endow == 1, covarmat(CV_t)

// Imbens & Rubin (2015), page 314
mat MV = (M_t - M_c) * inv((CV_c + CV_t)/2) * (M_t - M_c)'

scalar MV_balance = sqrt(MV[1,1])

  putexcel H`row':M`row' = MV_balance, $T_BORDER $DATA merge

*** GRAPHS: BALANCE BTW TREATMENTS *********************************************

forvalues i = 0(1)1{

  preserve

    keep if prime == `i'

    * DISCRETE VARIABLES -------------------------------------------------------

    foreach cov of varlist $COV_DISC {

      // PREP SUBTITLE (NORM DIF AND LOG RATIO OF SD)

      sum `cov' if endow == 0

        scalar c_mean = `r(mean)'

        scalar c_sd = `r(sd)'

      sum `cov' if endow == 1

        scalar t_mean = `r(mean)'

        scalar t_sd = `r(sd)'

      balanceMeasures $BALANCE

      local dif =  "Norm. diff. = "   + string(normDif, "%05.3f") +             ///
             	     " | Log ratio = " + string(logRatioSD, "%05.3f")


      // HISTOGRAMS BY COVARIATE

      tab `cov', nofreq

      local uniqueValues = r(r)

      #delimit ;

      twoway  (hist `cov' if endow == 0,
                            $HIST fcolor(none) lcolor(black) lpattern(solid) )
              (hist `cov' if endow == 1,
                            $HIST fcolor(none) lcolor(red) lpattern(dash) )
              ,
              xtitle("")
              xlabel(#`uniqueValues')
              title(`cov')
              subtitle("`dif'")
              ytitle("Fraction")
              ylabel(0(0.25)1,angle(horizontal))
              legend(order(1 "No info" 2 "Info")
                                    textfirst rows(2) region(lpattern(blank)))
              saving("$RUTA/temp/figures/temp_`i'_`cov'.gph", replace);

      #delimit cr

    } // end of foreach

    * CONTINUOUS VARIABLES -----------------------------------------------------

    foreach cov of varlist $COV_CONT {

    // PREP SUBTITLE (NORM DIF AND LOG RATIO OF SD)

      sum `cov' if endow == 0

        scalar c_mean = `r(mean)'

        scalar c_sd = `r(sd)'

      sum `cov' if endow == 1

        scalar t_mean = `r(mean)'

        scalar t_sd = `r(sd)'

      balanceMeasures $BALANCE

      * PREP SUBTITLE

      local dif =  "Norm. diff. = "   + string(normDif, "%05.3f") +             ///
                   " | Log ratio = " + string(logRatioSD, "%05.3f")

      // KDENSITY BY COVARIATE

      #delimit ;

      twoway  (kdensity `cov' if endow == 0,
                                      fcolor(none) lcolor(black) lpattern(solid) )
              (kdensity `cov' if endow == 1,
                                      fcolor(none) lcolor(red) lpattern(dash) )
              ,
              xtitle("")
              xlabel(#5)
              subtitle("`dif'")
              title("`cov'")
              ytitle("Density")
              ylabel(,angle(horizontal))
              legend(order(1 "No info" 2 "Info")
                        textfirst rows(2) region(lpattern(blank)))
              saving("$RUTA/temp/figures/temp_`i'_`cov'.gph", replace);

      #delimit cr

    } // end of foreach

    #delimit ;

    * COMBINE GRAPHS OF DEMOGRAPHICS ------------------------------------------;

    grc1leg "$RUTA/temp/figures/temp_`i'_female.gph"
            "$RUTA/temp/figures/temp_`i'_age.gph"
            "$RUTA/temp/figures/temp_`i'_collegeDegree.gph"
            "$RUTA/temp/figures/temp_`i'_exp_cat.gph"
            "$RUTA/temp/figures/temp_`i'_inc_cat.gph"
            "$RUTA/temp/figures/temp_`i'_weightDesc.gph"
            "$RUTA/temp/figures/temp_`i'_bmi.gph"
            ,
            cols(3) holes(7) altshrink position(5) ring(0);

    graph export "$RUTA/results/figures/covDifTreat_`i'_demographics.png",
                                        replace width(6000) height(8000);

    * COMBINE GRAPHS OF ATTITUDES ---------------------------------------------;

    grc1leg "$RUTA/temp/figures/temp_`i'_riskPref.gph"
            "$RUTA/temp/figures/temp_`i'_delta.gph"
            "$RUTA/temp/figures/temp_`i'_beta.gph"
            "$RUTA/temp/figures/temp_`i'_esc.gph"
            "$RUTA/temp/figures/temp_`i'_hungry.gph"
            ,
            cols(3) altshrink position(5) ring(0);

    graph export "$RUTA/results/figures/covDifTreat_`i'_attitudes.png",
                                        replace width(6000) height(5000);

    * COMBINE GRAPHS OF HEALTH STATUS AND IMPORTANCE --------------------------;

    grc1leg "$RUTA/temp/figures/temp_`i'_healthStatus.gph"
            "$RUTA/temp/figures/temp_`i'_benefitEatHealthier.gph"
            "$RUTA/temp/figures/temp_`i'_wishEatBetterHome.gph"
            "$RUTA/temp/figures/temp_`i'_wishEatBetterOut.gph"
            "$RUTA/temp/figures/temp_`i'_healthImportant.gph"
            "$RUTA/temp/figures/temp_`i'_exerciseImportant.gph"
            "$RUTA/temp/figures/temp_`i'_weightImportant.gph"
            ,
            cols(3) holes(5 6) altshrink position(3) ring(0);

    graph export "$RUTA/results/figures/covDifTreat_`i'_health.png",
                                        replace width(6000) height(8000);

    * COMBINE GRAPHS OF KNOWLEDGE OF CALORIES ---------------------------------;

    grc1leg "$RUTA/temp/figures/temp_`i'_calNeedsKnowledge.gph"
            "$RUTA/temp/figures/temp_`i'_prevExp.gph"
            "$RUTA/temp/figures/temp_`i'_chain.gph"
            ,
            cols(2) altshrink position(5) ring(0);

    graph export "$RUTA/results/figures/covDifTreat_`i'_calorieKnow.png",
                                        replace width(6000) height(5000);

    #delimit cr

  restore

}

*** END OF FILE ****************************************************************
********************************************************************************
