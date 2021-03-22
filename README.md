# Expecting to get it: An endowment effect for information

_[Tabaré Capitán](http://tabarecapitan.com/), Linda Thunström, Klaas van ‘t Veld, and Jonas Nordström_

<details>
  <summary>See abstract</summary>

  > In this paper we predict and find evidence for an “endowment effect for information”—a tendency to value information more if getting the information is expected than if it is not expected. We show that the two leading theories of expectations-based reference-dependent preferences imply such an endowment effect, and find evidence supporting this prediction in an experiment that manipulates participants’ expectations. The effect implies that the net benefits from information policies may vary with people’s expectations:  consumers  who  regularly  see  information  about  the  calories  in  their food, the energy use of their appliances, or the carbon footprint of their flights may come to expect access to such information and then end up valuing it more.
  >
  > _JEL codes_: D01, D80, D83, D84, D91, C91
  >  
  > _Keywords_: expectations,  reference-dependent  preferences,  preferences  for  information, information avoidance, endowment effect, welfare analysis

</details>

<!-- FIX LINK TO PAPER -->
We provide this repository to complement our [research article](http://tabarecapitan.com/jmp/). We include both the raw data and the code to run the analyses reported in the article.


## Materials

We collected data from our experiment using Qualtrics.

In `./analysis/rawData/`:

- `questionnaire_qualtrics.pdf`
- `questionnaire_qualtrics.qsf`

## Data

We include the raw data (as downloaded from qualtrics) and a codebook describing the meaning of each value in the variables of the dataset.

In `./analysis/rawData/`:

- `data.csv`
- `codebook.xlsx`

## Code

We use Stata 14.2 (SE) to conduct all analyses. The file main.do controls the execution of the rest of the files. To execute `main.do`, a specific folder structure is assumed (see Replication instructions below).

In `./analysis/code/`:

- `main.do`
  - `settings.do`
  - `installNewPrograms.do`
  - `importData.do`
  - `cleanData_texdoc.do`
  - `descriptiveStatistics.do`
  - `identifyLargeDifferences.do`
    - `balanceMeasures.ado`
  - `treatmentEffects_binaryDepVar.do`
  - `treatmentEffects_continuousDepVar.do`

## Replication instructions

We want our work to be replicated. To that end, we include **one** script to replicate our research. The easiest way to replicate is to download the folder "analysis", edit  `run.do`, and run it (assuming the right software is installed).

### Required software
- Stata (we use SE 14.2)
- LaTeX (to create LaTeX document describing data cleaning)

### Required folder structure
```bash
analysis
├── rawData
│   └── data.csv
├── code
│   ├── main.do
│   ├── installNewPrograms.do
│   └── ...
└── run.do
```

### Editing `run.do`

- In line 27, add your local path to global macro `RUTA`
- In line 31, add your pdflatex path to global macro `PDFLATEX`

### Description of `run.do` file

1. Header
2. Define project path
3. Define pdflatex path
4. Record system parameters
5. Set adopath to download user-written programs
6. Create directories for output files
7. Run analysis (call `main.do`)


## Citation

[To be updated once we publish the paper]

## Questions?

- Open github issue
- Send me an email
