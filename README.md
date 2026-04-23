📊 Sales Data Mining & Profit Prediction

This project presents a full data science pipeline applied to a global sales dataset, combining data mining, machine learning, and interactive visualization techniques using R.

🔍 Project Overview

The project focuses on extracting meaningful insights from a large-scale sales dataset (10,000 records) to understand purchasing patterns and predict transaction profitability. It integrates:

Association Rule Mining (Apriori Algorithm)
Logistic Regression Modeling
Interactive Dashboard Development (Plotly + Shiny)

⚙️ Technologies Used
R Programming
arules & arulesViz – Association rule mining
ggplot2, GGally – Data visualization
Plotly & Shiny – Interactive dashboard
dplyr, tidyverse – Data manipulation

🧹 Data Preparation
Cleaned and transformed dataset
Converted categorical variables into factors
Created binary target variable (High Profit)
Structured data into transactional format for ARM
Performed feature selection and normalization

🔗 Association Rule Mining
Applied Apriori Algorithm
Generated 2,600+ rules
Evaluated using:
Support
Confidence
Lift

🔑 Key Insights
Strong relationships between Region, Sales Channel, and Product Type
High frequency of Cosmetics in online purchases (Sub-Saharan Africa)
Regional preferences influence purchasing behavior

🤖 Predictive Modeling (Logistic Regression)
Built classification model to predict profitability
Used 70/30 train-test split
Evaluated using:
Accuracy
Confusion Matrix

📈 Results
Model achieved ~64% accuracy
Key predictors:
Units Sold
Unit Price
Total Cost

📊 Interactive Dashboard
Developed using Plotly + Shiny, enabling:

Revenue analysis by region
Profit analysis by item type
Sales trends over time
Geographic visualization of profit
Logistic regression insights

🔑 Dashboard Insights
North America & Europe lead in profitability
Office Supplies & Household items dominate sales
Seasonal trends (Q4 peaks) observed

🎯 Conclusion
This project demonstrates how combining data mining + machine learning + visualization can generate actionable business insights. It highlights the importance of data-driven strategies in optimizing sales, marketing, and operational decisions.
