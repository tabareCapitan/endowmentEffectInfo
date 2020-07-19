/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com
              klaas@uwyo.edu

Description:  Delete (unreasonable) outliers


Created: 20190217 | Last modified: 20200719
*******************************************************************************/
version 14.2

*** LOAD DATA ******************************************************************

use "$RUTA/temp/data/cleanUnderstood", replace

drop if !valid

drop valid

*** OUTLIERS *******************************************************************

/*   BETA

  beta is the present-bias parameter from the beta-delta model (Laibson, 97).

    beta < 1   : Present-bias
    beta = 0  : No present-bias
    beta > 1  : "Future-bias"

  Values below 1 but not too close to 0 are expected. Values higher than 1
  are unexpected.

  There are 217 consistent values of beta out of the 219 valid observations.

  beta < .25 for 4.5% of the participants and beta > 1.10 for  1.8%.

  We trim data below the 5th percentil and above the 95th percentil. We
  end up with 198 consistent values of beta.                                  */

sum beta, de

replace beta = .a if ( beta < r(p5) | beta > r(p95) )

/*  DELTA

  delta is the usual discounting factor.

  delta < 1  : Future is discounted
  delta = 1  : Future is not discounted
  delta > 1  : Present is discounted

  Values below 1 but far from 0 are expected. Values higher than 1 are not
  expected.

  We drop values lower than .5 and higher than 1. We end up with 199
  consistent values of delta.                                                 */

replace delta = .a if delta < .5 | delta > 1

/*   BMI

  The range of the body mass index is [.25 , 47.59]. We exclude values under
  15 as they are likely to be mistakes. We end up with 215 values.            */

replace bmi = .a if bmi < 15

*** SAVE ***********************************************************************

save "$RUTA/temp/data/cleanNoOutliers.dta", replace

*** END OF FILE ****************************************************************
********************************************************************************
