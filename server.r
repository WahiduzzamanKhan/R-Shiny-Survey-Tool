# loading packages
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(readxl)
library(stringr)
library(shinyTime)
library(tidyr)
library(dplyr)
library(DT)

server <- function(input, output, session){
  
  # reading the questionnaire file
  rawQues <- read_excel('questions.xlsx', sheet = 'questions')
  
  # creating vector of module names
  modules <- unique(rawQues$Module)
  
  # function to create a list of divs for each question in a module
  questionsDivList <- function(moduleName, last = modules[length(modules)]){
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
    if(moduleName==last){
      qList[[nrow(q)+1]] <- div(
        actionBttn(
          inputId = "submit",
          label = "Submit",
          style = "jelly", 
          color = "primary"
        ),
        class = 'submitDiv'
      )
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
    
    tabItemList[[length(tabItemList)+1]] <- tabItem(
      tabName = 'results',
      DTOutput('datatable')
    )
    
    do.call(tabItems, tabItemList)
  })
  
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
  
  varNames <- as.character()
  for(module in modules){
    for(i in 1:length(which(rawQues$Module==module))){
      varNames <- append(varNames, paste0(module, i))
    }
  }
  newData <- data.frame(names = varNames, value = NA) %>% spread(key = names, value = value)
  newData <- newData[-1,]
  
  if(file.exists("data.csv")==T) {
    older <- read.csv("data.csv", header = T, sep = ',')
  }else {
    write.csv(newData, file = "data.csv", row.names=F)
    older <- read.csv("data.csv", header = T, sep = ',')
  }
  
  observeEvent(
    input$submit,
    {
      for(name in varNames){
        newData[1, name] <- ifelse(is.null(input[[name]]), NA, input[[name]])
      }
      
      older[nrow(older)+1,] <- newData[1,]
      write.csv(older, file = 'data.csv', row.names = F)
      output$datatable <- renderDT(
        datatable(
          data = newData,
          style = 'bootstrap',
          class = 'compact stripe row-border hover',
          filter = 'none',
          selection = 'single',
          options = list(
            ordering = TRUE,
            info = TRUE,
            bLengthChange = FALSE,
            searching = TRUE
          ),
          extensions = list('Responsive'=NULL),
          width = '100%'
        )
      )
      
      # creating the sidebar menu
      output$sidebar <- renderMenu({
        sidebarMenu(
          menuItem(
            text = 'Results',
            tabName = 'results'
          ),
          HTML(
            "
            <button id='submitAnother' class='action-btn'>Submit another</button>
            "
          )
        )
      })
      
    }
  )
  
}