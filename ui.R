library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(plotly)
library(tidyverse)
library(patchwork)
library(janitor)
library(bslib)
library(shinythemes)
library(shinydashboard)
library(tidyr)
library(scales)
library(stringr)
library(data.table)


data <- read_csv("Movies.csv")
distributor_data <- data %>%
  group_by(Distributor) %>%
  mutate(num_movies = n())

convert_runtime <- function(runtime_string) {
  hours <- as.numeric(sub(".*?(\\d+) hr.*", "\\1", runtime_string, ignore.case = TRUE))
  minutes <- as.numeric(sub(".*?(\\d+) min.*", "\\1", runtime_string, ignore.case = TRUE))
  total_minutes <- hours * 60 + minutes
  return(total_minutes)
}

movie_data <- read.csv("Movies.csv")

movie_data <- movie_data %>%
  mutate(Total.Minutes = sapply(Movie.Runtime, convert_runtime))

movies_data <- read.csv("Movies.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

all_films_by_license <- movies_data %>% select(License, World.Sales..in...)

mean_money_film <- all_films_by_license %>% group_by(License) %>% 
  summarise(avg_revenue = mean(World.Sales..in...)) %>% 
  filter(License != "NA")

filtered_data <- movies_data %>% select(Release.Date) %>% 
  filter(Release.Date != "NA")

adding_year <- filtered_data %>% mutate(release_year = str_sub(Release.Date, 
str_length(Release.Date) - 4, str_length(Release.Date)))

adding_year_table <- data.table(adding_year)

casting_year <- data.frame(adding_year_table[ , release_year := as.integer(release_year)])

adding_month <- casting_year %>% mutate(release_month = 
str_sub(Release.Date, 1, str_length(Release.Date) - 8))

adding_month_table <- data.table(adding_month)

trimming_month <- data.frame(adding_month_table[, 
release_month := str_trim(release_month, side = c("both"))])

filter_by_month <- function(month){
trimming_month %>% filter(release_month == month) %>% 
arrange(release_year) %>% group_by(release_year) %>% select(release_year) %>% count()
}

January <- filter_by_month("January")

February <- filter_by_month("February")

March <- filter_by_month("March")

April <- filter_by_month("April")

May <- filter_by_month("May")

June <- filter_by_month("June")

July <- filter_by_month("July")

August <- filter_by_month("August")

September <- filter_by_month("September")

October <- filter_by_month("October")

November <- filter_by_month("November")

December <- filter_by_month("December")

add_sequence_function <- function(dataset){
  year = 1970
  while (year <= 2023){
    if (any(dataset$release_year) == year){
    }
    else {
      dataset[nrow(dataset) + 1,] <- list(year, 0)
      year = year + 1
    }
  }
  dataset %>% arrange(release_year)
  return (dataset)
}

creating_plottable_df <- function(dataset){
  add_sequence_function(dataset) %>% arrange(release_year) %>% 
    group_by(release_year) %>% arrange(release_year, -n) %>% 
    filter(duplicated(release_year) == FALSE)
}

January_final <- creating_plottable_df(January) 

February_final <- creating_plottable_df(February)

March_final <- creating_plottable_df(March)

April_final <- creating_plottable_df(April)

May_final <- creating_plottable_df(May)

June_final <- creating_plottable_df(June)

July_final <- creating_plottable_df(July)

August_final <- creating_plottable_df(August)

September_final <- creating_plottable_df(September)

October_final <- creating_plottable_df(October)

November_final <- creating_plottable_df(November)

December_final <- creating_plottable_df(December)

all_data_one_frame <- data.frame(
  Month = rep(c("January", "February", "March", "April", "May", "June",
                "July", "August", "September", "October", "November", "December"), each = nrow(January_final)),
  Year = rep(January_final$release_year, times = 12),
  Count = c(January_final$n, February_final$n, March_final$n, April_final$n, May_final$n,
            June_final$n, July_final$n, August_final$n, September_final$n,
            October_final$n, November_final$n, December_final$n)
)

ui <- navbarPage("Creating The Optimal Movie", 
              
### 1st tab
                 
tabPanel("Introduction",  fluidPage(
  titlePanel("Creating The Optimal Movie"),
  img("Star Wars: The Force Awakens; The highest-ranked film from our dataset", 
      src = "/dhruv/Downloads/INFO 201/final-deliverable-p03-dhruvj20/scale.jpg"),
  h2("Main Question:"),
  p("How do various factors impact the box office performance of movies?"),
  h2("Why is this important?"),
  p("Our research project aims to analyze the top 1000 highest-grossing movies, 
    investigating the relationships between distributor, runtime, genre, and world sales."),
  p("Our research questions revolve around whether the runtime and genre have an impact on 
    sales, which distributor produces the highest number of films in the top 1000, 
    and whether releasing movies under various genres affects box office performance."), 
  p("Addressing these research questions is motivated by the desire to gain valuable insights 
    into the intricate dynamics of the film industry. Understanding the potential influence 
    of runtime and genre on the number of sales can offer invaluable information to filmmakers 
    and movie studios while gaining valuable information about viewers and measuring elasticity."),
  p("This knowledge can help them better comprehend audience preferences, 
    refine marketing strategies, and optimize film production to cater to viewers’ 
    tastes effectively.  By answering these questions, valuable insights can be gained into audience preferences, industry trends, and the strategies that lead to box office success. "),
  p("The findings will benefit filmmakers, distributors, and other stakeholders in the 
  film industry, providing them with data-driven guidance to create 
  more engaging and commercially successful films in the future."), 
  p("This helps shed light on the major distributors in the film industry and uncover 
  their success in the film industry while still exploring the effect of releasing movies 
  under multiple genres on box office performance can provide insights into audience responsiveness to genre-blending and diverse storytelling. 
  This knowledge can foster new creation, and storytelling, and enhance the viewer experience."), 
  h2("What are our questions?"),
  p("- Does the the distributor affect the number of sales?"), 
  p("- Which distributor produces the highest number of films in the top 1000 movies?"),
  p("- Has the amount of movie releases across the months of the year changed 
  over the duration of this dataset?"),
  p("- Does the movie license offered by distributors impact the Movie Box office 
    performance?"),
  p("- Does the movie genre offered by distributors impact the Movie Box office 
    performance?"),
  h2("What data are we using for this?"),
  h3("Dataset"),
  p("The dataset used for this project came from Kaggle:"),
  a("Top 1000 Highest Grossing Movies", 
    href = "https://www.kaggle.com/datasets/sanjeetsinghnaik/top-1000-highest-grossing-movies"),
  h3("Origin of Dataset"),
  p("The data was updated 2 years ago by Sanjeet Singh Naik. This data was collected from 
  various websites and combined for use in a variety of data operations. 
  The information came from numerous websites, including IMDB, Rotten Tomatoes, and others."),
  p("The data is gathered for the public's use, particularly for those who are interested in 
    movies because it contains a lot of observations (movies) and information about genre, duration, and sales value."),
  p("Producers and directors can use it to research audience preferences and current movie 
  trends. Additionally, by collecting information on domestic and foreign sales, this data 
  is also made for business purposes by giving investors a more thorough picture of the 
  movie's revenue."),
  h3("Ethical Questions (Questions of Power):"),
  p("- Is the dataset biased in any way that might favor a particular genre?"),
  p("- Does the content of the movies reflect racism or sensitivity to a particular 
  culture or minority group?"),
  h3("Limitations"),
  p("Possible limitations and problems with this data is that there are some missing values 
    in this data, which could potentially lead to biased results because the data does 
    not fully represent the whole.  Furthermore, the dataset only includes movies from 
    the United States, so it cannot be used to analyze other countries or to examine 
    diversity.")
    )
  ),

  ### Stuff for 2nd tab

  tabPanel("Distributor vs Movie Production", fluidPage(
    titlePanel("Movie Distributors vs Number of Movies"),
    theme = bs_theme(version = 4, bootswatch = "minty"),
    fluidRow(
      column(width = 3, height = 4,
             checkboxGroupInput("option", "Choose License",
                                c("PG-13" = "PG-13",
                                  "G" = "G",
                                  "R" = "R"))),
      column(width = 5,
             sliderInput("number", "Number of Movies:",
                         min = 0, max = 158, c(0,158))),
      column(width = 3,
             selectInput("distributor_filter", "Select Distributor:",
                         choices = c("ALL", unique(distributor_data$Distributor))))
    ),
    fluidRow(
      column(width = 12, height = 33,
             plotlyOutput("distributor_plot")
        )
      ),
    p("To answer the research question 'which distributors produce the most movies' as well 
    as the productivity of movie production across distributors, I use a bar chart to 
    visualize this comparison."),
    p("As 'Distributors' is a categorical value, using bar chart will provide a 
      straightforward way to observe the frequency or count of each movie in the dataset. 
      Additionally, it displays the category labels clearly and arranges the value assigned 
      to each distributor in a tidy manner."),
    p("The X axis in this plot represents the overall number of films, and the Y axis 
      represents the various distributors. In comparison to other distributors, 
      Warner Bros. appears to produce the most movies."),
    p("By creating the checkbox showing three options for license, this enables us
      to vary the number of movies produced by various distributors falling under those categories.
      Warner Bros. is the top distributor for movies with license PG-13 and R, while 
      Walt Disney Studios Motion Picture produces most movies with license G."),
    p("Additionally, viewers can adjust the number of movies displayed using a range slider,
      which will allow us to focus on distributors that fall within a particular range.
      The third widget is a filter bar that allows us to choose which distributors to 
      display."),
    p("By doing this, we are able to see how many movies each distributor is distributing.
      With all three of these interactive widgets, we were able to compare the quantity of films
      released through number of films, the distributors, and the license.")
    )
  ),

### Stuff for 3rd tab

  tabPanel("Movie Runtime vs Movie World Sales", fluidPage(
    titlePanel("Movies: World Sales vs. Movie Runtime"),
    
    sidebarLayout(
      sidebarPanel(
        sliderInput("world_sales_slider", "World Sales Range:",
                    min = min(movie_data$World.Sales..in...),
                    max = max(movie_data$World.Sales..in...),
                    value = c(min(movie_data$World.Sales..in...), max(movie_data$World.Sales..in...)),
                    step = 1),
        uiOutput("selected_movie_info")
      ),
      mainPanel(
        plotlyOutput("world_sales_vs_runtime_scatter_plot"), 
        verbatimTextOutput("movie_info_output")
      )
    ),
    p("This chart is trying to decipher the relationship between world sales (X) in an unspecified 
    unit (most likely dollars) and movie runtime (Y) in minutes."),
    p("A scatter plot works best for this because both movie runtime and world sales are
      continuous variables and this plot is the best way to search for a potential
      correlation between these two variables (which is weak if present at all). "),
    p("We can see there's next to no correlation between the world sales and runtime. 
      If I had to guess, this is mostly because audiencemembers and advertising dictate
      most of the film's revenue, and runtime isn't on the top of their minds unless the
      film is egregiously long.")
  )
),
  tabPanel("Movie Rating vs Movie World Sales", fluidPage(
    titlePanel("Worldwide Sales vs Movie Licenses"),
    mainPanel(
      plotlyOutput("plot"),
      p("I chose a bar graph to represent the relationship between movie license/rating 
      (a categorical variable) and the average worldwide sales in dollars 
      (a continuous variable)."),
      p("I did so because bars are the best way to show the quantitative differences 
      between the movie license categories represented on the X-axis due to the space 
      they encompass, making said differences in average worldwide sales more noticeable 
      to the viewer's eye."),
      p("I think this chart is especially useful because it could provide useful 
      information to a potential film director on which movie rating to design/cater to 
      based on the highest mean influx of money worldwide (based on the top 1000 
      domestically highest-performing movies recorded."),
    )
  )
),
tabPanel("Movie Production by Month over time", fluidPage(
  titlePanel("Movie Production by Month over Time"),
  fluidRow(
    column(width = 6, selectInput("select", label = h3("Select Month"), 
                                  choices = unique(all_data_one_frame$Month)), 
           plotlyOutput("month")
      )
    ),
  p("This line plot tries to determine if certain months have produced more films than others,
    and how/if that trend has changed over time. Because time is the relevant X variable
    (in years between 1970 and 2023), a line plot is the best way to show the full
    chronology/history."),
  p("The ultimate takeaway is that number of movies across each month is the most volatile
    variable examined in this dataset. In all honesty, there's so much coincidence and no
    consistently observable pattern (other than random peaks and valleys) when it comes to 
    each month of the year and the number of movies produced."),
  )
),
tabPanel("Genre vs Movie World Sales", fluidPage(
  titlePanel("Genre vs Movie World Sales"),
  mainPanel(
    plotlyOutput("barchart"),
    p("Selecting the appropriate type of chart or graph is vital when visualizing data. 
        It guarantees that the information is presented in a clear and understandable format, 
        especially when dealing with categorical values like the different genres of the 
        top 1000 highest-grossing movies."),
    p("A bar chart is often the most effective choice in this case as it provides a 
      simple way to comprehend the data. The chart reveals that some movies belong to 
      more than one genre, making it difficult to determine the most prevalent genre."),
    p("Nevertheless, the chart highlights each genre and the aggregate revenue collected, 
      considering the revenue generated globally by each genre. 
      This enables us to identify the frequently occurring genre while providing a 
      comprehensive overview of the data.")
    )
  )
),
tabPanel("Summary", fluidPage(
    titlePanel("Overall Conclusions & Takeaways"),
    mainPanel(
        h2("Big Picture Goal"),
        p("The overall goal of our project is to guide film producers to creating the optimal 
        film using distributor, runtime, rating, and genre as separate criteria for overall 
        movie success, evaluated in world sales. "),
        plotlyOutput("dhruv_plot"),
        p(""),
        p("The main takeaway from this bar graph is that according to this dataset, a film 
 director designing a movie script for any of these 4 ratings will make money on the 
 same scale, but to optimize worldwide sales, they should significantly prioritize G, PG, 
 & PG-13-rated films over R-rated films."),
        plotlyOutput("pagna_bar_chart"),
        p(""),
        p("Out of all the individual genres in each dataset (and there were movies tagged with 
          multiple), 'adventure' and 'action' were correlated with by far the two highest world 
          sale incomes. Thus, a film director planning a movie should do so with the intention 
          of an adventure or action theme, because the two genres have significant overlap and 
          yield a lot of money in overall world sales."),
        plotlyOutput("vy_plot"),
        p("For all the films in this top 1000 dataset, 'Warner Bros' and 'Walt Disney Studios 
          Motion Pictures' were the two distributors who performed the best in not only overall 
          world sales, but also world sales for PG-13 and G-rated movies, two of the higher-producing 
          movie licenses. "),
        p(""),
        h3("Most Important Insight"),
        p("The most significant pattern revealed from our analysis is that popular variables, 
        such as genre, distributor, and rating have a much better relationship with movie 
        success (once again, defined by world sales) in comparison to hidden variables, such as 
        runtime and month of release."),
        p("This makes complete sense, because popular discourse around movies is split into a 
        few common aspects: director (unavailable in this dataset), movie plot (available but not 
        really usable), distributor (when people usually say 'Disney movie'), rating (usually 
        for families with kids), and genre, which semi-ties into the family element."),
        p("Thus, the implication is that the way movies are contextualized in popular discourse 
          could play a more significant role in their financial output than we think. Thus, 
          prospective film directors could really take advantage of this facet when dictating the 
          foundations of their films.")
      )
    ) 
  )
)