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

The quarto file (qmd file extension) should be edited in a number of places to  
customize the report for a specific catch-only projection. Here are the items
that should be modified:

1. Customize the species name in the title line.

```
title: 'Population projections and harvest specifications for canary rockfish (\textit{Sebastes pinniger}) based on recent catches, updating projections from the 2023 stock assessment' 
```

2. Update the author name and affiliations.

```
author:  
  - name: 'Chantel Wetzel'  
    affiliations:  
      - name: 'NOAA Fisheries Northwest Fisheries Science Center'  
        address: '2725 Montlake Boulevard East'  
        city: 'Seattle, WA'  
        state: 'WA'  
        postal-code: '98112-2097'  
```

3. Authors at the Southwest Fisheries Science Center, should also modify the 
`_titlepage.tex` file found in the `support_files` folder. Authors at the 
Northwest Fisheries Science Center can skip this step.

```
U.S. Department of Commerce\newline
National Oceanic and Atmospheric Administration\newline
National Marine Fisheries Service\newline
Northwest Fisheries Science Center\newline
```
This can be found at the bottom of the file.

4. Customize the parameters (`params`) defined in the `yaml` area of the quarto
file.

```
params:
  model_dir: "C:/Assessments/2026/cop_template/models"
  species: "canary rockfish"
  category: 1
  sigma: 0.50
  p_star: 0.45
  spawn_output_units: "(millions of eggs)"
  sb_decimal_number: 0
  hl_decimal_number: 0
```
The `model_dir` is the directory where each of the model runs being summarized are
located. The `category`, `sigma`, and `p_star` are the category designation, the
scientific uncertainty value based on the category, and the management risk tolerance.
These parameters are used in the text. They are not used to calculate the buffer
values between the OFL and ABC. This information is pulled from the model forecast
files within the package code functions. The `spawn_output_units` is the unit of
spawning output/biomass and is used in the document text. The `sb_decimal_number`
and `hl_decimal_number` are the number of decimals to include in the projection
table for spawning output/biomass and the OFL/ABC/ACL values, respectively.

5. Modify the model folder names located within the `model_dir`, defined in the 
parameter section of the yaml, to read in the original model (called `base_model`
in the example below) and the revised projection model (called the `cop_model` below)
in the `model` code chunk located at the top of the quarto file.

```
#| label: model
#| warning: false
#| message: false
base_model_table <- catchonlyproj::get_output_table(
  dir = file.path(params$model_dir, "stock_assessment_model")
)
cop_model_table <- catchonly::projget_output_table(
  dir = file.path(params$model_dir, "cop_model")
)
```

6. Review and edit the text in the quarto file, as needed.

7. Review and edit the table caption text (located in the `caption` code chunk),
as needed.

8. If only one alternative catch-only projection run is being conducted, no 
further edits are needed. If there are multiple alternative catch-only 
projections being conducted, add code to read in the additional models, add
code to combine the base model and the alternative run, add new caption
code chunk with revised text and label, and add new table code chunk with revised label.

```{r}
#| label: model
#| warning: false
#| message: false

base_model_table <- catchonlyproj::get_output_table(
  dir = file.path(params$model_dir, "stock_assessment_model")
)
cop_model_table <- catchonly::projget_output_table(
  dir = file.path(params$model_dir, "cop_model_1")
) 
cop_model_table_option_2 <- catchonly::projget_output_table(
  dir = file.path(params$model_dir, "cop_model_2")
)
```

```{r}
#| label: tbl-combine
#| eval: true
#| warning: false
#| message: false

combined_table <- catchonly::combine_tables(
  base_model_table = base_model_table$projection_values,
  cop_model_table = cop_model_table$projection_values,
  assess_year = assess_year
)

combined_table_option_2 <- catchonly::combine_tables(
  base_model_table = base_model_table$projection_values,
  cop_model_table = cop_model_table_option_2$projection_values,
  assess_year = assess_year
)
```

```{r}
#| label: caption-2
#| eval: true
#| warning: false
#| message: false

table_caption <- glue::glue("Original {assess_year} projection and new catch-only projection for OFLs (mt), buffer, ABCs (mt), actual & assumed catch (mt), ACLs (mt), {spawn_text} {params$spawn_output_units}, and stock status (fraction of unfished {spawn_text}) given the removals. The gray shading indicates values associated with the original {assess_year} assessment projection. In both the original model and the new projection, the removals for years beyond the values in the 'Actual & Assumed Removals' columns are the ACL values estimated from that model.")

```


```{r}
#| label: tbl-proj-2
#| eval: true
#| warning: false
#| message: false
#| tbl-cap: !expr table_caption

catchonly::format_table(
  table = combined_table_option_2,
  assess_year = assess_year,
  sb_decimal_number = params$sb_decimal_number,
  hl_decimal_number = params$hl_decimal_number
)
```

**Note that each example code chunk above, removed the `echo` line in order for the
code to be shown here. The `echo: false` should be retained in the quarto file 
to prevent the code from being shown in the rendered pdf.**
