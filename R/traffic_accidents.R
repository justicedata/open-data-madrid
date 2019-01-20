# Libraries ----
source(here::here("R","aux","libs.R"))

# Data loading ----
files <- list.files(here::here("data","traffic_accidents","raw"))
dat <- map(.x = paste(here::here("data","traffic_accidents","raw"),
                      files, sep = "/"), .f = read_xlsx)
dat <- map(.x = dat, .f = function(x){
    names(x) <- c("fecha", "hora", "dia", "distrito", "lugar", "num", "parte",
                    "granizo", "hielo", "lluvia", "niebla", "seco", "nieve", "via_mojada",
                    "via_aceite", "via_barro", "via_grava", "via_hielo", "via_seca_limpia",
                    "num_victimas", "tipo", "vehiculo", "persona", "sexo", "gravedad", "edad")
    x
  })
dat <- map_df(dat, function(x)x)


# Test
