# import libraries
library(shiny)
library(ggplot2)
library(plotly)
library(shinydashboard)
library(DT)
library(PerformanceAnalytics)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(dygraphs)
# avoid warnings
options(warn=-1)

# read data and change data
data <- read.csv("Google_app_after_cleaning.csv", header=T)
data$Last.Updated <- as.Date(data$Last.Updated,'%Y-%m-%d')
data$Profit <- data$Price*data$Installs
# read review dataset
review_data <- read.csv('Google_review_after_cleaning.csv',header=T)
# merge two datasets
merge_df <- merge(data, review_data, by.x="App", by.y="App")
apps <- unique(merge_df[merge_df$Installs==50000,]$App) # popular apps


# Define UI for application
ui <- dashboardPage(
  # create a dashboard
  dashboardHeader(title = "Analysis on Apps"),
  dashboardSidebar(
    sidebarMenu(
      menuItem('View the data',tabName = 'view_data',icon = icon('table')),
      menuItem('Category',tabName = 'category',icon = icon('th')),
      menuItem('Last Updated Time',tabName = 'last_updated_time',icon=icon('line-chart')),
      menuItem('Numeric Features',tabName = 'numeric',icon=icon('line-chart')),
      menuItem('Word Cloud for popular apps',tabName = 'review_app',icon=icon('th'))
    )
  ),
  dashboardBody(
    tabItems(
      # view data part
      tabItem(tabName = 'view_data',
        fluidPage(
          titlePanel("The distribution of installs for two types of apps"),
          # boxplot
          fluidRow(
            mainPanel(
              plotlyOutput("boxPlot",width=1000,height=500),
              textOutput('explanation')
            )
          ),
          # checkbox for type of apps
          titlePanel("Examples of DataTables"),
          checkboxGroupInput("type1", "Choose the type of apps to view on Apps Data:",
              c("Free apps" = "Free","Paid apps" = "Paid"), selected="Free"),
          helpText('Click the type of apps you want to show in apps dataset.'),
          # show dataset (give condition to show different columns)
          sidebarLayout(
             sidebarPanel(
                conditionalPanel('input.dataset == "AppsData"',
                  checkboxGroupInput("app_columns", "Columns in Apps Data to show:",
                                         names(data), selected = names(data))
                  ),
                conditionalPanel('input.dataset == "AppsReviewData"',
                  checkboxGroupInput("review_columns", "Columns in Apps Review Data to show:",
                                         names(review_data), selected = names(review_data))
                  )
              ),
              mainPanel(
                  tabsetPanel(
                      id = 'dataset',
                      tabPanel('AppsData',DT::dataTableOutput('mytable1')),
                      tabPanel('AppsReviewData',DT::dataTableOutput('mytable2'))
                  )
              )
          )
        )
      ),
      # category part
      tabItem(tabName = 'category',
        fluidPage(
          titlePanel("Analysis on Category feature"),
          checkboxGroupInput("type2", "Choose the type of apps:",
                      c("Free apps" = "Free",
                        "Paid apps" = "Paid"),selected="Free"),
          helpText('Click the type of apps you want to show for analysis.(this type is selected for all graphs)'),
          mainPanel(
              plotlyOutput("piePlot",width=1000,height=800),
              plotlyOutput('linePlot',width=1000),
              plotlyOutput('scatterPlot',width=1000)
            )
        )
      ),
    # last_updated_time part
    tabItem(tabName = 'last_updated_time',
            fluidPage(
              titlePanel("Analysis on Last_Updated_Time"),
              checkboxGroupInput("type3", "Choose the type of apps for analysis:",
                                 c("Free apps" = "Free",
                                   "Paid apps" = "Paid"), selected="Free"),
              helpText('Click the type of apps you want to show for analysis.(this type is selected for all graphs)'),
              
              sidebarLayout(
                sidebarPanel(
                  helpText("You can select the date range to view the plot, then click and drag to zoom in (Drag the slider on the time axis, double click to zoom back out)."),
                  br()
                ),
                mainPanel(dygraphOutput("timePlot"))
              )
            )
      ),
    # numeric features part
    tabItem(tabName = 'numeric',
            fluidPage(
              titlePanel("Analysis on Numeric features"),
              sidebarLayout(
                sidebarPanel(
                  h2('Correlation Matrix'),
                  checkboxGroupInput("type4", "Choose the type of apps for analysis:",
                                     c("Free apps" = "Free",
                                       "Paid apps" = "Paid"), selected="Free"),
                  helpText('Click the type of apps you want to show for analysis.(this type is selected for all graphs)')
                ),
                mainPanel(plotOutput('correlation'))
              ),
              
              sidebarLayout(
                sidebarPanel(
                  # Set input of coral types
                  selectInput("feature", "Select the feature to analyze: ", 
                              c("Rating (overall user rating)" = "Rating", 
                                "Reviews (number of user reviews)" = "Reviews",
                                "Size (size of the app)" = "Size")
                  )
                ),
                mainPanel(
                  plotlyOutput("numericPlot")
                )
              )
            )
      ),
    # word cloud for reviews
    tabItem(tabName = 'review_app',
            fluidPage(
              
              titlePanel("Word Cloud for popular apps"),
              sidebarLayout(
                sidebarPanel(
                  
                  selectInput("app","Choose an app(from most popular apps): ",
                              choices = apps),
                  helpText('Click the app name you want to visualize. (number of installations of these apps are 50,000)'),
                  hr(),
                  sliderInput("freq",
                              "Minimum Frequency:",
                              min = 1, max = 50, value = 15),
                  helpText('Drag to choose the minimum frequency'),
                  sliderInput('words',
                              'Maximum Number of Words:',
                              min = 1, max = 300, value = 100),
                  helpText('Drag to choose the maximum number of words.')
                ),
                mainPanel(
                  plotOutput('word_cloud')
                )
              )
            )
      )
    )
  )
)

