

options(reactable.theme = reactableTheme(
  color = "#000000",
  backgroundColor = "white",
  borderColor = "#00A651",
  stripedColor = "hsl(233, 12%, 22%)",
  highlightColor = "#0081C8",
  inputStyle = list(backgroundColor = "white"),
  selectStyle = list(backgroundColor = "yellow"),
  pageButtonHoverStyle = list(backgroundColor = "#EE334E"),
  pageButtonActiveStyle = list(backgroundColor = "#EE334E")
))

tabla_participantes <- tb_participantes |> 
  select("pais" = con, atletas, bandera) |> 
  mutate(pais = paste(pais, bandera)) |> 
  select(-bandera) |> 
  reactable(
    defaultSorted = "atletas",
    defaultColDef = colDef(
      headerStyle = list(background = "#f7f7f8"),
      align = "center"),
    columns = list(
      pais = colDef(name = "País", align = "left"),
      atletas = colDef(name = "# de Atletas", 
                       defaultSortOrder = "desc")
      ),
    #bordered = FALSE,
    borderless = TRUE,
    outlined = FALSE,
    #striped = TRUE,
    highlight = TRUE,
    filterable = TRUE,
    showPageInfo = FALSE, 
    showPageSizeOptions = TRUE, 
    defaultPageSize = 10
  )
