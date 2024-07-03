library(sf) 
library(dplyr)
library(tmap)
library(stringr)

US_map <- st_read("US/cb_2017_us_state_5m.shp", stringsAsFactors = FALSE)

# Load Single-family Home Data obtained from Zillow
  ## Data source: https://www.zillow.com/research/data/
cancer_data <- read.csv("cancer_by_states.csv")


map <- full_join(cancer_data,US_map, by=c("state"="STUSPS")) %>%
  select(state,avg_allowed_amt,geometry)

tm_shape(st_as_sf(map)) + 
  tm_polygons("avg_allowed_amt",
              colorNA = "#989898", 
              showNA = T, 
              id = c("state"), 
              palette = "Oranges",
              title = "Average Allowed Amount ($)")


# To enable interactive view mode
tmap_mode("view")

# Filter map data for California
CA_map <- US_map %>% 
  mutate(COUNTYFP = as.numeric(COUNTYFP), STATEFP = as.numeric(STATEFP)) %>%
  filter(STATEFP == 6)

# Filter listing data for California
CA_data <- housing_data %>% 
  filter(StateName == "CA") %>%
  mutate(RegionName = str_replace_all(RegionName," County", "")) %>%
  select(NAME = RegionName, State = StateName, Value = X1.31.21) 

# Join map data and listing data for California
CA_vis <- full_join(CA_data, CA_map)

# Run visualization for California
tm_shape(st_as_sf(CA_vis)) + 
  tm_polygons("Value",
              colorNA = "#989898", 
              showNA = T, 
              id = c("NAME"), 
              palette = "Oranges",
              title = "Average Listing Price ($)")

# Visualization for Minnesota
# Filter map data for Minnesota
MN_map <- US_map %>% 
  mutate(COUNTYFP = as.numeric(COUNTYFP), STATEFP = as.numeric(STATEFP)) %>%
  filter(STATEFP == 27)

# Filter listing data for Minnesota
MN_data <- housing_data %>% 
  filter(StateName == "MN") %>%
  mutate(RegionName = str_replace_all(RegionName," County", "")) %>%
  select(County = RegionName, State = StateName, Value = X1.31.21)

# Join map data and listing data for Minnesota
MN_vis <- full_join(MN_map, MN_data, by = c("NAME" = "County"))

# Run visualization for Minnesota
tm_shape(st_as_sf(MN_vis)) + 
  tm_polygons("Value",
              colorNA = "#989898", 
              showNA = T, 
              id = c("NAME"), 
              palette = "Blues",
              title = "Average Listing Price ($)")
