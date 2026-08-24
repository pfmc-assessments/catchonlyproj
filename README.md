# catchonlyproj

Template quarto file that can be used to generate catch-only projection reports.  The user will need to update the title, author, and  `params` 
in the YAML based upon their project.  Additionally, the directory needs to be specified to locate the Stock Synthesis model run to generate the 
report for.  

## Install packages

Install the package using:

```r
pak::pak("pfmc-assessments/catchonlyproj")
library(catchonlyproj)
```

Creating a quarto file based on the template for your catch-only projection
can be done by running the following code:

```r
# Create a empty folder for the template:
create.dir("C:/assessments/2027/cop_my_species")

quarto::quarto_use_template("pfmc-assessments/catchonlyproj/template")
```
