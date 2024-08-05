source(here::here("R/00-librerias.R"))

url <- "https://es.wikipedia.org/wiki/Juegos_Olímpicos_de_París_2024"

url_bow <- bow(url)
#url_bow

### MEDALLERO
url_olimpiadas <- "https://es.wikipedia.org/wiki/Juegos_Olímpicos_de_París_2024"
url_olimpiadas_bow <- bow(url_olimpiadas)

tb_olimpiadas <- polite::scrape(url_olimpiadas_bow) %>%  # scrape web page
  rvest::html_nodes("table.wikitable") %>% # pull out specific table
  rvest::html_table(fill = TRUE) 

tb_medallero <- tb_olimpiadas[[8]] %>% 
  clean_names() |> 
  mutate(pais_iso = str_extract(pais, "(?<=\\().*?(?=\\))"),
         pais_nombre = str_trim(str_replace(pais, "\\([^)]*\\)", "")),
         pais_nombre = case_when(pais_nombre == "República Popular China" ~ "China",
                                 .default = pais_nombre)) |> 
  relocate(c("pais_nombre", "pais_iso"), .after = "pais")

colnames(tb_medallero) <- c("ranking", "pais", "pais_nombre", "pais_iso", "med_oro", "med_plata", "med_bronce", "total")


df_banderas <- read.csv("datos/df_banderas.csv")



### Cantidad de disciplinas
url_competencias <- "https://es.wikipedia.org/wiki/Calendario_de_los_Juegos_Olímpicos_de_París_2024"
url_competencias_bow <- bow(url_competencias)

tb_competencias <- polite::scrape(url_competencias_bow) %>%  # scrape web page
  rvest::html_nodes("table.wikitable") %>% # pull out specific table
  rvest::html_table(fill = TRUE) 

tb_competencias <- tb_competencias[[1]] %>% 
  clean_names() |> 
  select(deporte:x_3)

colnames(tb_competencias) <- c("deporte", "disciplina", "med_oro", "med_plata", "med_bronce")

tb_competencias <- tb_competencias |> 
  filter(str_detect(deporte, "julio|agosto", negate = TRUE))


### Participantes
tb_participantes <- tb_olimpiadas[[6]] %>% 
  clean_names() |> 
  mutate(pais_iso = str_extract(con, "(?<=\\().*?(?=\\))"),
         pais_nombre = str_trim(str_replace(con, "\\([^)]*\\)", "")),
         pais_nombre = case_when(pais_nombre == "República Popular China" ~ "China",
                                 .default = pais_nombre),
         atletas = as.numeric(atletas)) |> 
  left_join(df_banderas, by = "pais_nombre")

