
source("R/00-librerias.R")
source("R/01-importar.R")
#df_banderas <- readxl::read_excel("base_bandera_limpio.xlsx")
source("R/02-preparo_base_viz.R")
source("R/TABLA_competencias.R")
source("R/TABLA_participantes.R")


ui <- page_navbar(
  title = tags$a(href='https://olympics.com/es/olympic-games',
                 tags$img(src='https://olympics.com/images/static/b2p-images/logo_color.svg',
                          height = 105, width = 300)),
  selected = "Sobre los juegos olímpicos",
  underline = TRUE,
  nav_panel(
    title = "Sobre los juegos olímpicos",
    layout_column_wrap(
      width = "250px",
      fill = FALSE,
      value_box(
        title = "Medallas en disputa",
        value = textOutput("out_medallas_tot"),
        #showcase = "🥇🥈🥉"), 
        showcase = a(tags$img(src="https://upload.wikimedia.org/wikipedia/commons/1/15/Gold_medal.svg", width = 20),
                     tags$img(src="https://upload.wikimedia.org/wikipedia/commons/0/03/Silver_medal.svg", width = 20),
                     tags$img(src="https://upload.wikimedia.org/wikipedia/commons/5/52/Bronze_medal.svg", width = 20))),
      value_box(
        title = "Cantidad de países disputando",
        value = textOutput(outputId = "out_paises_tot"),
        showcase = a(tags$img(src = "https://camo.githubusercontent.com/638926866cd7654aa8600a398113bb4182c499c5d06cd79cc0614a6627794fe4/68747470733a2f2f63646e2e7261776769742e636f6d2f666c656b73636861732f73696d706c652d776f726c642d6d61702f61333664656365352f776f726c642d6d61702e737667", width = 100))),
      value_box(
        title = "Cantidad de disciplinas",
        value = textOutput(outputId = "out_discuplina_tot"),
        showcase = a(tags$img(src='https://upload.wikimedia.org/wikipedia/commons/8/8f/Athletics_pictogram.svg', width = 30),
                     tags$img(src='https://upload.wikimedia.org/wikipedia/commons/3/31/Modern_pentathlon_pictogram.svg', width = 30))
      )
    ),
    card(min_height = "800px",
         h2("Cantidad de atletas por Comité Olímpico"),
         reactableOutput("tb_part")
    )
  ),
  nav_panel(
    title = "Medallero",
    card(min_height =  "1500px",
         highchartOutput("sankey", height = "1000px")),
  ),
  nav_panel(title = "Competencias",
            card(min_height = "800px", 
                 h2("Deporte, disciplina y país coronado por tipo de medalla"),
                 reactableOutput("tabla_competencias")
            )
  ),
  div(tags$a(href='https://linktr.ee/estacion_r',
             tags$img(src='https://ugc.production.linktr.ee/9ed888ed-c016-468e-95da-2c449b2c2fc5_Logo-PNG-Baja-Mesa-de-trabajo-1-copia-3.png?io=true&size=avatar-v3_0',
                      width = 300)), align = "center")
)


server <- function(input, output) {
  
  
  shinyalert(
    title = "Buenas!",
    text = "Esta aplicación está en desarrollo. Si algo no está funcionando, se puede mejorar o incluso tenés una idea para agregar, podés escribirme a pablotisco@gmail.com",
    size = "s",
    closeOnEsc = TRUE,
    closeOnClickOutside = FALSE,
    html = FALSE,
    type = "warning",
    showConfirmButton = TRUE,
    showCancelButton = FALSE,
    confirmButtonText = "JOYA",
    confirmButtonCol = "#405BFF",
    timer = 0,
    imageUrl = "",
    animation = TRUE
  )
  
  output$out_medallas_tot <- renderText({
    "329"
  })
  
  output$out_paises_tot <- renderText({
    length(unique(tb_participantes$con))
  })
  
  output$out_discuplina_tot <- renderText({
    length(unique(tb_competencias$deporte))
  })
  
  output$sankey <- renderHighchart({
    highchart() |> 
      hc_add_series(data = tb_medallero_pivot, 
                    type = "sankey",
                    hcaes(from = from, to = to, weight = weight),
                    nodes = nodes_list) |> 
      hc_plotOptions(series = list(dataLabels = list(
        style = list(
          fontSize = "12px",
          color = "black"
        ),
        useHTML = TRUE,
        padding = 2,
        shadow = FALSE
      ))) |> 
      hc_tooltip(useHTML = TRUE, formatter = JS("
    function() {
      let point = this.point;
      let tooltipStyle = 'background-color: white; border-radius: 10px; border: 1px solid #0072CE; padding: 5px;';
      if (point.isNode) {
        // Node tooltip (country name)
        let country = point.id;
        let totalMedals = this.series.chart.series[0].points
          .filter(p => p.to === country)
          .reduce((acc, p) => acc + p.weight, 0);
        return '<div style=\"' + tooltipStyle + '\">' +
               '<b>' + country + '</b><br/>' +
               'Total Medals: ' + totalMedals +
               '</div>';
      } else {
        // Link tooltip (medal bar)
        let medalType = point.from;
        let weight = point.weight;
        let medalIcons = {
          'Medalla de oro': '🥇',
          'Medalla de plata': '🥈',
          'Medalla de bronce': '🥉'
        };
        return '<div style=\"' + tooltipStyle + '\">' +
               medalIcons[medalType] + ' ' + weight + ' ' + medalType.replace('med_', '') +
               '</div>';
      }
    }
  ")) |> 
      hc_title(text = "Medallero") |> 
      hc_subtitle(text = "Juegos Olímpicos de París 2024") |> 
      hc_caption(text = "Fuente: Wikipedia") |> 
      hc_add_theme(hc_theme_smpl())
    
    
  })
  
  
  # Tabla de competencias y medallas
  output$tabla_competencias <- renderReactable({tabla_comp})
  
  # Tabla de participantes
  output$tb_part <- renderReactable({tabla_participantes})
  
}

shinyApp(ui, server)