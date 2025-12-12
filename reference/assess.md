# Assess

Calculate all assessments from the \`catalogue\`.

## Usage

``` r
assess(data = NULL, name = NULL, catalogue = NULL, ...)
```

## Arguments

- data:

  Dataframe of variables in hera inter-change format by default
  including columns for sample_id, question, response, label and
  parameter. See \`demo_data\` for example. This is specific for each
  assessment is held in \`catalogue\` data frame 'data' column for
  requirements. For details of optional columns and requirements of
  specific assessment, see refer to the vignettes.

- name:

  Limit the assessments calculated by name(s) see \`catalogue\` name
  column. By default all assessments are run and if relative input data,
  the function will return output. Where there is no relative data, no
  output will be returned.

- catalogue:

  Dataframe of assessments by default the built-in \`catalogue\` is
  used. But if developing new assessments a custom assessment dataframe
  could be used.

- ...:

  Other arguments passed on to methods. This optional parameters is only
  for testing. The DARLEQ3 assessment uses an option \`metric\` argument
  by default this is ""TDI5LM".

## Value

Dataframe of assessments

## Details

`assess()` assess

## Examples

``` r
if (FALSE) { # \dontrun{
assessments <- assess(hera::demo_data)
selected_assessments <- assess(hera::demo_data, c("RICT", "DARLEQ3"))
} # }
```