# Define server logic required 
server <- function(input, output) {
  # view data output
  output$boxPlot <- renderPlotly({
    p <- ggplot(data, aes(x=Type,y=Installs)) + geom_boxplot() +
      ylab('Number of Installs') + ggtitle('The number of installs between two types of apps')
    ggplotly(p)
  })
  output$explanation <- renderText({
    "Explanation: The boxplot to present aims to present the different distribution 
                       of number of installs for different type of apps. Based on this, this 
    project regard number of installs as profit for free apps and 
    regard the product of price and number of installs as profit for paid apps for later analysis"
  })
  output$mytable1 <- DT::renderDataTable({
    DT::datatable(data[data$Type==input$type1,input$app_columns,drop=FALSE],
                  options = list(scrollX = TRUE,scrollY = "400px"))
  })

  output$mytable2 <- DT::renderDataTable({
    DT::datatable(review_data[,input$review_columns,drop=FALSE],
                  options = list(scrollX = TRUE,scrollY = "400px"))
  })
  
   # category output
   output$piePlot <- renderPlotly({
     category_freq <- as.data.frame(table(data[data$Type==input$type2,2]))
     p <- plot_ly(category_freq, labels = ~Var1, values = ~Freq, type = 'pie') %>%
       layout(title = 'Category Distribution',
              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
     p
   })
   
   output$linePlot <- renderPlotly({
     if ("Free" %in% input$type2) {        # identify which type to visualize
       avg_category <- aggregate(data[data$Type==input$type2, 6], 
                                 by=list(Category=data[data$Type==input$type2,2]), 
                                 FUN=mean)
       colnames(avg_category) <- c('Category','Average_Profit')
       p <- plot_ly(avg_category, x= ~ Category, y = ~ Average_Profit, type='scatter',mode='lines') %>%
         layout(title = 'Average Profit distribution for each category')
       p
     }
     else {
       avg_category <- aggregate(data[data$Type==input$type2, 14], 
                                 by=list(Category=data[data$Type==input$type2,2]), 
                                 FUN=mean)
       colnames(avg_category) <- c('Category','Average_Profit')
       p <- plot_ly(avg_category, x= ~ Category, y = ~ Average_Profit, type='scatter',mode='lines') %>%
         layout(title = 'Average Profit distribution for each category')
       p
     }
   })
   
   output$scatterPlot <- renderPlotly({
     if ("Free" %in% input$type2) {
       sum_category <- aggregate(data[data$Type==input$type2, 6], 
                                 by=list(Category=data[data$Type==input$type2,2]), 
                                 FUN=sum)
       colnames(sum_category) <- c('Category','Overall_Profit')
       p <- plot_ly(sum_category, x= ~ Category, y = ~ Overall_Profit, type='scatter',
                    marker = list(size = 10,
                                  color = 'rgba(255, 182, 193, .9)',
                                  line = list(color = 'rgba(152, 0, 0, .8)',
                                              width = 2))) %>%
         layout(title = 'Overall Profit distribution for each category')
       p
     }
     else {
       sum_category <- aggregate(data[data$Type==input$type2, 14], 
                                 by=list(Category=data[data$Type==input$type2,2]), 
                                 FUN=sum)
       colnames(sum_category) <- c('Category','Overall_Profit')
       p <- plot_ly(sum_category, x= ~ Category, y = ~ Overall_Profit, type='scatter',
                    marker = list(size = 10,
                                  color = 'rgba(255, 182, 193, .9)',
                                  line = list(color = 'rgba(152, 0, 0, .8)',
                                              width = 2))) %>%
         layout(title = 'Overall Profit distribution for each category')
       p
     }
   })
   
   # laset_updated_time output
   output$timePlot <- renderDygraph({
     if ("Free" %in% input$type3) {
       time_df = xts(x = data[data$Type==input$type3, 6], order.by = data[data$Type==input$type3, 11])
       dygraph(time_df, main = "Relationship between Time and Profit for apps") %>% 
         dyRangeSelector(dateWindow = c('2010-05-21','2018-08-08')) %>% 
         dyOptions(drawGrid = input$time_range)
     }
     else{
       time_df = xts(x = data[data$Type==input$type3, 14], order.by = data[data$Type==input$type3, 11])
       
       dygraph(time_df, main = "Relationship between Time and Profit for apps") %>% 
         dyRangeSelector(dateWindow = c('2010-05-21','2018-08-08')) %>% 
         dyOptions(drawGrid = input$time_range)
     }
   })
   
   # numeric output
   output$correlation <- renderPlot({
     if ('Free' %in% input$type4){
       p <- chart.Correlation(data[data$Type==input$type4,c(3,4,5,6)], histogram=TRUE, pch=6)
       p
     }
     else {
       p <- chart.Correlation(data[data$Type==input$type4,c(3,4,5,14)], histogram=TRUE, pch=6)
       p
     }
   })
   
   which_feature <- reactive({             # identify which feature to plot
     if (input$feature == 'Rating') {
       return (data[data$Type==input$type4,]$Rating) }
     else if (input$feature == 'Reviews') {
       return (data[data$Type==input$type4,]$Reviews)}
     else if (input$feature == 'Size') {
       return (data[data$Type==input$type4,]$Size)}
   })
   
   output$numericPlot <- renderPlotly({
     if ('Free' %in% input$type4) {
       p <- plot_ly(data[data$Type==input$type4,], x= which_feature(), y = ~ Installs, type='scatter',
                    marker = list(size = 10,
                                  color = 'rgba(255, 182, 193, .9)',
                                  line = list(color = 'rgba(152, 0, 0, .8)',
                                              width = 2))) %>%
         layout(title = paste('Distribution between ', input$feature, ' and Profit'))
       p
     }
     else {
       p <- plot_ly(data[data$Type==input$type4,], x= which_feature(), y = ~ Profit, type='scatter',
                    marker = list(size = 10,
                                  color = 'rgba(255, 182, 193, .9)',
                                  line = list(color = 'rgba(152, 0, 0, .8)',
                                              width = 2))) %>%
         layout(title = paste('Distribution between ', input$feature, ' and Profit'))
       p
     }
   })
   
   # word cloud output
   terms <- reactive({       # preprocess for word cloud
     app_review <- merge_df[merge_df$App==input$app,]$Translated_Review
     docs <- Corpus(VectorSource(app_review))
     toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
     
     docs <- tm_map(docs, toSpace, "/")
     docs <- tm_map(docs, toSpace, "@")
     docs <- tm_map(docs, toSpace, "\\|")
     docs <- tm_map(docs, content_transformer(tolower))
     docs <- tm_map(docs, removeNumbers)
     docs <- tm_map(docs, removeWords, stopwords("english"))
     docs <- tm_map(docs, removeWords, c("blabla1", "blabla2")) 
     docs <- tm_map(docs, removePunctuation)
     docs <- tm_map(docs, stripWhitespace)
     
     dtm <- TermDocumentMatrix(docs)
     m <- as.matrix(dtm)
     v <- sort(rowSums(m),decreasing=TRUE)
     d <- data.frame(word = names(v),freq=v)
   })
   
   output$word_cloud <- renderPlot({
     v <- terms()
     wordcloud(words = v$word, freq = v$freq, min.freq = input$freq,
               max.words=input$words, random.order=FALSE, rot.per=0.35, 
               colors=brewer.pal(8, "Dark2"))
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

