library(tidyverse)
library(jsonlite)
library(rvest)
library(furrr)

get_metacritic_score <- function(imdb_id) {

	print(imdb_id)

	if(!is.na(imdb_id) || imdb_id != ""){

		url <- paste0("https://www.imdb.com/title/tt", imdb_id, "/")
		score <- read_html(url) %>% html_node(".metacriticScore") %>% html_text() %>% as.numeric()

	} else {

		score <- NA

	}

	score
}

plan(multisession)

#http://bechdeltest.com
bechdel_scrape <- fromJSON('http://bechdeltest.com/api/v1/getAllMovies') %>% tibble


bechdel_scrape %>%
	filter(imdbid != "") %>%
	mutate(imdbid = str_pad(imdbid, 7, "left", 0)) %>%
	mutate(metacritic_score = future_map_dbl(imdbid, get_metacritic_score)) %>%
	write_tsv("bechdel_data.tsv")
