/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com
              klaas@uwyo.edu

Description:  Clean data and create a laTeX file describing the process.


Created: 20191229 | Last modified: 20200719
*******************************************************************************/
version 14.2

cap sjlatex install using "$RUTA/code/logs/texdoc"

texdoc init "$RUTA/code/logs/texdoc/cleanData.tex", replace

/*tex
\documentclass[11pt,reqno]{amsart}
\usepackage{fullpage}
\usepackage{graphicx}
\usepackage{stata}
\usepackage{setspace}
\usepackage{float}
\usepackage{subfigure}
\usepackage[bookmarks]{hyperref}
\setlength{\parskip}{\baselineskip}
\setlength{\parindent}{0pt}
%\setlength{\parskip}{0pt}
%\setlength{\parindent}{2em}
\setlength{\footskip}{0.5in}
%\setstretch{1.2}
\makeatletter
\def\@fnsymbol#1{\ifcase#1\or *\or **\fi\relax}
\renewcommand{\section}{\@startsection%
  {section}%
  {1}%
  {0mm}%
  {-1.2\baselineskip}%
  {0.5\baselineskip}%
  {\centering\scshape\normalsize}}
\renewcommand{\subsection}{\@startsection%
  {subsection}%
  {1}%
  {0mm}%
  {-1.4\baselineskip}%
  {0.5em}%
  {\centering\bfseries\normalsize}}
\renewcommand{\subsubsection}{\@startsection%
  {subsubsection}%
  {2}%
  {0mm}%
  {-0em}%
  {0.5em}%
  {\itshape\normalsize}}
\makeatother
\setcounter{secnumdepth}{2}
\renewcommand{\floatpagefraction}{1.00}
\renewcommand{\topfraction}{1.00}
\renewcommand{\textfraction}{0.00}
\newcommand{\eqs}{\buildrel s \over =}
\let\IG\iffalse
\let\ENDIG\fi
\newcommand{\LR}{\Leftrightarrow}
\newcommand{\half}{\tfrac{1}{2}}
\newcommand{\thrd}{\tfrac{1}{3}}
\newcommand{\sxth}{\tfrac{1}{6}}
\newcommand{\xb}{\overline{x}}
\begin{document}

\tableofcontents
\newpage
\section{Load the raw data saved to Stata format by getrawdata.do}
tex*/

texdoc stlog, do
//use rawdata, clear
use "$RUTA/temp/data/raw.dta", clear
quietly destring, replace
texdoc stlog close

/*tex
\section{Drop unwanted observations and variables}

Drop the lone subject who reported being vegetarian or vegan.
tex*/

texdoc stlog, do
tab screen_diet
drop if screen_diet == 1
drop screen_diet
texdoc stlog close

/*tex
Drop the 18 subjects who reported participating in a similar experiment earlier
in the year.
tex*/

texdoc stlog, do
tab screen_exp2018
drop if screen_exp2018 == 1
drop screen_exp2018
drop screened_out
texdoc stlog close

/*tex
Drop the 29 subjects who reported they did not intend to eat the cake
themselves (implying that the calorie content wouldn't matter to them).

This leaves 219 subjects.
tex*/

texdoc stlog, do
tab intend
drop if intend == 2
drop intend
count
texdoc stlog close

/*tex
Drop unnecessary diagnostic variables added by Qualtrics.
tex*/

texdoc stlog, do
#delimit ;
local dropvars = "
startdate
enddate
status
ipaddress
progress
durationinseconds
finished
recordeddate
responseid
recipientfirstname
recipientlastname
recipientemail
externalreference
locationlatitude
locationlongitude
distributionchannel
userlanguage
";
#delimit cr
drop `dropvars'
texdoc stlog close

/*tex
Drop display-order variables added by Qualtrics.
tex*/

texdoc stlog, do
drop *_do
texdoc stlog close

/* Drop ``embedded data'' variables generated as part of the
survey-flow logic */
texdoc stlog, do
drop do_*
drop row*
drop dessert*
drop descal*
drop parserow*
rename session tmpsession
drop ses*
rename tmpsession session
drop noncake*
drop nc*
drop chosen*
drop other*
drop rest*
drop phone*
drop car*
drop vac*
drop color1
drop ccod*
drop cmon*
texdoc stlog close

/*tex
Drop id variables.
tex*/

texdoc stlog, do
drop id1 id2
texdoc stlog close

/*tex
Drop variables created in the training phase of the survey that we aren't
really interested in.
tex*/

drop ex1 ex2 ex3 ex4 ex5a ex5b ex8
drop wta1_1
foreach i of numlist 1/3 {
  drop wta2_`i'
}
local tmpnum "3 4 8"
foreach i of local tmpnum {
  foreach j of numlist 1/6 {
    drop wta`i'_`j'
  }
}
/* Typo */
rename priming20_s priming20_c
foreach i of numlist 1/10 {
  foreach j of numlist 0/1 {
    drop priming`i'`j'_c
    foreach k of numlist 1/3 {
      drop priming`i'`j'_s_`k'
    }
  }
}

/*tex
Generate a proper, unique id number (the ones in the raw dataset aren't always
unique)
tex*/

texdoc stlog, do
gen id = _n
texdoc stlog close

/*tex
\section{Generate treatment dummies}

For convenience, generate new dummies that correpond to the four effective
treatments:

\begin{tabular}{ll}
\verb~nN~ & not primed, not endowed with information\\
\verb~nE~ & not primed, endowed with information\\
\verb~pN~ & primed, not endowed with information\\
\verb~pE~ & primed, endowed with information
\end{tabular}
tex*/

texdoc stlog, do
mark nN if prime == 0 & endow == 0
mark nE if prime == 0 & endow == 1
mark pN if prime == 1 & endow == 0
mark pE if prime == 1 & endow == 1
tab nN
tab nE
tab pN
tab pE
texdoc stlog close

/*tex
Also generate a dummy that marks if a subject was primed {\em or} endowed (or
both)
tex*/

texdoc stlog, do
mark porE if prime == 1 | endow == 1
tab porE
texdoc stlog close



/*tex
\section{Generate dependent variables}

\subsection{Information choice}

Generate a dummy for whether the subject wanted calorie info.

If subjects where shown info (\verb~endow == 1)~, then the
\verb~keepon_or_remove~ variable is 2 if they chose to keep it,
and 1 if they chose to have it removed.

If subjects were not shown info (\verb~endow == 0)~, then the
\verb~add_or_keep_off~ variable is 1 if they chose to add it,
and 2 if they chose to have it removed.
tex*/

texdoc stlog, do
gen wantcalinfo = .
replace wantcalinfo = 1 if endow == 1 & keepon_or_remove == 2
replace wantcalinfo = 0 if endow == 1 & keepon_or_remove == 1
replace wantcalinfo = 1 if endow == 0 & add_or_keep_off == 1
replace wantcalinfo = 0 if endow == 0 & add_or_keep_off == 2
tab wantcalinfo
assert wantcalinfo < .
drop keepon_or_remove add_or_keep_off
texdoc stlog close

/*tex
\subsection{Variables indicating how well the subject understood the BDM
mechanism}

After a short in-lab lecture on how to use the multiple-price list and four
practice exercises using the computer, we asked participants three further
questions to test their understanding of the mulitple-price list.

The dummy variable \verb~confused5a~ indicates if subjects misunderstood how
much money they would get depending on which row the computer randomly chose
for the first test question.

Out of 219 valid participants, 30 (13.7\%) failed the first test and received an
individualized explanation from the monitor.
tex*/

texdoc stlog, do
tab confused5a
label var confused5a "Confused about BDM initially a"
texdoc stlog close

