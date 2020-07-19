/*******************************************************************************
              | DEPRECATED -> Use descriptiveStatistics.do |
********************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  (Excel) Table with descriptive statistics

Known issues: putexcel often fails when saving to dropbox (just pause dropbox)

Created: 20190102 | Last modified: 20200719
*******************************************************************************/
version 14.2

*** LOAD DATA ******************************************************************

use "$RUTA/results/endowmentEffectInfo.dta", clear

#delimit ;

*** MACROS:********************************************************************;

* FORMAT: TABLES --------------------------------------------------------------;

global HEADER "bold vcenter hcenter font(timesnewroman, 12)";

global SIDE_VAR "nobold italic right font(timesnewroman, 12)";

global DATA "nobold vcenter hcenter font(timesnewroman, 12)";


* LISTS OF COVARIATES ---------------------------------------------------------;

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


*** TABLE *********************************************************************;

putexcel set "$RUTA/results/tables/descriptiveStatistics.xlsx",
                                                        sheet(results) replace;

* HEADER ----------------------------------------------------------------------,

quietly putexcel A1 = "Variable", $SIDE_VAR;


quietly putexcel  B1 = "N"
                  C1 = "Mean"
                  D1 = "Std. Dev."
                  E1 = "Min"
                  F1 = "Max"
                  ,
                  $HEADER;

* SIDE BAR --------------------------------------------------------------------;

local row = 2;

foreach name in $COVS {;

  quietly putexcel A`row' = "`name'", $SIDE_VAR;

  local ++ row;

};


* ADD STATS -------------------------------------------------------------------;

local row = 2;

foreach cov of varlist $COVS {;

  quietly sum `cov';

  quietly putexcel  B`row' = `r(N)'
                    C`row' = `r(mean)'
                    D`row' = `r(sd)'
                    E`row' = `r(min)'
                    F`row' = `r(max)'
                    ,
                    $DATA;

  local ++ row;
};

#delimit cr

*** END OF FILE ****************************************************************
********************************************************************************
