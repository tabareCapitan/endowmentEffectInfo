/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  Import raw .csv data to .dta

Created: 20190217 | Last modified:20200719
*******************************************************************************/
version 14.2

*** IMPORT DATA ****************************************************************

import delimited using "$RUTA/rawData/data.csv", varnames(1) rowrange(4) clear


*** SAVE DATA ******************************************************************

save "$RUTA/temp/data/raw.dta", replace

*** END OF FILE ****************************************************************
********************************************************************************
