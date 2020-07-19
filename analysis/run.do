/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Link:                                                                           // PENDING

Author:       TabareCapitan.com

Description:  This code generates tables and figures for the project

Input:        /rawData
              /code

Output:       /results/tables
              /results/figures

Replication:  For a clean run, delete /processed and /results
              and run this do-file

Software:     Analyses run on Windows using Stata 14 SE

Created: 20190217 | Last modified: 20200719
*******************************************************************************/
version 14.2


*** DEFINE PROJECT PATH ********************************************************

global RUTA "D:\Dropbox\T\r\endowmentEffectInfo\analysis"


*** INITIALIZE LOG AND RECORD SYSTEM PARAMETERS ********************************

clear

set more off

cap mkdir "$RUTA/code/logs"

cap log close

local datetime: di %tcCCYY.NN.DD!_HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'

local logfile "$RUTA/code/logs/log_`datetime'.txt"

log using "`logfile'", text

di "Begin date and time:  $S_DATE $S_TIME"
di "Stata version:        `c(stata_version)'"
di "Updated as of:        `c(born_date)'"
di "Variant:              `=cond( c(MP),"MP",cond(c(SE),"SE",c(flavor)) )'"
di "Processors:           `c(processors)'"
di "OS:                   `c(os)' `c(osdtl)'"
di "Machine type:         `c(machine_type)'"


*** USER-WRITTEN PACKAGES AND PROJECT PROGRAMS *********************************

*adopath ++ "$RUTA/code/libraries/stata"                                        // PENDING

adopath ++ "$RUTA/code/programs"                                                // PENDING


*** CREATE DIRECTORIES FOR OUTPUT FILES ****************************************

cap mkdir "$RUTA/temp"
cap mkdir "$RUTA/temp/data"
cap mkdir "$RUTA/temp/figures"

cap mkdir "$MyProject/results"
cap mkdir "$MyProject/results/figures"
cap mkdir "$MyProject/results/tables"


*** RUN ANALYSIS ***************************************************************

run "$RUTA/code/main.do"


*** END LOG ********************************************************************

di "End date and time: $S_DATE $S_TIME"

log close


*** END OF DOFILE **************************************************************
********************************************************************************
