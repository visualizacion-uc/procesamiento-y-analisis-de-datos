# Repaso clase anterior

### Paso 1:
  
if (!require("pacman")) install.packages("pacman")

p_load(readr,readxl,dplyr,ggplot2,forcats)

### Paso 2:  
  
folder = "datasets/"
zip    = paste0(folder,"clase2_vuelos.zip")
csv    = paste0(folder,"clase2_vuelos.csv")

try(dir.create(folder))

if(!file.exists(zip)) {
  download.file("https://goo.gl/6hTX5o",zip)
}

if(!file.exists(csv)) {
  system(paste0("7z e ",zip," -oc:",folder))
}

### Paso 3:

flights = read_csv(csv)
filter(flights, month == 1, day == 1)
filter(flights, month == 12, day == 25)

# Tarea Nº1
  
### forma 1
filter(flights, month == 11 | month == 12)

### forma 2
filter(flights, month %in% c(11,12))

# Tarea Nº2
  
### forma 1
filter(flights, !(arr_delay > 120 | dep_delay > 120))

### forma 2
filter(flights, arr_delay <= 120, dep_delay <= 120)

# Tarea Nº3

NA > 5
10 == NA
NA + 10
NA / 2
NA == NA

# Tarea Nº4

df = tibble(x = c(1, NA, 3)) %>% 
  filter(!is.na(x))

# Tarea Nº5
  
### Paso 1:

not_cancelled = flights %>% 
  select(tailnum,arr_delay) %>% 
  filter(!is.na(arr_delay))

### Paso 2:

delays = not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(delay = mean(arr_delay))

### Paso 3:

ggplot(delays, aes(x = delay)) + 
  geom_freqpoly(binwidth = 10) +
  ggtitle("Conteo de vuelos salientes según atraso", 
          subtitle = "Luego de filtrar y agrupar")

# Tarea Nº6

### Paso 1:

by_dest = flights %>% 
  select(dep_delay,distance,dest) %>% 
  group_by(dest) %>% 
  summarise(count = n(),
            dist = mean(distance, na.rm = TRUE),
            delay = mean(dep_delay, na.rm = TRUE)) %>% 
  filter(count > 20)

### Paso 2:

ggplot(by_dest, aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE) +
  ggtitle("Atrasos vs distancia en vuelos salientes", 
          subtitle = "Luego de filtrar y agrupar")

# Tarea Nº7

p_load(DBI,nycflights13)

nycflights13_db = dbConnect(RSQLite::SQLite(), "datasets/lecture2_nycflights13.sqlite")

dbWriteTable(nycflights13_db, "flights", flights)
dbWriteTable(nycflights13_db, "airports", airports)
dbWriteTable(nycflights13_db, "planes", planes)
dbWriteTable(nycflights13_db, "weather", weather)
dbWriteTable(nycflights13_db, "airlines", airlines)

dbDisconnect(nycflights13_db)

# Tarea Nº8
  
nycflights13_db = dbConnect(RSQLite::SQLite(), "datasets/lecture2_nycflights13.sqlite")

dbListTables(nycflights13_db)

dbGetQuery(nycflights13_db, 'SELECT * FROM flights LIMIT 5')

dbGetQuery(nycflights13_db, 'SELECT * FROM airlines WHERE name LIKE "%Delta%"')

# Tarea Nº9
  
flights_db = as_tibble(dbReadTable(nycflights13_db, "flights"))
airlines_db = as_tibble(dbReadTable(nycflights13_db, "airlines"))
dbDisconnect(nycflights13_db)

summary_by_airline = flights_db %>% 
  select(year,month,day,carrier) %>% 
  left_join(airlines_db) %>% 
  select(-carrier) %>% 
  rename(airline = name) %>% 
  group_by(year,month,day,airline) %>% 
  summarise(flights = n())

summary_delta = summary_by_airline %>% 
  ungroup() %>% 
  filter(airline == "Delta Air Lines Inc.") %>% 
  group_by(year,month,airline) %>% 
  summarise(flights = sum(flights))

ggplot(summary_delta, aes(x = month, y = flights)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(limits = c(1:12)) +
  ggtitle("Vuelos por mes de aerolínea Delta", 
          subtitle = "Luego de agrupar")

# Tarea Nº10

hs92_db = dbConnect(RSQLite::SQLite(), "datasets/lecture2_hs92.sqlite")
dbListTables(hs92_db)

chl_chn_2014 = as_tibble(dbGetQuery(hs92_db, 
                                    'SELECT * FROM yod_hs92_6 WHERE origin = "chl" AND dest = "chn" AND year = "2014"'))
products_hs_92 = as_tibble(dbGetQuery(hs92_db, 'SELECT * FROM products_hs_92'))

exports_groups = chl_chn_2014 %>% 
  mutate(export_val = as.integer(export_val)) %>% 
  left_join(products_hs_92) %>% 
  select(group_name,export_val) %>% 
  group_by(group_name) %>% 
  summarise(export_val = sum(export_val, na.rm = TRUE)) %>% 
  ungroup() %>% 
  arrange(desc(export_val))

exports_groups %>% 
  group_by(group_name) %>% 
  mutate(pos = cumsum(0.5 * as.numeric(export_val))) %>% 
  ggplot(aes(y = export_val, x = reorder(group_name, export_val))) + 
  geom_col(fill = "#30729C", alpha = 0.7) + 
  coord_flip() +
  geom_text(aes(y = pos, label = format(export_val, big.mark = ",")), 
            colour = "black", size = 3, show.legend = F) + 
  labs(title = "Composici\u00f3n de las exportaciones a China ($)", 
       subtitle = "Fuente: Observatorio de la Complejidad Econ\u00f3mica",
       x = "Grupo de producto", 
       y = "D\u00f3lares")