/*tex
The dummy variable \verb~confused5b~ indicates if subjects misunderstood how
much money they would get depending on which row the computer randomly chose
for the second test question.

This time there was no prompt to raise their hand if their answer was
incorrect.

Only 6 participants (2.74\%) chose the wrong answer. Oddly, 5 out of the 6
participants who chose the wrong answer on the second test question had
previously chosen the correct answer on the first test question. Only 1
participant chose the wrong answer for both.
tex*/

texdoc stlog, do
tab confused5b
tab confused5b confused5a
label var confused5b "Confused about BDM initially b"
texdoc stlog close

/*tex
The dummy variable \verb~confused8~ indicates if on the very last exercise,
subjects made mistakes in terms of indicating willingness to accept a lower sum
of money, but not a higher sum of money. No subjects made that error, so we
don't need to retain the variable.
tex*/

texdoc stlog, do
tab confused8
drop confused8
texdoc stlog close

/*tex
We assume that participants who chose the wrong answer on the second test
question did not understand the multiple-price list. Note that this
lack of understanding casts doubt on the ``value of information'' outcome
variable elicited for these participants, but does not affect the other,
``Information choice'' outcome variable.
tex*/

texdoc stlog, do
gen understanding = (confused5b == 0) if !missing(confused5b)
tab understanding
drop confused*
texdoc stlog close

/*tex
\subsection{Value of information}

For subjects initially endowed with info who chose to remove it,
calculate the WTA to keep the info on after all.
The 10 options offered to them as an alternative to
``Remove calorie information'' (coded as 0) were

\begin{enumerate}
\item Keep and see calorie information + \$0.01
\item Keep and see calorie information + \$0.25
\item Keep and see calorie information + \$0.50
\item Keep and see calorie information + \$0.75
\item Keep and see calorie information + \$1.00
\item Keep and see calorie information + \$1.50
\item Keep and see calorie information + \$2.00
\item Keep and see calorie information + \$2.50
\item Keep and see calorie information + \$3.00
\item Keep and see calorie information + \$5.00
\end{enumerate}

A subject who chose 1 for all 10 options is willing to accept info for some
value on interval \$(\$0,\$0.01]\$. A subject who chose 0 for the first option, but 1
for all remaining 9 options is willing to accept info for some value on
interval \$(\$0.01,\$0.25]\$. Etc. If we take the midpoint of the intervals to be
their WTA, and conservatively use \$5.00 for the WTA of subjects who chose 0
for all 10 options, we get WTA values

\begin{enumerate}
\item 0.5(\$0.00 + \$0.01) = \$0.005
\item 0.5(\$0.01 + \$0.25) = \$0.13
\item 0.5(\$0.25 + \$0.50) = \$0.375
\item 0.5(\$0.50 + \$0.75) = \$0.625
\item 0.5(\$0.75 + \$1.00) = \$0.875
\item 0.5(\$1.00 + \$1.50) = \$1.25
\item 0.5(\$1.50 + \$2.00) = \$1.75
\item 0.5(\$2.00 + \$2.50) = \$2.25
\item 0.5(\$2.50 + \$3.00) = \$2.75
\item 0.5(\$3.00 + \$5.00) = \$4.00
\item \$5.00
\end{enumerate}

Since we ensured in Qualtrics that answers never had 0's following 1's, we can
calculate the WTA using the following code, which maps the total number of 1's
to the WTA.
tex*/

texdoc stlog, do
egen wta_rtki = rowtotal(wta_remove_to_keepon_*), missing
gen wta_rtk = .
replace wta_rtk = 0.005 if wta_rtki == 10
replace wta_rtk = 0.13  if wta_rtki ==  9
replace wta_rtk = 0.375 if wta_rtki ==  8
replace wta_rtk = 0.625 if wta_rtki ==  7
replace wta_rtk = 0.875 if wta_rtki ==  6
replace wta_rtk = 1.25  if wta_rtki ==  5
replace wta_rtk = 1.75  if wta_rtki ==  4
replace wta_rtk = 2.25  if wta_rtki ==  3
replace wta_rtk = 2.75  if wta_rtki ==  2
replace wta_rtk = 4.00  if wta_rtki ==  1
replace wta_rtk = 5.00  if wta_rtki ==  0
assert wta_rtk == . if endow == 0 | wantcalinfo == 1
assert wta_rtk <  . if endow == 1 & wantcalinfo == 0
drop wta_rtki
drop wta_remove_to_keepon_*
texdoc stlog close

/*tex
For subjects initially endowed with info who chose to keep it,
calculate the WTA to remove the info after all.
The 10 options offered to them as an alternative to
``Keep and see calorie information'' (coded as 0) were

\begin{enumerate}
\item Remove calorie information + \$0.01
\item Remove calorie information + \$0.25
\item Remove calorie information + \$0.50
\item Remove calorie information + \$0.75
\item Remove calorie information + \$1.00
\item Remove calorie information + \$1.50
\item Remove calorie information + \$2.00
\item Remove calorie information + \$2.50
\item Remove calorie information + \$3.00
\item Remove calorie information + \$5.00
\end{enumerate}

A subject who chose 1 for all 10 options is willing to accept not having info for some
value on interval \$(\$0,\$0.01]\$. A subject who chose 0 for the first option, but 1
for all remaining 9 options is willing to not have info for some value on
interval \$(\$0.01,\$0.25]\$. Etc. If we take the midpoint of the intervals to be
their WTA, and conservatively use \$5.00 for the WTA of subjects who chose 0
for all 10 options, we get WTA values

\begin{enumerate}
\item 0.5(\$0.00 + \$0.01) = \$0.005
\item 0.5(\$0.01 + \$0.25) = \$0.13
\item 0.5(\$0.25 + \$0.50) = \$0.375
\item 0.5(\$0.50 + \$0.75) = \$0.625
\item 0.5(\$0.75 + \$1.00) = \$0.875
\item 0.5(\$1.00 + \$1.50) = \$1.25
\item 0.5(\$1.50 + \$2.00) = \$1.75
\item 0.5(\$2.00 + \$2.50) = \$2.25
\item 0.5(\$2.50 + \$3.00) = \$2.75
\item 0.5(\$3.00 + \$5.00) = \$4.00
\item \$5.00
\end{enumerate}

Since we ensured in Qualtrics that answers never had 0's following 1's, we can
calculate the WTA using the following code, which maps the total number of 1's
to the WTA.
tex*/

texdoc stlog, do
egen wta_ktri = rowtotal(wta_keepon_to_remove_*), missing
gen wta_ktr = .
replace wta_ktr = 0.005 if wta_ktri == 10
replace wta_ktr = 0.13  if wta_ktri ==  9
replace wta_ktr = 0.375 if wta_ktri ==  8
replace wta_ktr = 0.625 if wta_ktri ==  7
replace wta_ktr = 0.875 if wta_ktri ==  6
replace wta_ktr = 1.25  if wta_ktri ==  5
replace wta_ktr = 1.75  if wta_ktri ==  4
replace wta_ktr = 2.25  if wta_ktri ==  3
replace wta_ktr = 2.75  if wta_ktri ==  2
replace wta_ktr = 4.00  if wta_ktri ==  1
replace wta_ktr = 5.00  if wta_ktri ==  0
assert wta_ktr == . if endow == 0 | wantcalinfo == 0
assert wta_ktr <  . if endow == 1 & wantcalinfo == 1
drop wta_ktri
drop wta_keepon_to_remove_*
texdoc stlog close

