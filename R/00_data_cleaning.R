# Libraries ----
source(here::here("R","aux","libs.R"))

# Data loading ----
files <- list.files(here::here("data","raw"))
dat <- map(.x = paste(here::here("data","raw"),
                      files, sep = "/"), .f = read_xlsx)
dat <- map(.x = dat, .f = function(x){
  names(x) <- c("fecha", "hora", "dia", "distrito", "lugar", "num", "parte",
                "granizo", "hielo", "lluvia", "niebla", "seco", "nieve", "via_mojada",
                "via_aceite", "via_barro", "via_grava", "via_hielo", "via_seca_limpia",
                "num_victimas", "tipo", "vehiculo", "persona", "sexo", "gravedad", "edad")
  x
})
dat <- map_df(dat, function(x)x)

# Variable recoding ----

## hora ----
dat$hora <- factor(dat$hora)
levels(dat$hora) <- c("00", "01", "10", "11", "12", "13", "14", "15",
                      "16", "17", "18", "19", "02", "20", "21", "22",
                      "23", "03", "04", "05", "06", "07", "08", "09")
dat$hora <- factor(dat$hora, levels = sort(levels(dat$hora)), ordered = T)
## dia ----
dat$dia <- factor(tolower(dat$dia), levels = c("lunes", "martes", "miercoles","jueves",
                                               "viernes", "sabado", "domingo"), ordered = T)
## distrito ----
dat$distrito <- factor(tolower(dat$distrito))
## lugar ----
dat$lugar <- tolower(dat$lugar)
## num ----
dat$lugar <- ifelse(test = dat$num == 0, yes = dat$lugar, no = paste(dat$lugar, dat$num))
dat <- dat %>% select(-num)
## parte ----
dat$parte <- factor(dat$parte)

## categorical features ----
dat[,7:23] <- map_df(dat[,7:23], function(x) factor(tolower(x))) #Refering to the columns as numbers sucks
dat$gravedad <- ordered(dat$gravedad, levels = c("NO ASIGNADA", "IL", "HL", "HG", "MT"))
levels(dat$gravedad) <- c("no_conocida", "ileso", "leve", "grave", "muerte")
## edad ----
dat$edad <- factor(dat$edad) #I´m sure this recoding can be done more efficiently
levels(dat$edad) <- c("0-5", "10-14", "15-17", "18-20", "21-24", "25-29", "30-34", "35-39",
                      "40-44", "45-49", "50-54", "55-59", "6-9", "60-64","65-69", "70-74", ">74","no_conocida")
dat$edad <- factor(dat$edad,
                   ordered =T,
                   levels = c("no_conocida", "0-5", "6-9", "10-14", "15-17", "18-20", "21-24",
                              "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59",
                              "60-64", "65-69", "70-74", ">74"))

# Nested data frame creation ----
# As the "parte" variable contains the incident number, we can join the rows by the
# specific accident they belong to.
dat_nested <- as_tibble(dat) %>% nest(-(1:20))
names(dat_nested)[21] <- "implicados"

write_rds(x = dat_nested, path =  here::here("data","clean_data.rds"))

