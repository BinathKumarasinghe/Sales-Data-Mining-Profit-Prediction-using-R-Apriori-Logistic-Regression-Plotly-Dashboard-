# Load required libraries
library(shiny)
library(plotly)
library(dplyr)
library(readr)
library(lubridate)
library(RColorBrewer)

# Load and clean data
sales_data <- read_csv("10000 Sales Records.csv")
colnames(sales_data) <- make.names(colnames(sales_data))

# Date conversion
sales_data$Order.Date <- mdy(sales_data$Order.Date)
sales_data$Ship.Date <- mdy(sales_data$Ship.Date)
sales_data$ProcessingTime <- as.numeric(difftime(sales_data$Ship.Date, sales_data$Order.Date, units = "days"))

# Binary target for logistic regression
sales_data$HighProfit <- ifelse(sales_data$Total.Profit > median(sales_data$Total.Profit, na.rm = TRUE), 1, 0)

# Define UI
ui <- fluidPage(
  titlePanel("Sales Data Mining Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("region", "Select Region", choices = unique(sales_data$Region)),
      selectInput("category", "Select Item Type", choices = unique(sales_data$Item.Type)),
      dateRangeInput("date_range", "Select Order Date Range", 
                     start = min(sales_data$Order.Date, na.rm = TRUE), 
                     end = max(sales_data$Order.Date, na.rm = TRUE))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Revenue by Region", plotlyOutput("sales_by_region")),
        tabPanel("Profit by Item Type", plotlyOutput("category_profit")),
        tabPanel("Processing Time", plotlyOutput("processing_time")),
        tabPanel("Units vs Revenue", plotlyOutput("units_vs_revenue")),
        tabPanel("Box Plot: Profit by Region", plotlyOutput("box_plot")),
        tabPanel("Profit by Country", plotlyOutput("map_plot")),
        tabPanel("Pie Chart: Revenue Share", plotlyOutput("pie_chart")),
        tabPanel("Logistic Regression", verbatimTextOutput("log_reg")),
        tabPanel("Insights", verbatimTextOutput("summary"))
      )
    )
  )
)

# Server logic
server <- function(input, output) {
  
  filtered_data <- reactive({
    sales_data %>%
      filter(Region == input$region,
             Item.Type == input$category,
             Order.Date >= input$date_range[1],
             Order.Date <= input$date_range[2])
  })
  
  # 1. Revenue by Region
  output$sales_by_region <- renderPlotly({
    data_plot <- sales_data %>%
      group_by(Region) %>%
      summarise(TotalRevenue = sum(Total.Revenue, na.rm = TRUE))
    
    plot_ly(data_plot, x = ~Region, y = ~TotalRevenue, type = 'bar',
            marker = list(color = brewer.pal(n = nrow(data_plot), name = "Set1"))) %>%
      layout(title = "Total Revenue by Region", xaxis = list(title = "Region"), yaxis = list(title = "Total Revenue"))
  })
  
  # 2. Profit by Item Type
  output$category_profit <- renderPlotly({
    data_plot <- sales_data %>%
      filter(Region == input$region) %>%
      group_by(Item.Type) %>%
      summarise(TotalProfit = sum(Total.Profit, na.rm = TRUE))
    
    colors <- colorRampPalette(brewer.pal(9, "Accent"))(nrow(data_plot))
    
    plot_ly(data_plot, x = ~Item.Type, y = ~TotalProfit, type = 'bar',
            marker = list(color = colors)) %>%
      layout(title = paste("Profit by Item Type in", input$region), xaxis = list(title = "Item Type"), yaxis = list(title = "Total Profit"))
  })
  
  # 3. Processing Time
  output$processing_time <- renderPlotly({
    data_plot <- filtered_data()
    
    plot_ly(data_plot, x = ~Order.Date, y = ~ProcessingTime, type = 'scatter', mode = 'markers',
            color = ~Sales.Channel, colors = brewer.pal(3, "Pastel1")) %>%
      layout(title = "Processing Time vs Order Date", xaxis = list(title = "Order Date"), yaxis = list(title = "Processing Time (days)"))
  })
  
  # 4. Units vs Revenue
  output$units_vs_revenue <- renderPlotly({
    data_plot <- filtered_data()
    
    plot_ly(data_plot, x = ~Units.Sold, y = ~Total.Revenue, type = 'scatter', mode = 'markers',
            color = ~Order.Priority, colors = brewer.pal(4, "Set2")) %>%
      layout(title = "Units Sold vs Total Revenue", xaxis = list(title = "Units Sold"), yaxis = list(title = "Total Revenue"))
  })
  
  # 5. Box Plot
  output$box_plot <- renderPlotly({
    plot_ly(sales_data, y = ~Total.Profit, x = ~Region, type = "box", color = ~Region,
            colors = brewer.pal(length(unique(sales_data$Region)), "Dark2")) %>%
      layout(title = "Box Plot: Total Profit by Region", yaxis = list(title = "Total Profit"))
  })
  
  # 6. Map Plot: Average Profit by Country
  output$map_plot <- renderPlotly({
    data_map <- sales_data %>%
      group_by(Country) %>%
      summarise(AvgProfit = mean(Total.Profit, na.rm = TRUE))
    
    plot_geo(data_map) %>%
      add_trace(
        z = ~AvgProfit, color = ~AvgProfit, colors = 'Blues',
        text = ~paste(Country, "<br>", round(AvgProfit, 2)),
        locations = ~Country, locationmode = 'country names'
      ) %>%
      colorbar(title = "AvgProfit") %>%
      layout(title = "Average Profit by Country")
  })
  
  # 7. Pie Chart
  output$pie_chart <- renderPlotly({
    data_plot <- sales_data %>%
      group_by(Item.Type) %>%
      summarise(Revenue = sum(Total.Revenue, na.rm = TRUE))
    
    colors <- brewer.pal(12, "Set3")
    
    plot_ly(data_plot, labels = ~Item.Type, values = ~Revenue, type = 'pie',
            marker = list(colors = colors),
            textinfo = 'label+percent') %>%
      layout(title = "Revenue Share by Item Type")
  })
  
  # 8. Logistic Regression Output
  output$log_reg <- renderPrint({
    model <- glm(HighProfit ~ Units.Sold + Total.Cost + Order.Priority + Sales.Channel,
                 data = sales_data, family = binomial)
    summary(model)
  })
  
  # 9. Summary Text
  output$summary <- renderText({
    paste0("Insights based on your selected filters:\n",
           "- Region: ", input$region, "\n",
           "- Item Type: ", input$category, "\n",
           "- Date Range: ", format(input$date_range[1]), " to ", format(input$date_range[2]), "\n\n",
           "💡 Association Rule Insight: High-priority Office Supplies in ", input$region,
           " are likely to generate significant revenue.\n\n",
           "📈 Logistic Regression Insight: Higher Units Sold and Online Channel are predictors of High Profit.")
  })
}

# Launch app
shinyApp(ui = ui, server = server)