/*tex
For subjects initially {\em not} endowed with info who chose to add it,
calculate the WTA to keep the info off after all.
The 10 options offered to them as an alternative to
``Add and see calorie information'' (coded as 0) were

\begin{enumerate}
\item Keep calorie information off + \$0.01
\item Keep calorie information off + \$0.25
\item Keep calorie information off + \$0.50
\item Keep calorie information off + \$0.75
\item Keep calorie information off + \$1.00
\item Keep calorie information off + \$1.50
\item Keep calorie information off + \$2.00
\item Keep calorie information off + \$2.50
\item Keep calorie information off + \$3.00
\item Keep calorie information off + \$5.00
\end{enumerate}

A subject who chose 1 for all 10 options is willing to accept not having info for some
value on interval \$(\$0,\$0.01]\$. A subject who chose 0 for the first option, but 1
for all remaining 9 options is willing to not have info for some value on
interval \$(\$0.01,\$0.25]\$. Etc. If we take the midpoint of the intervals to be
their WTA, and conservatively use \$5.00 for the WTA of subjects who chose 0
for all 10 options, we get WTA values

\begin{enumerate}
\item 0.5(\$0.00 + \$0.01) = \$0.005
\item 0.5(\$0.01 + \$0.25) = \$0.13
\item 0.5(\$0.25 + \$0.50) = \$0.375
\item 0.5(\$0.50 + \$0.75) = \$0.625
\item 0.5(\$0.75 + \$1.00) = \$0.875
\item 0.5(\$1.00 + \$1.50) = \$1.25
\item 0.5(\$1.50 + \$2.00) = \$1.75
\item 0.5(\$2.00 + \$2.50) = \$2.25
\item 0.5(\$2.50 + \$3.00) = \$2.75
\item 0.5(\$3.00 + \$5.00) = \$4.00
\item \$5.00
\end{enumerate}

Since we ensured in Qualtrics that answers never had 0's following 1's, we can
calculate the WTA using the following code, which maps the total number of 1's
to the WTA.
tex*/

texdoc stlog, do
egen wta_atki = rowtotal(wta_add_to_keepoff_*), missing
gen wta_atk = .
replace wta_atk = 0.005 if wta_atki == 10
replace wta_atk = 0.13  if wta_atki ==  9
replace wta_atk = 0.375 if wta_atki ==  8
replace wta_atk = 0.625 if wta_atki ==  7
replace wta_atk = 0.875 if wta_atki ==  6
replace wta_atk = 1.25  if wta_atki ==  5
replace wta_atk = 1.75  if wta_atki ==  4
replace wta_atk = 2.25  if wta_atki ==  3
replace wta_atk = 2.75  if wta_atki ==  2
replace wta_atk = 4.00  if wta_atki ==  1
replace wta_atk = 5.00  if wta_atki ==  0
assert wta_atk == . if endow == 1 | wantcalinfo == 0
assert wta_atk <  . if endow == 0 & wantcalinfo == 1
drop wta_atki
drop wta_add_to_keepoff_*
texdoc stlog close

/*tex
For subjects initially {\em not} endowed with info who chose to keep it off,
calculate the WTA to add the info after all.
The 10 options offered to them as an alternative to
``Keep calorie information off'' (coded as 0) were

\begin{enumerate}
\item Add and see calorie information + \$0.01
\item Add and see calorie information + \$0.25
\item Add and see calorie information + \$0.50
\item Add and see calorie information + \$0.75
\item Add and see calorie information + \$1.00
\item Add and see calorie information + \$1.50
\item Add and see calorie information + \$2.00
\item Add and see calorie information + \$2.50
\item Add and see calorie information + \$3.00
\item Add and see calorie information + \$5.00
\end{enumerate}

A subject who chose 1 for all 10 options is willing to accept having info for some
value on interval \$(\$0,\$0.01]\$. A subject who chose 0 for the first option, but 1
for all remaining 9 options is willing to have info for some value on
interval \$(\$0.01,\$0.25]\$. Etc. If we take the midpoint of the intervals to be
their WTA, and conservatively use \$5.00 for the WTA of subjects who chose 0
for all 10 options, we get WTA values

\begin{enumerate}
\item 0.5(\$0.00 + \$0.01) = \$0.005
\item 0.5(\$0.01 + \$0.25) = \$0.13
\item 0.5(\$0.25 + \$0.50) = \$0.375
\item 0.5(\$0.50 + \$0.75) = \$0.625
\item 0.5(\$0.75 + \$1.00) = \$0.875
\item 0.5(\$1.00 + \$1.50) = \$1.25
\item 0.5(\$1.50 + \$2.00) = \$1.75
\item 0.5(\$2.00 + \$2.50) = \$2.25
\item 0.5(\$2.50 + \$3.00) = \$2.75
\item 0.5(\$3.00 + \$5.00) = \$4.00
\item \$5.00
\end{enumerate}

Since we ensured in Qualtrics that answers never had 0's following 1's, we can
calculate the WTA using the following code, which maps the total number of 1's
to the WTA.
tex*/

texdoc stlog, do
egen wta_ktai = rowtotal(wta_keepoff_to_add_*), missing
gen wta_kta = .
replace wta_kta = 0.005 if wta_ktai == 10
replace wta_kta = 0.13  if wta_ktai ==  9
replace wta_kta = 0.375 if wta_ktai ==  8
replace wta_kta = 0.625 if wta_ktai ==  7
replace wta_kta = 0.875 if wta_ktai ==  6
replace wta_kta = 1.25  if wta_ktai ==  5
replace wta_kta = 1.75  if wta_ktai ==  4
replace wta_kta = 2.25  if wta_ktai ==  3
replace wta_kta = 2.75  if wta_ktai ==  2
replace wta_kta = 4.00  if wta_ktai ==  1
replace wta_kta = 5.00  if wta_ktai ==  0
assert wta_kta == . if endow == 1 | wantcalinfo == 1
assert wta_kta <  . if endow == 0 & wantcalinfo == 0
drop wta_ktai
drop wta_keepoff_to_add_*
texdoc stlog close

/*tex
Now calculate the value of information implied by the WTA values calculated
above.

For subjects initially endowed with info who chose to remove it,
the WTA to keep the info on after all
(\verb~wta_remove_to_keepon~ or \verb~wta_rtk~ for short)
measures how much they {\em dislike} info.

For subjects initially endowed with info who chose to keep it,
the WTA to remove the info after all
(\verb~wta_wta_keepon_to_remove~ or \verb~wta_ktr~ for
short) measures how much they {\em like} info.

For subjects initially {\em not} endowed with info who chose to add it,
the WTA to keep the info off after all
(\verb~wta_add_to_keepoff~ or \verb~wta_atk~ for
short) measures how much they {\em like} info.

For subjects initially {\em not} endowed with info who chose to keep it off,
the WTA to add the info after all
(\verb~wta_wta_keepoff_to_add~ or \verb~wta_kta~ for
short) measures how much they {\em dislike} info.

Label the thus calculated value of information \verb~valinfocn~, with suffix
``\verb~cn~'' indicating that this measure ``conservatively'' assigns values -\$5
and \$5 to subjects with extreme values $\leq -\$5$ and $\geq \$5$.

At the very end, set this variable to missing for participants who did not
seem to understand the BGM mechanism.
tex*/

texdoc stlog, do
gen valinfocn = .
replace valinfocn = -wta_rtk if endow == 1 & wantcalinfo == 0
replace valinfocn =  wta_ktr if endow == 1 & wantcalinfo == 1
replace valinfocn =  wta_atk if endow == 0 & wantcalinfo == 1
replace valinfocn = -wta_kta if endow == 0 & wantcalinfo == 0
assert valinfocn < .
replace valinfocn = . if understanding == 0
label var valinfocn "Value of information setting extremes to -5 and 5"
texdoc stlog close

/*tex
To be able to run interval regression on the \verb~valinfo~ data, generate two
copies, one of which drops left-censored values and one of which drops
right-censored ones.
tex*/

texdoc stlog, do
gen valinfo1 = valinfocn
replace valinfo1 = . if valinfocn == -5
gen valinfo2 = valinfocn
replace valinfo2 = . if valinfocn == 5
texdoc stlog close

