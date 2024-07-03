library(tidyverse)       # Tidyverse for Tidy Data
library(readxl)
library(tmap)            # Thematic Mapping
library(tmaptools) 
library(tigris)          # Get Census Geography Poloygons
library(sf)

US_map <- st_read("US/cb_2017_us_state_5m.shp", stringsAsFactors = FALSE)

cancer_data <- read.csv("cancer_by_states.csv")
HD_data <- read.csv("HD_by_states.csv")
both_data <- read.csv("both_by_states.csv")
neither_data <- read.csv("neither_by_states.csv")


cancer_join <- left_join(US_map,cancer_data, by=c("STUSPS"="state")) %>%
  select(STUSPS,avg_allowed_amt,geometry)

HD_join <- left_join(US_map,HD_data, by=c("STUSPS"="state")) %>%
  select(STUSPS,avg_allowed_amt,geometry)

both_join <- left_join(US_map,both_data, by=c("STUSPS"="state")) %>%
  select(STUSPS,avg_allowed_amt,geometry)
neither_join <- left_join(US_map,neither_data, by=c("STUSPS"="state")) %>%
  select(STUSPS,avg_allowed_amt,geometry)

cancer_states <- cancer_join %>% 
  filter(!STUSPS %in% c("VI", "PR", "MP", "GU", "AS")) %>% 
  shift_geometry()
HD_states <- HD_join %>% 
  filter(!STUSPS %in% c("VI", "PR", "MP", "GU", "AS")) %>% 
  shift_geometry()
both_states <- both_join %>% 
  filter(!STUSPS %in% c("VI", "PR", "MP", "GU", "AS")) %>% 
  shift_geometry()
neither_states <- neither_join %>% 
  filter(!STUSPS %in% c("VI", "PR", "MP", "GU", "AS")) %>% 
  shift_geometry()


cancer_map <- tm_shape(st_as_sf(cancer_states), projection = 2163) + 
  tm_polygons("avg_allowed_amt",
              colorNA = "#C9C9C9", 
              showNA = T, 
              id = c("state"), 
              palette="Blues",
              title = "Average Allowed Amount ($)",
              legend.is.portrait=TRUE) +
  tm_layout(main.title = "Average Allowed Amount Among Patients \nWith Cancer Only by States", 
            main.title.size = 2,
            frame = NA, 
            bg.color = NA,
            legend.frame = FALSE,
            legend.outside =  TRUE,
            legend.outside.position = c("right"),
            legend.text.size = 1,
            title.size = 2,
            main.title.position = "center") +
  tm_text("STUSPS", size=0.7)
cancer_map

HD_map <- tm_shape(st_as_sf(HD_states), projection = 2163) + 
  tm_polygons("avg_allowed_amt",
              colorNA = "#C9C9C9", 
              showNA = T, 
              id = c("state"), 
              palette="seq",
              title = "Average Allowed Amount ($)") +
  tm_layout(main.title = "Average Allowed Amount Among Patients \nWith Heart Diseases Only by States", 
            main.title.size = 2,
            frame = NA, 
            bg.color = NA,
            legend.frame = FALSE,
            legend.outside =  TRUE,
            legend.outside.position = c("right"),
            legend.text.size = 1,
            title.size = 2,
            main.title.position = "center") +
  tm_text("STUSPS", size=0.7)
HD_map

both_map <- tm_shape(st_as_sf(both_states), projection = 2163) + 
  tm_polygons("avg_allowed_amt",
              colorNA = "#C9C9C9", 
              showNA = T, 
              id = c("state"), 
              palette="Purples",
              title = "Average Allowed Amount ($)") +
  tm_layout(main.title = "Average Allowed Amount Among Patients \nWith Both Conditions by States", 
            main.title.size = 2,
            frame = NA, 
            bg.color = NA,
            legend.frame = FALSE,
            legend.outside =  TRUE,
            legend.outside.position = c("right"),
            legend.text.size = 1,
            title.size = 2,
            main.title.position = "center") +
  tm_text("STUSPS", size=0.7)
both_map

neither_map <- tm_shape(st_as_sf(neither_states), projection = 2163) + 
  tm_polygons("avg_allowed_amt",
              colorNA = "#C9C9C9", 
              showNA = T, 
              id = c("state"), 
              palette="Greens",
              title = "Average Allowed Amount ($)") +
  tm_layout(main.title = "Average Allowed Amount Among Patients \nWith Neither Condition by States", 
            main.title.size = 2,
            frame = NA, 
            bg.color = NA,
            legend.frame = FALSE,
            legend.outside =  TRUE,
            legend.outside.position = c("right"),
            legend.text.size = 1,
            title.size = 2,
            main.title.position = "center") +
  tm_text("STUSPS", size=0.7)
neither_map

tmap_arrange(cancer_map,HD_map,both_map)
