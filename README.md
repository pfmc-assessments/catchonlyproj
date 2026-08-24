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

This package uses `quarto` for creating pdf documents. In order to render to a 
pdf from a quarto file the following package needs to be installed:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

After this completes running you can verify install with the following 
R command:

```r
tinytex::is_tinytex()
```

## Creating a catch-only projection template

Creating a quarto file based on the template for your catch-only projection
is easy to do. 

First create a empty directory folder where you want to save the template and 
resulting rendered pdf document. This folder needs to be empty.

```r
create.dir("C:/assessments/2027/cop_my_species")
```

Once the folder is created run the following command in your R terminal:

```r
quarto::quarto_use_template(
 template = "pfmc-assessments/catchonlyproj/template",
 dir = "C:/assessments/2027/cop_my_species"
)
```

After running this command you should have a `qmd` file and a folder called
`support_files` in the specified directory location. The files in the 
`support_files` folder set the formatting of the document and do not need to 
be edited. 

## Editing the catch-only projection template

The quarto file (qmd file extension) should be edited in specific places to customize 
the report for a specific catch-only projection.

