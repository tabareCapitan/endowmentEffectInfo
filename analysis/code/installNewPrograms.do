/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  Install required user-written programs (.ado)

Warning:      This do-file should not be run for replication. Instead, use the
              current ado files in /code/libraries


Created: 20191229 | Last modified: 20200719
*******************************************************************************/
version 14.2

*** CREATE AND DEFINE A LOCAL INSTALLATION DIRECTORY ***************************

cap mkdir "$RUTA/code/libraries"

cap mkdir "$RUTA/code/libraries/stata"

net set ado "$RUTA/code/libraries/stata"


*** INSTALL LAST VERSION OF USER-WRITTEN PROGRAMS ******************************

cap net install grc1leg, replace

cap net install ritest, replace

cap ssc install gsreg, replace

cap net install dm79, replace

cap ssc install svmatf, replace

cap net install texsave,                                                        ///
    from("https://raw.githubusercontent.com/reifjulian/texsave/master") replace


*** END OF FILE ****************************************************************
********************************************************************************