/*tex
As an alternative way of dealing with extreme values, generate a value
\verb~valinfotr~ that drops them altogether, with suffix ``\verb~tr~''
indicating that the values were ``trimmed.''
tex*/

texdoc stlog, do
gen valinfotr = valinfocn
replace valinfotr = . if valinfocn == -5 | valinfocn == 5
replace valinfotr = . if understanding == 0
label var valinfotr "Value of information dropping extremes"
texdoc stlog close

/*tex
As yet another way of dealing with extreme values, impute them
using the ``triangle'' imputation method used by Alcott and
others (in a paper that Tabar\'{e} dug up).

This method involves the following steps:
\begin{enumerate}
  \item Find the density of the next-to-last bin, equal to
    \begin{equation*}
      \dfrac{n_i}{N},
    \end{equation*}
where $n_i$ is the number of observations in the bin and $N$ is the total number
of observations.
  \item Find the implied height of the next-to-last bin, equal to
\begin{equation*}
  h_i = \dfrac{n_i}{N\cdot w_i},
\end{equation*}
where $w_i$ is the bin's width.
\item Find the density of the last bin to be added, equal to
    \begin{equation*}
      \dfrac{n_e}{N},
    \end{equation*}
where $n_e$ is the number of extreme observations beyond the last bin's edge.
\item Tack a rectangular triangle onto the end of the histogram with height $h_i$
  and width $w_e$ such that the triangle's area corresponds to the density
  $n_e/N$. Mathematically, this requires that
  \begin{equation*}
      \half h_i w_e = \dfrac{n_e}{N}
  \end{equation*}
  so that
  \begin{equation*}
    w_e = \dfrac{2n_e}{N\cdot h_i} = \dfrac{2n_e}{N}\cdot\dfrac{N\cdot
    w_i}{n_i} = 2 \dfrac{n_e}{n_i}w_i.
  \end{equation*}
\item Letting $x_i$ denote the outer edge of the last bin,
  calculate the conditional expectation of values in the range $[x_i, x_i
    + w_e]$ if they were distributed according to the triangular distribution:
    \begin{align*}
      \xb
      &= x_i + \dfrac{
        \int_0^{w_e} \left(h_i - \dfrac{h_i}{w_e}w\right)w\,dw
      }
      {
        \int_0^{w_e} \left(h_i - \dfrac{h_i}{w_e}\right)\,dw
      }\\
      &= x_i +
      \dfrac{
        \left[\half h_i w^2 - \thrd\dfrac{h_i}{w_e}w^3\right]_0^{w_e}
      }
      {
        \left[h_i w - \half\dfrac{h_i}{w_e}w^2\right]_0^{w_e}
      }\\
      &= x_i +
      \dfrac{
        \half h_i w_e^2 - \thrd h_i w_e^2
      }
      {
        h_i w_e - \half h_i w_e
      }\\
      &= x_i +
      \dfrac{
        \sxth h_i w_e^2
      }
      {
        \half h_i w_e
      }\\
      &= x_i + \thrd w_e.
    \end{align*}

\end{enumerate}

{\em Note:} I tried doing this for each treatment separately, but that
generated crap for treatment \verb~nE~, because it doesn't have any
observations in the next-to-extreme bins. The closest alternative was to then
spread out those bins to -5 and 5, but that yielded very high and low values
of $\xb$ (-10 and 7.3). So instead, I ended up doing it for the entire sample
at once. Since I find that the imputed value on the left is exactly -6 and
that on the right is 5.952, it seems sensible to round that value up to 6, for
symmetry.
tex*/

texdoc stlog, do
/* Generate a variable to hold partially imputed values of information */
gen valinfoim = valinfocn

/* Get the total number of observations */
count
local N = r(N)
di "N = `N'"

/* Get the number of observations in the second bin on the left
   and the width of that bin */
count if valinfocn == -4
local nil = r(N)
di "nil = `nil'"

/* Get the number of observations in the first bin on the left*/
count if valinfocn == -5
local nel = r(N)
di "nel = `nel'"

/* Calculate and assign the imputed value */
local xbl = -5 - (2/3)*`nel'/`nil'*(5 - 3)
di "xbl = `xbl'"
replace valinfoim = -6 if valinfocn == -5

/* Get the number of observations in the next-to-last bin on the right
   and the width of that bin */
count if valinfocn == 4
local nir = r(N)
di "nir = `nir'"

/* Get the number of observations in the extreme bin on the right*/
count if valinfocn == 5
local ner = r(N)
di "ner = `ner'"

/* Calculate and assign the imputed value */
local xbr = 5 + (2/3)*`ner'/`nir'*(5 - 3)
di "xbr = `xbr'"
replace valinfoim = 6 if valinfocn == 5

