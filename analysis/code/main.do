/*******************************************************************************
Project:      Reference-Dependent Preferences for Information

Author:       TabareCapitan.com

Description:  Controls the flow of the analysis

Created: 20190217 | Last modified: 20200101
*******************************************************************************/
version 14.2


*** SET UP *********************************************************************

run "$RUTA\code\settings.do"

run "$RUTA\code\installNewPrograms.do"

*** DATA MANAGEMENT ************************************************************

run "$RUTA\code\importData.do"

run "$RUTA\code\cleanData.do"

*** CHOICE PROCESS DATA ********************************************************

run "$RUTA\code\testUnderstanding.do"

*** ASSUMPTIONS ****************************************************************

run "$RUTA\code\outliers.do"

run "$RUTA\code\calculateValueInfo.do"

*** DATA ANALYSIS **************************************************************

run "$RUTA\code\descriptiveStatistics.do"

run "$RUTA\code\identifyLargeDifferences.do"

    //calls balanceMeasures.ado

run "$RUTA\code\results.do"

*** ERASE TEMP FILES ***********************************************************

run "$RUTA\code\deleteTempFiles.do"

*** END OF FILE ****************************************************************
********************************************************************************
