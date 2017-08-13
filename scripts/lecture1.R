###########
# CLASE 1
###########

# Tarea Nº1
  
### instalar y cargar pacman usando Base R
if (!require("pacman")) install.packages("pacman")

### instalar y/o cargar lo ya mencionado usando pacman
p_load(readr,readxl,dplyr,ggplot2,forcats)

####################################################################

# Tarea Nº2
  
### Paso 3:
  
mpg %>% 
  filter(year > 2000,
         cyl == 4)

### Paso 4:

mpg %>% 
  arrange(trans)

mpg %>% 
  arrange(-cty)

mpg %>% 
  arrange(trans,desc(cty),desc(hwy))

### Paso 5:

mpg %>% 
  filter(year == 2008, cyl == 4) %>% 
  arrange(cty)

####################################################################

# Tarea Nº3
  
### Paso 1:
  
folder = "datasets/"
file = paste0(folder,"lecture1_officesupplies.xlsx") 
### "paste0" pega elementos sin espacios
### "paste" agrega espacios

try(dir.create(folder))

if(!file.exists(file)) {
  download.file("http://pacha.datawheel.us/teaching/diplomado_uc/datasets/lecture1_officesupplies.xlsx",file)
}

### Paso 2:
  
officesupplies = read_excel(file)

### vista rápida de las columnas
str(officesupplies)

### convertir la columna Units a enteros
officesupplies = officesupplies %>% mutate(Units = as.integer(Units))

### regiones distintas
officesupplies %>% select(Region) %>% distinct()

### items distintos
officesupplies %>% select(Item) %>% distinct()

### unidades totales por región
officesupplies %>% 
  select(Region,Units) %>%
  group_by(Region) %>% 
  summarise(Sold_Units = sum(Units))

### unidades totales por item
officesupplies %>% 
  select(Item,Units) %>% 
  group_by(Item) %>% 
  summarise(Sold_Units = sum(Units))

### unidades totales por region e item
officesupplies %>% 
  select(Region,Item,Units) %>% 
  group_by(Region,Item) %>% 
  summarise(Sold_Units = sum(Units))

### Paso 3:
  
### ingreso por región e item
officesupplies %>% 
  select(Region,Item,Units,`Unit Price`) %>% 
  rename(Unit_Price = `Unit Price`) %>% 
  group_by(Region,Item) %>% 
  summarise(Income = sum(Units * Unit_Price))

### Paso 4:

officesupplies = officesupplies %>% 
  select(Region,Item,Units,`Unit Price`) %>% 
  rename(Unit_Price = `Unit Price`) %>% 
  mutate(Income = Units * Unit_Price) %>% 
  write_csv(paste0(folder,"office_supplies.csv"))

####################################################################
  
# Tarea Nº4
  
### Paso 1:
  
folder = "datasets/"
file = paste0(folder,"lecture1_copper.csv") 
### "paste0" pega elementos sin espacios
### "paste" agrega espacios

try(dir.create(folder))

if(!file.exists(file)) {
  download.file("http://pacha.datawheel.us/teaching/diplomado_uc/datasets/lecture1_copper.csv",file)
}

### Paso 2:

copper = read_csv(file)

### vista rápida de las columnas
str(copper)

### convertir a factor
copper = copper %>% 
  mutate(product = factor(product, levels = c("copper","others"),
                          labels = c("Cobre ","Pulpa de madera, fruta, salmón y otros")))

### Paso 3:

copper %>% 
  ggplot(aes(y = export, x = year, colour = product)) + 
  geom_line(size = 1.5) + 
  scale_x_continuous(breaks = seq(2006,2014,1)) +
  labs(title = "Composici\u00f3n de las exportaciones a China ($)", 
       subtitle = "Fuente: Aduana de Chile",
       x = "A\u00f1o", 
       y = "Millones de d\u00f3lares") + 
  scale_colour_manual(values = c("#40b8d0", "#b2d183"))
  
####################################################################

# Tarea Nº5
  
## Parte 1:

copper %>% 
  ggplot(aes(y = export, x = year, fill = product)) + 
  geom_area() + 
  scale_x_continuous(breaks = seq(2006,2014,1)) + 
  labs(title = "Composici\u00f3n de las exportaciones a China ($)", 
       subtitle = "Fuente: Aduana de Chile",
       x = "A\u00f1o", 
       y = "Millones de d\u00f3lares") + 
  scale_fill_manual(values = c("#40b8d0", "#b2d183"))

## Parte 2:

copper %>% 
  ggplot(aes(y = export, x = year, fill = fct_rev(product))) + 
  geom_area() + 
  scale_x_continuous(breaks = seq(2006,2014,1)) + 
  labs(title = "Composici\u00f3n de las exportaciones a China ($)", 
       subtitle = "Fuente: Aduana de Chile",
       x = "A\u00f1o", 
       y = "Millones de d\u00f3lares") + 
  scale_fill_manual(values = c("#b2d183","#40b8d0"))

## Parte 3:

copper %>%
  ggplot(aes(y = export, x = year, fill = fct_rev(product))) + 
  geom_col() + 
  scale_x_continuous(breaks = seq(2006,2014,1)) +
  labs(title = "Composici\u00f3n de las exportaciones a China ($)", 
       subtitle = "Fuente: Aduana de Chile",
       x = "A\u00f1o", 
       y = "Millones de d\u00f3lares") + 
  scale_fill_manual(values = c("#b2d183","#40b8d0"))

####################################################################

# Tarea Nº6
  
## Parte 1:

chart = copper %>%
  group_by(year) %>% 
  mutate(pos = cumsum(export) - (0.5 * export)) %>% 
  ggplot(aes(y = export, x = year, fill = fct_rev(product))) + 
  geom_col() + 
  geom_text(aes(x = year, y = pos, label = export), colour = "black", 
            size = 4, show.legend = F) + 
  scale_x_continuous(breaks = seq(2006,2014,1)) +
  labs(title = "Composici\u00f3n de las exportaciones a China ($)", 
       subtitle = "Fuente: Aduana de Chile",
       x = "A\u00f1o", 
       y = "Millones de d\u00f3lares")

## Parte 2:

chart +
  scale_fill_manual(values = c("#b2d183","#40b8d0")) + 
  theme_bw() +
  theme(legend.position = "bottom", legend.direction = "horizontal", 
      legend.title = element_blank()) +
  guides(fill = guide_legend(reverse = T))