/* Summarize the results */
local treatments "nN nE pN pE"
foreach treatment of local treatments {
  di _n(3) "Treatment: `treatment'"
  sum valinfoim if `treatment' == 1
}
replace valinfoim = . if understanding == 0
label var valinfoim "Value of information imputing extremes"
texdoc stlog close

/*tex
\section{Generate independent variables}

\subsection{Hungry likert}

Qualtrics codes the ``How hungry are you right now?'' variable \verb~hungry~ as

\begin{tabular}{l@{\;=\;}c}
Not hungry at all & 3\\
Somewhat hungry   & 4\\
Hungry            & 2\\
Very Hungry       & 1
\end{tabular}

Change that to

\begin{tabular}{l@{\;=\;}c}
Not hungry at all & 0\\
Somewhat hungry   & 1\\
Hungry            & 2\\
Very Hungry       & 3
\end{tabular}
tex*/

texdoc stlog, do
rename hungry hungryQ
tab hungryQ
recode hungryQ (3=0) (4=1) (1=3), generate(hungry)
tab hungry
label var hungry "Hungry (0 = not at all, 3 = very)"
drop hungryQ
texdoc stlog close

/*tex
Also create a set of dummies for each item.
tex*/

texdoc stlog, do
tab hungry, generate(hungry_)
texdoc stlog close

/*tex
\subsection{Female dummy}

Qualtrics codes the ``What is your gender?'' variable \verb~gender~ as

\begin{tabular}{l@{\;=\;}c}
Male   & 1\\
Female & 2
\end{tabular}

Change that to a \verb~female~ dummy with

\begin{tabular}{l@{\;=\;}c}
Male   & 0\\
Female & 1
\end{tabular}
tex*/

texdoc stlog, do
tab gender
recode gender (1=0) (2=1), generate(female)
tab female
label var female "Female"
drop gender
texdoc stlog close

/*tex
\subsection{Age}
Qualtrics codes the ``What is your age?'' variable
\verb~age~ as
\begin{tabular}{l@{\;=\;}c}
18 & 1\\
19 & 2\\
\multicolumn{1}{c}{\vdots}\\
79 & 62\\
80 or more & 63
\end{tabular}

Noone was 80 or more, so just recode this by adding 17.
tex*/

texdoc stlog, do
replace age = age + 17 if age < .
label var age "Age"
texdoc stlog close

/*tex
\subsection{College dummy}

Qualtrics codes the ``What is your highest level of education?'' variable
\verb~education~ as

\begin{tabular}{l@{\;=\;}c}
Less than high school & ?\\
High school           & 2\\
Professional degree   & 6\\
Some college          & 3\\
College degree        & 4
\end{tabular}

(The question mark indicates that nobody selected ``Less than high school.'')

Change this to

\begin{tabular}{l@{\;=\;}c}
Less than high school & ?\\
High school           & 1\\
Professional degree   & 2\\
Some college          & 3\\
College degree        & 4
\end{tabular}
tex*/

texdoc stlog, do
rename education educationQ
tab educationQ
recode educationQ (2=1) (6=2), generate(education)
tab education
label var education "Education (1 = high school, 4 = college degree)"
drop educationQ
texdoc stlog close

/*tex
Also create a set of dummies for each item
tex*/

texdoc stlog, do
tab education, generate(education_)
texdoc stlog close

/*tex
and generate a \verb~college~ dummy equal to 1 if the subject has either some
college or a college degree.
tex*/

texdoc stlog, do
mark college if education == 3 | education == 4
tab college
label var college "Some college or finished college"
texdoc stlog close

/*tex
\subsection{Risk preference likert}

Qualtrics codes the ``Please select the gamble below that you would choose to
participate in'' variable
\verb~riskpref~ as

\begin{tabular}{l@{\;=\;}c}
Gamble 1: low outcome: \$28, high outcome: \$28 & 1\\
Gamble 2: low outcome: \$24, high outcome: \$36 & 2\\
Gamble 3: low outcome: \$20, high outcome: \$44 & 3\\
Gamble 4: low outcome: \$16, high outcome: \$52 & 4\\
Gamble 5: low outcome: \$12, high outcome: \$60 & 5\\
Gamble 6: low outcome: \$2,  high outcome: \$70 & 6
\end{tabular}

For now, let's stick with treating this as is as a Likert scale, but let's also
create dummies for each item.
tex*/

texdoc stlog, do
label var riskpref "Risk preference (1 = low, 6 = high)"
tab riskpref, generate(riskpref_)
texdoc stlog close

/*tex
\subsection{Eating self-control}

The \verb~foodsc_[1-10]~ variables map as follows to the Haws et.\ al eating
self-control scale, with stars indicating reverse coding.

\begin{tabular}{ll}
\verb=foodsc_1= & I am good at resisting tempting food.\\
\verb=foodsc_2= & I have a hard time breaking bad eating habits.*\\
\verb=foodsc_3= & I eat inappropriate things.*\\
\verb=foodsc_4= & I eat certain things that are bad for my health, if they are
delicious.*\\
\verb=foodsc_5= & I refuse to overindulge on foods that are bad for me.\\
\verb=foodsc_6= & People would say that I have iron self-discipline with my
eating.\\
\verb=foodsc_7= & I am able to work effectively toward long-term health
goals.\\
\verb=foodsc_8= & Sometimes I can't stop myself from eating something, even if
I know it is bad for me.*\\
\verb=foodsc_9= & I often eat without thinking through the health
consequences.*\\
\verb=foodsc_10= & I wish I had more self-discipline in food consumption.*
\end{tabular}

The original coding is

\begin{tabular}{l@{\;=\;}c}
Very much disagree         & 1\\
Disagree                   & 2\\
Neither agree nor disagree & 3\\
Agree                      & 4\\
Very much agree            & 5
\end{tabular}

so to reverse-code the starred statements 2, 3, 4, 8, 9, and 10 we need to do
the following:
tex*/

texdoc stlog, do
recode foodsc_2  (1=5) (2=4) (4=2) (5=1)
recode foodsc_3  (1=5) (2=4) (4=2) (5=1)
recode foodsc_4  (1=5) (2=4) (4=2) (5=1)
recode foodsc_8  (1=5) (2=4) (4=2) (5=1)
recode foodsc_9  (1=5) (2=4) (4=2) (5=1)
recode foodsc_10 (1=5) (2=4) (4=2) (5=1)
texdoc stlog close

/*tex
We can then generate an index of eating self-control, \verb~foodsc~, by summing
over the statements:
tex*/

texdoc stlog, do
egen foodsc = rowtotal(foodsc_*)
summ foodsc
label var foodsc "Food self-control index (10 = lowest, 50 = highest)"
texdoc stlog close

/*tex
\subsection{Discounting}

The answer to question

\begin{quote}
``Suppose someone was going to pay you \$450 in one month. He/she
offers to pay a lower amount today. What amount today would make you just as
happy as receiving \$450 in one month?''
\end{quote}

is saved in variable \verb~q147~ and the answer to question

\begin{quote}
``Suppose someone was going to pay you \$450 in 13
months. He/she offers to pay a lower amount in 12 months. What amount in 12
months would make you just as happy as receiving \$450 in 13 months?''
\end{quote}
in variable \verb~q148~.

Calculate the implied $\beta$ and $\delta$ hyperbolic-discounting coeffients as
follows:

\begin{alignat*}{2}
&&
x_2\beta\delta^{12} &= \beta\delta^{13}450\\
\LR\quad&&
x_2 &= \delta 450\\
\LR\quad&&
\delta &= \dfrac{x_2}{450}
\intertext{and}
&&
x_1 &= \beta\delta 450\\
&&
    &= \beta x_2\\
\LR\quad&&
\beta &= \dfrac{x_1}{x_2}.
\end{alignat*}
tex*/

texdoc stlog, do
tab q147
tab q148
rename q147 x1
rename q148 x2
gen delta = x2/450
gen beta = x1/x2 if x2 > 0 & x2 < .
tab delta
tab beta
texdoc stlog close

/*tex
Set ridiculous values to missing: there were clearly some subjects who didn't
take the survey seriously.
tex*/

texdoc stlog, do
replace delta = . if x1 == 0 | x2 == 0 | x1 > 450 | x2 > 450
replace beta  = . if x1 == 0 | x2 == 0 | x1 > 450 | x2 > 450
tab delta
tab beta
label var beta  "Beta-delta present bias, slightly trimmed"
label var delta "Beta-delta discount factor, slightly trimmed"
texdoc stlog close

/*tex
The delta's of some other subjects make sense only if they were extremely
suspicious of the claims made in the questions. Generate copies of delta
and beta set to missing if they are less than 2/3.

Do not drop x1 and x2, just so I can replicate Tabar\'{e}'s slightly different
beta and delta values.
tex*/

texdoc stlog, do
gen delta2 = delta
replace delta2 = . if delta < 2/3
gen beta2 = beta
replace beta2 = . if beta < 2/3
*drop x1 x2
label var beta2  "Beta-delta present bias, heavily trimmed"
label var delta2 "Beta-delta discount factor, heavily trimmed"
texdoc stlog close

/*tex
\subsection{Calorie information preferences}

Qualtrics codes the ``At what venues do you want to know about calories in the
food (including sweets and snacks) served? Please mark all that apply.''
variable \verb~venues~ as

\begin{tabular}{l@{\;=\;}c}
When I go to a coffee shop                    & 1\\
When I go to a fast food restaurant           & 2\\
When I go to a diner                          & 3\\
When I go to a fancy restaurant               & 4\\
When I buy something to eat at a gas station  & 5\\
When I eat a meal cooked at home              & 6\\
I never want to know about calories           & 7
\end{tabular}

Subjects could make multiple choices, though, so the answer is a
comma-separated list.  Create separate dummies for each answer.
tex*/

texdoc stlog, do
mark vknwcof if regexm(venues,"1")
label var vknwcof "Want to know at coffee shops"
mark vknwfas if regexm(venues,"2")
label var vknwfas "Want to know at fast-food restaurants"
mark vknwdin if regexm(venues,"3")
label var vknwdin "Want to know at diners"
mark vknwfan if regexm(venues,"4")
label var vknwfan "Want to know at fancy restaurants"
mark vknwgas if regexm(venues,"5")
label var vknwgas "Want to know at gas stations"
mark vknwhom if regexm(venues,"6")
label var vknwhom "Want to know at home"
mark nevvknw if venues == "7"
label var nevvknw "Want to know nowhere"
drop venues
texdoc stlog close

/*tex
Also create a variable \verb~nvenues~ counting the number of venues at which
the subject wants to know.
tex*/

texdoc stlog, do
egen nvknw = rowtotal(vknw*)
tab nvknw
label var nvknw "Number of venues at which want to know"
texdoc stlog close

/*tex
Qualtrics codes the ``Do you think most people would like to know the calorie
content in food they eat away from home?'' variable \verb~othknow~ as

\begin{tabular}{l@{\;=\;}c}
Yes & 1\\
No  & 2\\
\end{tabular}

Recode this as

\begin{tabular}{l@{\;=\;}c}
Yes & 1\\
No  & 0\\
\end{tabular}

tex*/

texdoc stlog, do
recode othknow (2=0)
label var othknow "Think most others want to know"
texdoc stlog close

/*tex
Qualtrics codes the ``When do you want to know about calories in meals?''
variable \verb~youknow~ as

\begin{tabular}{l@{\;=\;}c}
Always                  & 1\\
It depends              & 2\\
Only when I'm on a diet & 3\\
Never                   & 4
\end{tabular}

If subjects chose ``It depends,'' a follow-up question ``When do you want to
know about calories in meals? Please mark all that apply.'' was asked, and the
answer, stored in variable \verb~youknow2~, coded as

\begin{tabular}{l@{\;=\;}c}
When I go out to eat to celebrate something special ...           & 1\\
When I go to a restaurant/coffee shop where I eat frequently      & 2\\
When I go to a restaurant/coffee shop where I otherwise never eat & 3\\
When I go to a restaurant/coffee shop to treat myself ...         & 4\\
When someone else takes me out to a restaurant/coffee shop        & 5
\end{tabular}

Subjects could make multiple choices for that second question, so the answer
is a comma-separated list. Create separate dummies for each answer.
tex*/

texdoc stlog, do
mark alwtknw if youknow == 1
label var alwtknw "Want to know always"
mark tknwcel if youknow == 2 & regexm(youknow2,"1")
label var tknwcel "Want to know when celebrate"
mark tknwfrq if youknow == 2 & regexm(youknow2,"2")
label var tknwfrq "Want to know at frequented venues"
mark tknwotn if youknow == 2 & regexm(youknow2,"3")
label var tknwotn "Want to know at non-frequented venues"
mark tknwtrt if youknow == 2 & regexm(youknow2,"4")
label var tknwtrt "Want to know when treat self to visit"
mark tknwels if youknow == 2 & regexm(youknow2,"5")
label var tknwels "Want to know when treated to visit"
mark ondtknw if youknow == 3
label var ondtknw "Want to know only when on diet"
mark nevtknw if youknow == 4
label var nevtknw "Want to know never"
drop youknow
texdoc stlog close

/*tex
The display logic for follow-up question ``For what meal do you want to know
about calories when you go out?'' saved in variable \verb~whatmeal~, was
unfortunately screwed up, so it is empty for all subjects.
tex*/

texdoc stlog, do
tab whatmeal
drop whatmeal
texdoc stlog close

/*tex
Also create a variable \verb~noccas~ counting the number of occasions at which
the subject wants to know.
tex*/

texdoc stlog, do
egen ntknw = rowtotal(tknw*)
label var ntknw "Number of occasions when want to know"
tab ntknw
texdoc stlog close

/*tex
Qualtrics codes the ``Sometimes people do not want to know the calorie content
of their meals when eating out. What do you think is the most common reason
people avoid calorie information when eating at a restaurant/coffee shop?''
variable \verb~avoid~ (which we accidentally didn't label with ``Mark all that
apply'') as

\begin{tabular}{l@{\;=\;}c}
They don't want to think of calories when they eat out & 1\\
Calorie information would not matter ... anyway        & 2\\
They would feel guilty ...                             & 11\\
They know the calorie content anyway                   & 4\\
They do not know how to interpret calorie information  & 5\\
I do not know                                          & 6\\
Other (please specify)                                 & 7
\end{tabular}

Generate separate dummies for each avoidance reason:
tex*/

texdoc stlog, do
mark avoithk if regexm(avoid,"1")
label var avoithk "Avoid to not think"
mark avoiirr if regexm(avoid,"2")
label var avoiirr "Avoid because irrelevant"
mark avoigui if regexm(avoid,"3")
label var avoigui "Avoid to not feel guilty"
mark avoiknw if regexm(avoid,"4")
label var avoiknw "Avoid because know already"
mark avoiint if regexm(avoid,"5")
label var avoiint "Avoid because can't interpret"
mark dknavoi if regexm(avoid,"6")
label var dknavoi "Avoid don't know why"
mark avoioth if regexm(avoid,"7")
label var avoioth "Avoid for other reason"
drop avoid
texdoc stlog close

/*tex
Only 2 subjects listed other reasons, namely
tex*/

texdoc stlog, do
local N = _N
foreach i of numlist 1/`N' {
  if avoioth == 1 {
    di avoid_7_text[`i']
  }
}
drop avoid_7_text
texdoc stlog close

/*tex
Also create a variable \verb~navoi~ counting the number of reasons given by
the subject
tex*/

texdoc stlog, do
egen navoi = rowtotal(avoi*)
tab navoi
label var navoi "Number of reasons for avoiding"
texdoc stlog close

/*tex
\subsection{Importance of healthy food}

Qualtrics codes the ``How important is it to you that the food you eat is
healthy?'' variable \verb~important_1~ as

\begin{tabular}{l@{\;=\;}c}
Not at all important & 5\\
Slightly important   & 4\\
Moderately important & 3\\
Very important       & 2\\
Extremely important  & 1
\end{tabular}

Change this to a new variable \verb~hlfdimp~ with coding

\begin{tabular}{l@{\;=\;}c}
Not at all important & 1\\
Slightly important   & 2\\
Moderately important & 3\\
Very important       & 4\\
Extremely important  & 5
\end{tabular}

tex*/

texdoc stlog, do
gen hlfdimp=important_1
tab important_1
recode hlfdimp (1=5) (2=4) (4=2) (5=1)
tab hlfdimp
label var hlfdimp "Importance of healthy food (1 = not at all, 5 = extremely)"
drop important_1
texdoc stlog close

/*tex
Also create dummies for each Likert-scale item.
tex*/

texdoc stlog, do
tab hlfdimp, generate(hlfdimp_)
texdoc stlog close

/*tex
\subsection{Importance of exercise}

Qualtrics codes the ``How important is it to you to exercise regularly?''
variable \verb~important_2~ as

\begin{tabular}{l@{\;=\;}c}
Not at all important & 5\\
Slightly important   & 4\\
Moderately important & 3\\
Very important       & 2\\
Extremely important  & 1
\end{tabular}

Change this to a new variable \verb~exerimp~ with coding

\begin{tabular}{l@{\;=\;}c}
Not at all important & 1\\
Slightly important   & 2\\
Moderately important & 3\\
Very important       & 4\\
Extremely important  & 5
\end{tabular}

tex*/

texdoc stlog, do
gen exerimp=important_2
tab important_2
recode exerimp (1=5) (2=4) (4=2) (5=1)
tab exerimp
label var exerimp "Importance of exercise (1 = not at all, 5 = extremely)"
drop important_2
texdoc stlog close

/*tex
Also create dummies for each Likert-scale item,
for the later Hosmer et al.\ (2013) analysis Step 1.
tex*/

texdoc stlog, do
tab exerimp, generate(exerimp_)
texdoc stlog close

/*tex
\subsection{Importance of weight}

Qualtrics codes the ``How important is it to you to be of a healthy body weight?''
variable \verb~important_3~ as

\begin{tabular}{l@{\;=\;}c}
Not at all important & 5\\
Slightly important   & 4\\
Moderately important & 3\\
Very important       & 2\\
Extremely important  & 1
\end{tabular}

Change this to a new variable \verb~wghtimp~ with coding

\begin{tabular}{l@{\;=\;}c}
Not at all important & 1\\
Slightly important   & 2\\
Moderately important & 3\\
Very important       & 4\\
Extremely important  & 5
\end{tabular}

tex*/

texdoc stlog, do
gen wghtimp=important_3
tab important_3
recode wghtimp (1=5) (2=4) (4=2) (5=1)
tab wghtimp
label var wghtimp "Importance of healthy weight (1 = not at all, 5 = extremely)"
drop important_3
texdoc stlog close

/*tex
Also create dummies for each Likert-scale item.
tex*/

texdoc stlog, do
tab wghtimp, generate(wghtimp_)
texdoc stlog close

/*tex
\subsection{Previous exposure to calorie info}

Qualtrics codes the ``Do you recall if [restaurants, etc., that you've been to over the
past 12 months] displayed information about calories in their food items ...''
variable \verb~prevexp~ as

\begin{tabular}{l@{\;=\;}c}
I do not recall ever seeing calories displayed ... & 1\\
I recall rarely seeing calories displayed ...      & 2\\
I recall sometimes seeing calories displayed ...   & 3\\
I recall often seeing calories displayed ...       & 4\\
I recall always seeing calories displayed ...      & 5
\end{tabular}

Stick with treating this as is as a Likert scale, but also
create dummies for each item.
tex*/

texdoc stlog, do
tab prevexp
label var prevexp "Previous info exposure (1 = never, 5 = always)"
tab prevexp, generate(prevexp_)
texdoc stlog close

/*tex
Qualtrics codes the
``On average, how often have you eaten at chain restaurants
[during the past 12 months]?''
variable \verb~chain~ and the
``On average, how often have you eaten at coffee shops
[during the past 12 months]?''
variable \verb~coffee~ as

\begin{tabular}{l@{\;=\;}c}
Every day              & 1\\
3--5 times a week      & 2\\
Once a week            & 3\\
2--3 times a month     & 4\\
Once a month           & 5\\
Less than once a month & 6
\end{tabular}

It makes more sense to reverse code these, so that higher numbers reflect a
higher likelihood of exposure, and to relabel the variables to \verb~frqcof~ and
\verb~frqchn~
tex*/

texdoc stlog, do
tab chain
recode chain  (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(frqchn)
tab frqchn
drop chain
label var frqchn "Frequenting of chain restaurants (1 = rarely, 6 = every day)"

tab coffee
recode coffee (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(frqcof)
tab frqcof
label var frqcof "Frequenting of coffee shops (1 = rarely, 6 = every day)"
drop coffee
texdoc stlog close

/*tex
Also create dummies for each Likert-scale item.
tex*/

texdoc stlog, do
tab frqchn, generate(frqchn_)

tab frqcof, generate(frqcof_)
texdoc stlog close

/*tex
\subsection{Knowledge about calories}

Qualtrics codes the ``Approximately how many calories should a moderately
active 30--40 year old man eat per day to maintain a healthy body weight?''
variable \verb~shouldeat~ as

\begin{tabular}{l@{\;=\;}c}
Around     50 calories & ?\\
Around    500 calories & 4\\
Around  1,500 calories & 1\\
Around  2,500 calories & 2\\
Around  4,000 calories & 3\\
Around  6,000 calories & 5\\
Around 10,000 calories & 6
\end{tabular}

Recode this more sensibly as follows, and shorten the variable name to
\verb~shdeat~

\begin{tabular}{l@{\;=\;}c}
Around     50 calories & 1\\
Around    500 calories & 2\\
Around  1,500 calories & 3\\
Around  2,500 calories & 4\\
Around  4,000 calories & 5\\
Around  6,000 calories & 6\\
Around 10,000 calories & 7
\end{tabular}
tex*/

texdoc stlog, do
rename shouldeat shouldeatQ
tab shouldeatQ
recode shouldeatQ (4=2) (1=3) (2=4) (3=5) (5=6) (6=7), generate(shdeat)
tab shdeat
label var shdeat "Calories a male should eat (1 = 50, 4 = 2,500, 7 = 10,000)"
drop shouldeatQ
texdoc stlog close

/*tex
Also create dummies for each Likert-scale item.
tex*/

texdoc stlog, do
tab shdeat, generate(shdeat_)
texdoc stlog close

/*tex
Rename the dummy for the correct answer, \verb~shd4~, to
\verb~knowcal~, so we can include only it to distinguish subjects
who knew the right answer from subjects who didn't.
tex*/

texdoc stlog, do
rename shdeat_4 knowcal
label var knowcal "Knows correct calorie requirement"
texdoc stlog close

/*tex
\subsection{Health status}

Qualtrics codes the
``I am in excellent health''
variable \verb~health_1~, the
``I would benefit from eating healthier''
variable \verb~health_2~, the
``I wish I could make healthier food choices at home''
variable \verb~health_3~, and the
``I wish I could make healthier food choices when eating out''
variable \verb~health_4~ as

\begin{tabular}{l@{\;=\;}c}
Very much disagree         & 1\\
Disagree                   & 2\\
Neither agree nor disagree & 3\\
Agree                      & 4\\
Very much agree            & 5
\end{tabular}

Keep the scaling, but rename these variables as follows:
tex*/

texdoc stlog, do
rename health_1 healths
label var healths "In excellent health (1 = disagree, 5 = agree)"
rename health_2 eatbshd
label var eatbshd "Should eat healthier (1 = disagree, 5 = agree)"
rename health_3 eatbhom
label var eatbhom "Want to eat healthier at home (1 = disagree, 5 = agree)"
rename health_4 eatbout
label var eatbout "Want to eat healthier out (1 = disagree, 5 = agree)"
texdoc stlog close

/*tex
Also create dummies for each Likert-scale item
tex*/

texdoc stlog, do
tab healths, generate(healths_)
tab eatbshd, generate(eatbshd_)
tab eatbhom, generate(eatbhom_)
tab eatbout, generate(eatbout_)
texdoc stlog close

/*tex
\subsection{Body weight}

Qualtrics codes the ``What best describes your body weight?'' variable
\verb~weight_descr~ as

\begin{tabular}{l@{\;=\;}c}
I am underweight   & 7\\
I am normal weight & 4\\
I am overweight    & 1\\
I am obese         & 2\\
I do not know      & 3
\end{tabular}

Recode this more sensibly as follows, and shorten the variable name to
\verb~weightd~:

\begin{tabular}{l@{\;=\;}c}
I am underweight   & 1\\
I am normal weight & 2\\
I am overweight    & 3\\
I am obese         & 4\\
I do not know      & .
\end{tabular}

Also generate separate dummies for each description:
tex*/

texdoc stlog, do
rename weight_descr weight_descrQ
tab weight_descrQ
recode weight_descrQ (7=1) (4=2) (1=3) (2=4) (3=.), generate(weightd)
tab weightd
label var weightd "Self-described weight category (1 = underweight, 5 = obese)"
drop weight_descrQ

mark unweight  if weightd == 1
label var unweight "Self-described underweight"
mark nmweight if weightd == 2
label var nmweight "Self-described normal weight"
mark ovweight   if weightd == 3
label var ovweight "Self-described overweight"
mark obweight        if weightd == 4
label var obweight "Self-described obese"
mark dkweight   if weightd == .
label var dkweight "Self-described don't know weight"
texdoc stlog close

/*tex
\subsection{Height, weight, and BMI}

Rename the height in feet and inches (\verb~height_1~ and \verb~height_2~)
variables and calculate BMI from them combined with the
weight in pounds (\verb~weight_pounds~) variable, using the formula
\begin{equation*}
\text{BMI} = \dfrac{\text{kg}}{\text{m}^2}.
\end{equation*}

tex*/

texdoc stlog, do
rename height_1 height_ft
rename height_2 height_in
rename weight_pounds weight_lb
label var weight_lb "Weight in pounds"
gen height_m = height_ft*0.3048 + height_in*0.0254
gen weight_kg = weight_lb*0.45359237
gen bmi = weight_kg/(height_m^2)
label var bmi "BMI"

sum height_m

sum weight_kg

sum bmi
list height_ft height_in weight_lb bmi if bmi < 15
texdoc stlog close

/*tex
One of the outliers is an easy fix: they simply entered their
height both in feet, as 5.7 and in inches, as 68.4.
tex*/

texdoc stlog, do
replace height_m = height_in*0.0254 if height_ft == 5.7 & height_in == 68.4
replace bmi = weight_kg/(height_m^2) if height_ft == 5.7 & height_in == 68.4
drop height_ft height_in
drop weight_lb
texdoc stlog close

/*tex
\subsection{Expenditure}

Qualtrics codes the ``In a typical month, how much do you spend on food,
housing, transportation, utilities, and other items?'' variable
\verb~expenditure~ as

\begin{tabular}{l@{\;=\;}c}
  \$400 or less    & 1\\
  \$401 --   \$600 & 2\\
  \$601 --   \$800 & 3\\
  \$801 -- \$1,000 & 4\\
\$1,001 -- \$1,200 & 5\\
\$1,201 -- \$1,400 & 6\\
\$1,401 -- \$1,600 & 7\\
\$1,601 -- \$1,800 & 8\\
\$1,801 -- \$2,000 & 9\\
\$2,000 or more    & 10\\
I'd rather not say & 11
\end{tabular}

Rename his variable \verb~expcat~ and use it to calculate a continuous
\verb~expenditure~ variable by using the midpoint of the intervals (picking
\$2,100 for the top one). Recode ``I'd rather not say'' as missing.

Also generate an \verb~expend2~ variable with
``I'd rather not say'' recoded as zero, to be used in combination with the
``I'd rather not say'' dummy generated below.
tex*/

texdoc stlog, do
rename expenditure expcat
tab expcat
gen expend = .
replace expend =  .200 if expcat ==  1
replace expend =  .500 if expcat ==  2
replace expend =  .700 if expcat ==  3
replace expend =  .900 if expcat ==  4
replace expend = 1.100 if expcat ==  5
replace expend = 1.300 if expcat ==  6
replace expend = 1.500 if expcat ==  7
replace expend = 1.700 if expcat ==  8
replace expend = 1.900 if expcat ==  9
replace expend = 2.100 if expcat == 10
replace expend =    . if expcat == 11
tab expend
label var expend "Monthly expenditure x $1000 (don't know coded as missing)"
gen expend2 = expend
replace expend2 = 0 if expend == .
label var expend2 "Monthly expenditure x $1000 (don't know coded as 0)"
texdoc stlog close

/*tex
Save the ``I'd rather not say'' category as a separate dummy \verb~expdec~ (for
``expenditure declined'')
tex*/

texdoc stlog, do
mark expdec if expcat == 11
label var expdec "Declined to state monthly expenditure"
drop expcat
texdoc stlog close

/*tex
\subsection{Income}

Qualtrics codes the ``What is your individual annual, pre-tax income?'' variable
\verb~income~ as

\begin{tabular}{l@{\;=\;}c}
  \$10,000 or less      &  1\\
  \$10,001 --  \$12,500 &  2\\
  \$12,501 --  \$15,000 &  3\\
  \$15,001 --  \$17,500 &  4\\
  \$17,501 --  \$20,000 &  5\\
  \$20,001 --  \$25,000 &  6\\
  \$25,001 --  \$30,000 &  7\\
  \$30,001 --  \$50,000 &  8\\
  \$50,001 --  \$70,000 &  9\\
  \$70,001 -- \$100,000 &  ?\\
  \$100,000+            &  ?\\
  I'd rather not say    & 10
\end{tabular}

Rename his variable \verb~inccat~ and use it to calculate a continuous
\verb~income~ variable by using the midpoint of the intervals. Recode ``I'd
rather not say'' as missing.

Also generate an \verb~income2~ variable with
``I'd rather not say'' recoded as zero, to be used in combination with the
``I'd rather not say'' dummy generated below.
tex*/

texdoc stlog, do
rename income inccat
tab inccat
gen income = .
replace income =   5.000 if inccat ==  1
replace income =  11.250 if inccat ==  2
replace income =  13.750 if inccat ==  3
replace income =  16.250 if inccat ==  4
replace income =  18.750 if inccat ==  5
replace income =  22.500 if inccat ==  6
replace income =  27.500 if inccat ==  7
replace income =  40.000 if inccat ==  8
replace income =  60.000 if inccat ==  9
replace income =      . if inccat == 10
tab income
label var income  "Annual income x $1000 (don't know coded as missing)"
gen income2 = income
replace income2 = 0 if income == .
label var income2 "Annual income x $1000 (don't know coded as 0)"
texdoc stlog close

/*tex
Save the ``I'd rather not say'' category as a separate dummy \verb~incdec~ (for
``income declined'')
tex*/

texdoc stlog, do
mark incdec if inccat == 10
label var incdec "Declined to state annual income"
drop inccat
texdoc stlog close

/*tex
\subsection{Previous knowledge of the experiment}

Qualtrics codes the ``Please let us know if before you arrived here today, you heard
anything about the type of questions we asked you in this study or about the kind of
desserts we were using.'' variable
\verb~prevknow~ as

\begin{tabular}{l@{\;=\;}c}
I heard nothing & 1\\
I heard some    & 2\\
I heard a lot   & 3
\end{tabular}

If subjects chose ``I heard some'' or ``I heard a lot,'' a follow-up question
``Please let us know specifically if you heard anything about the type of
questions we asked'' was asked, and the answer, stored in variable
\verb~prevques~, coded as

\begin{tabular}{l@{\;=\;}c}
I heard nothing about the questions & 1\\
I heard some about the questions    & 2\\
I heard a lot about the questions   & 3
\end{tabular}

Generate dummies to capture the various answer combinations.
tex*/

texdoc stlog, do
rename prevknow tmpprevknow
mark prevknow if tmpprevknow != 1
label var prevknow "Had some previous knowledge of experiment"
local knowlist "not som lot"
foreach i of numlist 2/3 {
  foreach j of numlist 1/3 {
    quietly count if tmpprevknow == `i' & prevques == `j'
    if r(N) > 0 {
      di r(N)
      di "tmpprevknow = `i', prevques = `j'"
      local know: word `i' of `knowlist'
      local ques: word `j' of `knowlist'
      mark pk`know'`ques' if tmpprevknow == `i' & prevques == `j'
      tab pk`know'`ques'
    }
  }
}
label var pksomnot "Heard some about experiment, but not questions"
label var pksomsom "Heard some about both experiment and questions"
label var pklotnot "Heard a lot about experiment, but not questions"
label var pklotlot "Heard a lot about both experiment and questions"
drop tmpprevknow
texdoc stlog close

/*tex
The display logic for then asking them ``Could you please describe exactly what
you heard before coming in?'' was screwed up (we should do display logic only
in the Survey Flow next time!), so that people who answered ``I heard nothing''
on the \verb~preknow~ question also got to answer it. Here's the list of
answers:
tex*/

texdoc stlog, do
local N = _N
foreach i of numlist 1/`N' {
  if prevques_desc[`i'] != "" {
    di prevknow[`i'] ":" prevques[`i'] ":" prevques_desc[`i']
  }
}
drop prevques
drop prevques_desc
texdoc stlog close

/*tex
\section{Save the cleaned data}
tex*/

texdoc stlog, do
save "$RUTA/temp/data/clean.dta", replace

texdoc stlog close

/*tex
\end{document}
tex*/


*** CREATE PDF *****************************************************************

! $PDFLATEX "$RUTA/code/logs/texdoc/cleanData.tex"

*** END OF DOFILE **************************************************************
********************************************************************************
