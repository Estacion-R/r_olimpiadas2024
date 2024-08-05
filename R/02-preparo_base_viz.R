tb_medallero_pivot <- tb_medallero |> 
  pivot_longer(cols = starts_with("med"), names_to = "medalla", values_to = "cantidad") |> 
  select(
    "from" = medalla,
    "to" = pais,
    "weight" = cantidad
  ) |> 
  mutate(id = paste0(from, to),
         weight = as.numeric(weight)) |> 
  filter(!is.na(weight))


### Preparo base para grafico
# Calculate total number of medals for each country
country_totals <- tb_medallero_pivot %>%
  group_by(to) %>%
  summarise(total_medals = sum(weight)) %>%
  arrange(desc(total_medals)) |> 
  filter(!is.na(total_medals)) |> 
  left_join(df_banderas |> 
              select(pais_orig, bandera),
            by = c("to" = "pais_orig"))

# Ensure the `to` column is a factor with levels in the desired order
tb_medallero_pivot <- tb_medallero_pivot %>%
  mutate(
    from = case_when(from == "med_oro" ~ "Medalla de oro",
                     from == "med_plata" ~ "Medalla de plata",
                     from == "med_bronce" ~ "Medalla de bronce"),
    from = factor(from, 
                  levels = c('Medalla de oro', 'Medalla de plata', 'Medalla de bronce')
                  #     labels = c("🥇", "🥈", "🥉")
    ),
    to = factor(to, levels = country_totals$to)) %>%
  arrange(from, to, -weight)


# Prepare nodes with country flags and transparent colors
nodes_list <- lapply(1:nrow(country_totals), function(i) {
  country <- country_totals$to[i]
  #flag_url <- df_banderas$bandera[match(country, df_banderas$pais_orig)]
  flag_url <- country_totals$bandera[i]
  list(
    id = country, 
    name = flag_url,
    color = 'rgba(0, 0, 0, 0)'  # Transparent color
  )
})

# Add medal nodes with colors
nodes_list <- append(nodes_list, list(
  list(id = 'Medalla de oro', color = 'rgba(255, 215, 0, 0.5)'),  # Gold with 50% transparency
  list(id = 'Medalla de plata', color = 'rgba(192, 192, 192, 0.5)'),  # Silver with 50% transparency
  list(id = 'Medalla de bronce', color = 'rgba(205, 127, 50, 0.5)')   # Bronze with 50% transparency
))