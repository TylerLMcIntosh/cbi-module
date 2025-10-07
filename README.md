# Project:

## Description & Key Links

Explain here

**Note that key tools used for this project include: R & Python**

## Contributors

Tyler L. McIntosh

## Project Structure
```text
my-project/
├── code/               # Notebooks and scripts (R, Python, Quarto)
├── config/             # Configuration files, env settings
│   └── secrets/        # API keys or service accounts (not tracked)
├── data/               # Raw and derived datasets
│   ├── raw/
│   └── derived/
├── figs/               # Figures and plots
├── results/            # Model outputs and reports
├── utils/              # Reusable helper functions (R and Python)
│   └── cyverse-utils/  # Helper functions and information for CyVerse use
├── .gitignore
├── LICENSE
├── README.md
└── .Rproj
```


## Instructions for collaborators and reproduction
- Place raw data in data/raw/ and processed data in data/derived/
- Store any personal or project credentials in config/secrets/ (excluded from Git)
- As code becomes irrelevant, move any deprecated scripts to code/deprecated/
- To create and activate the Python environment, run the following in a terminal:
```
conda env create -f config/environment.yaml
conda activate myenv
```
Or, to update an environment of the same name:
```
conda env update --name macrosystems --file config/environment.yml
```




