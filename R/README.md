# R/ folder: for helper functions

*Suggestions for best practices when writing functions*  

*Writing clean, efficient, and well-documented functions is essential for maintaining readable, reusable, and reliable code. Here are some tips and tools to follow when writing functions:*

---

Checklist:

- [ ] &nbsp;&nbsp;&nbsp;Roxygen-style documentation  
- [ ] &nbsp;&nbsp;&nbsp;When using a function from a package, write it like package::function() e.g., janitor::clean_names()  
- [ ] &nbsp;&nbsp;&nbsp;Tidyverse style (maybe specific sections)  
- [ ] &nbsp;&nbsp;&nbsp;Recommended packages

---

## 1. Roxygen-style documentation

*Standarised format of writing functions*

[Roxygen2 tutorial](https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html)  
[Roxygen2 function documentation in R packages](https://r-pkgs.org/man.html)  
[Roxygen2 documentation](https://roxygen2.r-lib.org/)  

### Example of roxygen-style documentation:

```r
#' Title: add up two values.
#'
#' Description: this function takes two numbers as input and returns their sum.
#'
#' @param a a numeric value.
#' @param b a numeric value.
#'
#' @return the sum of `a` and `b`.
#' @examples
#' add_numbers(5, 10)
#' @export
add_numbers <- function(a, b) {
  return(a + b)
}
```

### Key Roxygen tags:
@param: describe each function argument.  
@return: describe what the function returns.  
@examples: provide usage examples.  
@export: indicates the function should be exported in a package.  

The devtools::document() function can parses the Roxygen2 comments in your R scripts and converts them into formal R documentation files.



---


## 2. Tidyverse style

*Writing clean, consistent, and readable R code*

[Tidyverse tutorial](https://style.tidyverse.org/index.html)  
[Tidyverse website](https://www.tidyverse.org/)  

**Function names** use lowercase words separated by underscores (e.g., add_numbers), and use named arguments in function.

**Argument names** use clear, descriptive names 
&ensp; good: sugar_contents, weight  
&ensp; bac: x, y  

**Default arguments** use default argument/values in complex functions, and avoid hardcoding them inside the function:  

```r
calculate_mean <- function(x, na.rm = TRUE) {
  mean(x, na.rm = na.rm)
  }
  # this function remove NA from the calculation by default
```

**Return values** it makes code easier to follow and debug to avoid deeply nested if-else blocks and returning earlier

```r
check_positive <- function(x) {
  if (x <= 0) {
    return("Value is not positive")
  }
  return("Value is positive")
}
```

**Keep function short** by breaking long functions into smaller ones.  

**Avoid side effects** where a function modifies global variables, writes to external files, or causes changes outside its own scope, which can lead to unexpected behavior and bug.



---


## 3. Recommended packages

**here**: The `here` package simplifies file path management in R projects by providing a relative path reference that works across environments. [here](https://here.r-lib.org/)  

**tidyverse (readr, ggplot2, dplyr, tidyr, purrr)**: The `tidyverse` is a collection of R packages designed for data science, including tools for data manipulation, visualisation, and analysis. [tidyverse](https://www.tidyverse.org/)  

**janitor**: The `janitor` package provides simple functions for cleaning and organizing data, such as removing empty rows or cleaning column names. [janitor](https://sfirke.github.io/janitor/index.html)  

**pak**: The `pak` package helps with installing and managing R packages. [pak](https://r-lib.r-universe.dev/pak)  

**renv**: The `renv` is used for managing project-specific package environments, improving reproducibility. [renv](https://rstudio.github.io/renv/articles/renv.html)

**readxl**: Import Excel files into R. [readxl](https://readxl.tidyverse.org/)

**targets**: The `targets` package is a pipeline tool for managing workflows, making it easier to build reproducible and scalable data analysis. [targets](https://books.ropensci.org/targets/)

**assertr**: The assertr package provides a set of tools to verify assumptions about data early in an analysis pipeline so that data errors are spotted early and can be addressed quickly. [assertr](https://docs.ropensci.org/assertr/)





