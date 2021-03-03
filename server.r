# loading packages
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(readxl)
library(stringr)
library(shinyTime)

server <- function(input, output, session){
  
  # reading the questionnaire file
  rawQues <- read_excel('questions.xlsx', sheet = 'questions')
  
  # creating vector of module names
  modules <- unique(rawQues$Module)
  
  # creating the sidebar menu
  output$sidebar <- renderMenu({
    sidebarMenu(
      lapply(modules, function(module){
        menuItem(
          text = module,
          tabName = str_replace_all(module, pattern = ' ', replacement = '_')
        )
      })
    )
  })
  
  # function to create a list of divs for each question in a module
  questionsDivList <- function(moduleName){
    q <- rawQues[rawQues$Module==moduleName,]
    qList <- list()
    for (i in 1:nrow(q)){
      if(q$Type[i]=='closed'){
        qList[[i]] <- div(
          prettyRadioButtons(
            inputId = paste0(moduleName, i),
            label = q$Question[i], 
            choices = strsplit(q$Options[i], split = ',')[[1]],
            icon = icon("check"), 
            bigger = TRUE,
            status = "info",
            animation = "jelly",
            inline = FALSE
          ),
          class = 'questionDiv'
        )
      }
      else if(q$Type[i]=='numeric'){
        qList[[i]] <- div(
          numericInput(
            inputId = paste0(moduleName, i),
            label = q$Question[i],
            min = as.numeric(strsplit(q$Options[i], split = ',')[[1]][1]),
            max = as.numeric(strsplit(q$Options[i], split = ',')[[1]][2]),
            value = as.numeric(strsplit(q$Options[i], split = ',')[[1]][3]),
            width = '100%'
          ),
          class = 'questionDiv field'
        )
      }
      else if(q$Type[i]=='string'){
        qList[[i]] <- div(
          textInput(
            inputId = paste0(moduleName, i),
            label = q$Question[i],
            value = NA
          ),
          class = 'questionDiv field'
        )
      }
      else if(q$Type[i]=='date'){
        qList[[i]] <- div(
          dateInput(
            inputId = paste0(moduleName, i),
            label = q$Question[i],
            format = 'dd-mm-yyyy',
            min = strsplit(q$Options[i], split = ',')[[1]][1],
            max = strsplit(q$Options[i], split = ',')[[1]][2]
          ),
          class = 'questionDiv field'
        )
      }
      else if(q$Type[i]=='date-range'){
        qList[[i]] <- div(
          dateRangeInput(
            inputId = paste0(moduleName, i),
            label = q$Question[i],
            min = strsplit(q$Options[i], split = ',')[[1]][1],
            max = strsplit(q$Options[i], split = ',')[[1]][2]
          ),
          class = 'questionDiv field'
        )
      }
      else if(q$Type[i]=='time'){
        qList[[i]] <- div(
          timeInput(
            inputId = paste0(moduleName, i),
            label = q$Question[i],
            value = Sys.time()
          ),
          class = 'questionDiv field'
        )
      }
    }
    return(qList)
  }
  
  # creating the main body where the questions will be shown
  output$mainBody <- renderUI({
    tabItemList <- lapply(
      modules, function(module){
        tabItem(
          tabName = str_replace_all(module, pattern = ' ', replacement = '_'),
          fluidRow(
            column(width = 3),
            column(
              width = 6,
              questionsDivList(module)
            ),
            column(width = 3)
          )
        )
      }
    )
    do.call(tabItems, tabItemList)
  })
  # output$mainBody <- renderUI({
  #   tabItemList <- list()
  #   for (i in length(modules)) {
  #     if(i!=length(modules)){
  #       tabItemList[[i]] <- tabItem(
  #         tabName = str_replace_all(modules[i], pattern = ' ', replacement = '_'),
  #         fluidRow(
  #           column(width = 3),
  #           column(
  #             width = 6,
  #             questionsDivList(modules[i])
  #           ),
  #           column(width = 3)
  #         )
  #       )
  #     }
  #     else {
  #       tabItemList[[i]] <- tabItem(
  #         tabName = str_replace_all(modules[i], pattern = ' ', replacement = '_'),
  #         fluidRow(
  #           column(width = 3),
  #           column(
  #             width = 6,
  #             questionsDivList(modules[i]),
  #             actionBttn(
  #               inputId = 'submit',
  #               label = 'SUBMIT'
  #             )
  #           ),
  #           column(width = 3)
  #         )
  #       )
  #     }
  #   }
  #   do.call(tabItems, tabItemList)
  # })
  
}