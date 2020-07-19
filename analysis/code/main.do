/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  Controls the flow of the analysis

Created: 20190217 | Last modified: 20200719
*******************************************************************************/
version 14.2


*** SET UP *********************************************************************

run "$RUTA/code/settings.do"

run "$RUTA/code/installNewPrograms.do"

*** DATA MANAGEMENT ************************************************************

run "$RUTA/code/importData.do"

run "$RUTA/code/cleanData.do"                                                   // NEED TEXDOC

*** CHOICE PROCESS DATA ********************************************************

run "$RUTA/code/testUnderstanding.do"                                           // UPDATED

*** ASSUMPTIONS ****************************************************************

run "$RUTA/code/outliers.do"                                                    // NEED TEXDOC

run "$RUTA/code/calculateValueInfo.do"                                          // NEED TEXDOC

*** DATA ANALYSIS **************************************************************

run "$RUTA/code/descriptiveStatistics.do"                                       // IN PROGRESS

run "$RUTA/code/identifyLargeDifferences_excel.do"                              // PENDING

    //calls balanceMeasures.ado

run "$RUTA/code/treatmentEffects_binaryDepVar.do"                               // DONE

run "$RUTA/code/treatmentEffects_continuousDepVar.do"                           // PENDING

*** ERASE TEMP FILES ***********************************************************

run "$RUTA/code/deleteTempFiles.do"

*** END OF FILE ****************************************************************
********************************************************************************
