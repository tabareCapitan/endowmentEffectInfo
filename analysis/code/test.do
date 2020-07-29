texdoc init "$RUTA/code/logs/texdoc/aaa.tex", replace

/***
\documentclass[a4paper]{article}
\usepackage{stata}
\begin{document}

\section*{Exercise 1}
Open the 1978 Automobile Data and summarize the variables.

***/

texdoc stlog
sysuse auto
summarize
texdoc stlog close

/***

\section*{Exercise 2}
Run a regression of price on milage and weight.

***/

texdoc stlog
regress price mpg weight
texdoc stlog close

/***

\end{document}
***/

! "C:\texlive\2019\bin\win32\pdflatex" "$RUTA/code/logs/texdoc/cleanData.tex"



texdoc do "C:\Users\Tabare\Desktop\klaas\beforeBogota\getcleandata.do"
