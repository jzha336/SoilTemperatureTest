# scripts/ folder: for R scripts

*Suggestions for best practices when creating and writing R scripts to ensure readability and maintainability:*  

---

Checklist:

- [ ] &nbsp;&nbsp;&nbsp;Recommended Naming System for Multiple Scripts
- [ ] &nbsp;&nbsp;&nbsp;Use the `here` package for File Linking
- [ ] &nbsp;&nbsp;&nbsp;Details About Calling Files from PowerPlant

---

## 1. File naming conventions

*Standarised format of R script names*

- File names should be in lowercase and `_` for separating words. 
- If files should be run in a particular order, prefix them with numbers. 
 

### Examples:

```r
# Good
fit_models.R
00_process_data.R

# Bad
code.r
fit model.R
```

## 2. Use the `here` package to link to files within this repository

*The `here` package enables easy file referencing by using the top-level directory of a file project to easily build file paths.*

### Examples

```r
library(here)
source(here("R/helper_functions.R"))
```

## 3. Work with files on powerplant

### Examples:

```r
# If working on powerplant:
data_file <- "/input/projects/rds-starter/palmerpenguins_raw.csv"

# If not working on powerplant:
data_file <- "https://storage.powerplant.pfr.co.nz/input/projects/rds-starter/palmerpenguins_raw.csv"
```

## 4. More readings

- [R Coding Style Best Practices](https://www.datanovia.com/en/blog/r-coding-style-best-practices/)
- [here](https://cran.r-project.org/web/packages/here/vignettes/here.html)

