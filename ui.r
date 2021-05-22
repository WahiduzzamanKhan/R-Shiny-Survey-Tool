# creating the ui
ui <- dashboardPage(
  # start header
  dashboardHeader(title = 'Demo Survey'),
  # end header
  
  # start sidebar
  dashboardSidebar(
    sidebarMenuOutput('sidebar')
  ),
  # end sidebar
  
  # start main body
  dashboardBody(
    tags$link(href='style.css', rel='stylesheet'),
    HTML(
      "
      <script>
        $(document).on('click', '#nextTab', function(e) {
         e.stopPropagation()
         if(typeof BUTTON_CLICK_COUNT == 'undefined') {
            BUTTON_CLICK_COUNT = 1; 
          } else {
            BUTTON_CLICK_COUNT ++;
          }
          Shiny.onInputChange('js.button_clicked', 
            e.target.id + '_' + BUTTON_CLICK_COUNT);
        });
      </script>
      "
    ),
    uiOutput('mainBody')
  )
  # end main body
)