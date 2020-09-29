/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  Controls the flow of the analysis

Created: 20190217 | Last modified: 20200728
*******************************************************************************/
version 14.2

*** SET UP *********************************************************************

run "$RUTA/code/settings.do"

run "$RUTA/code/installNewPrograms.do"

*** DATA MANAGEMENT ************************************************************

run "$RUTA/code/importData.do"

texdoc do "$RUTA/code/cleanData_texdoc.do"

*** DATA ANALYSIS **************************************************************

run "$RUTA/code/descriptiveStatistics.do"

run "$RUTA/code/identifyLargeDifferences.do"

    //calls balanceMeasures.ado

run "$RUTA/code/treatmentEffects_binaryDepVar.do"

run "$RUTA/code/treatmentEffects_continuousDepVar.do"

*run "$RUTA/code/treatmentEffects_continuousDepVar_tr.do"                        // PENDING

*run "$RUTA/code/treatmentEffects_continuousDepVar_cn.do"                        // PENDING

*** END OF FILE ****************************************************************
********************************************************************************
