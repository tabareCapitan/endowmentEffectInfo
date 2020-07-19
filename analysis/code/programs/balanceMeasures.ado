/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  Calculate measures of balance

Created: 20190217 | Last modified: 20190206
*******************************************************************************/
version 14.2

capture program drop balanceMeasures

program define balanceMeasures

  // ARGUMENTS

  local cMean = `1'
  local cSD   = `2'
  local tMean = `3'
  local tSD   = `4'

    scalar numerator = `tMean' - `cMean'

    scalar denominator = sqrt((`cSD'^2 + `tSD'^2)/2)

		// Imbens & Rubin (2015), page 311
    scalar normDif = abs(numerator / denominator)

    * GET LOG RATIO OF SD

		// Imbens & Rubin (2015), page 312
		scalar logRatioSD = abs(ln(`tSD') - ln(`cSD'))

end

*** END OF PROGRAM *************************************************************
********************************************************************************
