# loading packages
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(readxl)
library(stringr)
library(tidyr)
library(dplyr)
library(DT)
library(shinyjs)

# function to create a custom time input
timeInput <- function(inputId, label, time=NULL, min = NULL, max = NULL){
  tagList(
    HTML(paste0("<label for='",inputId,"'class = 'timeInputLabel'>", label, "</label><br/>")),
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