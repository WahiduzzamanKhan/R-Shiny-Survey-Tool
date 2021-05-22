# loading packages
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(readxl)
library(stringr)
library(tidyr)
library(dplyr)
library(DT)

# function to create a custom time input
timeInput <- function(inputId, label, time=NULL, min = NULL, max = NULL){
  tagList(
    tags$head(tags$script(
      paste0("$(document).on('shiny:connected', function() {", "Shiny.onInputChange('", inputId, "', String(document.getElementById('", inputId, "').value));",  "$(document).on('input', 'input#", inputId, "',function(){var time = String(document.getElementById('", inputId, "').value);Shiny.onInputChange('", inputId, "', time);});});")
    )),
    HTML(paste0("<label for='",inputId,"'>", label, "</label>")),
    tags$input(
      type = "time",
      id = inputId,
      value = ifelse(!is.null(time), time, ""),
      min = ifelse(!is.null(min), min, ""),
      max = ifelse(!is.null(max), max, ""),
      class = "timeInput",
    ),
    HTML(ifelse(
      !is.null(min) | !is.null(max),
      "<span class='validity'></span>",
      ""
    ))
  )
}
