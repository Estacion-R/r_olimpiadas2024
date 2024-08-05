

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

tabla_comp <- tb_competencias |> 
  mutate(across(starts_with("med"), \(x) coalesce(x, "Por competir"))) |> 
  reactable(
    #groupBy = "deporte",
    defaultSorted = "deporte",
    defaultColDef = colDef(
      headerStyle = list(background = "#f7f7f8"),
      align = "center"),
    columns = list(
      #deporte = colDef(name = "Deporte"),
      #disciplina = colDef(name = "Disciplina"),
      deporte = colDef(
        headerVAlign = "bottom",
        vAlign = "center",
        
        name = "Deporte / Disciplina",align = "left",
        defaultSortOrder = "asc",
        # Show species under character names
        cell = function(value, index) {
          disciplina <- tb_competencias$disciplina[index]
          disciplina <- if (!is.na(disciplina)) disciplina else "Unknown"
          div(
            div(style = list(fontWeight = 600), value),
            div(style = list(fontSize = "0.75rem"), disciplina)
          )
        }
      ),
      disciplina = colDef(show = FALSE),
      med_oro = colDef(name = "🥇"),
      med_plata = colDef(name = "🥈"),
      med_bronce = colDef(name = "🥉")
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

