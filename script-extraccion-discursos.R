##########################################################################
#                                                                        #
#                                                                        #
#         Laboratorio 2 - Datos Elegantes, Crawling y Scrapping          #
#           Gianpaul Custodio - Julio Fuerte - Lenin Valles              #
#                                                                        #
##########################################################################

#Datos Elegantes & Análisis de Datos con Web Scrapping

# Los paquetes que utilizaremos
library(httr)
library(rvest)
library(stringr)
library(readr)
library(XML)
library(xml2)
library(ggplot2)
library(dplyr)
library(graphics)
library(shiny)


#########################################################################
##Pregunta 1: Programa de tipo web scrapping con el que podemos obtener
##una página web, mediante su URL, y analizar su contenido HTML con tal 
##de extraer datos e información específica.

##Pregunta 1.1 . Descargar la página web de la URL indicada, y almacenarlo 
##en un formato de R apto para ser tratado.

#Definir la URL de la página web que quieres descargar
url <- GET("https://www.mediawiki.org/wiki/MediaWiki")
#Recuperar el contenido de la solicitud
contenido <- rvest::read_html(url)
#Imprimir resultado
print(contenido)
cat("La página web se ha mostrado correctamente")


##Pregunta 1.2. Analizar el contenido de la web, buscando el título de la 
##página (que en HTML se etiqueta como “title”).

#Definir la URL de la página web 
url <- GET("https://www.mediawiki.org/wiki/MediaWiki")
#Recuperar el contenido de la solicitud
contenidoweb <- rvest::read_html(url)
# Convertir contenido web a formato "UTF-8"
contenidoweb_titulo<- htmlParse(contenidoweb, encoding="UTF-8")
# Buscar el título de la página utilizando xpathSApply()
Titulo_Web <- xpathSApply(contenidoweb_titulo, "//title",xmlValue)
# Imprimir el título
cat("Título de la página:", Titulo_Web,"\n")


##Pregunta 1.3. Analizar el contenido de la web con todos los enlaces 
##(que en HTML se etiquetan como “a”).

# Load the XML library
library(XML)
library(httr)
library(rvest)
library(xml2)
pagina <- "https://www.mediawiki.org/wiki/MediaWiki"
html <- rvest::read_html(pagina)
#print(html)
html %>% html_elements("a")

##Pregunta 1.4. Analizar el contenido de la web, buscando el título de la 
##página (que en HTML se etiqueta como “title”).


#Definir la URL de la página web 
pagina <- "https://www.mediawiki.org/wiki/MediaWiki"
#Recuperar el contenido de la solicitud
html <- rvest::read_html(pagina)
#Asignamos el contenido a enlaces
enlaces <- html %>% html_elements("a")
df <- data.frame(
  url = enlaces %>% html_attr("href"),
  texto = enlaces %>% html_text2()
)
#Determinamos la cantidad de veces que aparece el enlace
nveces_enlace <- nrow(df)
View(nveces_enlace)

##Pregunta 1.5. Para cada enlace, seguirlo e indicar si está activo (podemos 
##usar el código de status HTTP al hacer una petición a esa URL). 

library(httr)

# Definir la URL que deseas verificar
url <- "https://www.mediawiki.org/wiki/MediaWiki"

# Enviar una solicitud HEAD a la URL
response <- HEAD(url)
# Obtener el código de estado HTTP
status_code <- response$status_code
# Imprimir el código de estado HTTP
print(status_code)
#Convertir URL relativa a absoluta
df$url <- ifelse(grepl("^http", df$url), df$url, paste0("https://www.mediawiki.org/wiki/MediaWiki", df$url))
df$url <- ifelse(grepl("^//", df$url), paste0("https:", df$url), df$url)

# Iteramos sobre cada fila del data frame
for (i in 1:nrow(df)) {
  # Obtenemos la URL de la fila actual
  URL1 <- df[i, "url"]
  
  # Verificamos si la URL es relativa o absoluta
  if (grepl("^http", URL1)) {
    # Si la URL es absoluta, hacemos una petición HTTP directamente
    response <- httr::GET(URL1)
  } else {
    # Si la URL es relativa, le añadimos el dominio de la página
    domain <- "https://www.mediawiki.org/wiki/MediaWiki"
    URL1 <- paste0(domain, URL1)
    response <- httr::GET(URL1)
  }
  
  
  # Extraemos el código de estado HTTP de la respuesta
  status_code <- response$status_code
  
  # Guardamos el código de estado HTTP en una nueva columna
  df[i, "responseCode"] <- status_code
  
  # Esperamos unos segundos antes de hacer la siguiente petición
  Sys.sleep(0.2)
}

# Verificar si se ha convertido correctamente
View(df)
print(df)


##############################################################################

## Gráficos en R



##Pregunta 2.1: Elaborar un histograma con la frecuencia de aparición de 
#los enlaces, pero separado por URLs absolutas (con “http…”) y URLs relativas.
# Añadir una columna para indicar si la URL es absoluta


df <- df %>% mutate(is_absolute = str_detect(url, "^http(s)?://"))

df_enlaces$is_absolute <- sapply(df_enlaces$enlace, absoluto)

ggplot2::ggplot(data=df_enlaces)+facet_wrap(~absoluto)+ geom_bar(aes(x = Enlace))


#Pregunta 2.2: Un gráfico de barras indicando la suma de enlaces que apuntan a otros dominios o servicios (distinto a https://www.mediawiki.org en el caso de
#ejemplo) vs. la suma de los otros enlaces. Aquí queremos distinguir enlaces que apuntan a mediawiki versus el resto.
#Sabemos que las URLs relativas ya apuntan dentro, por lo tanto hay que analizar las URLs absolutas y comprobar que apunten a https://www.mediawiki.org.
#Añadiremos a nuestro data.frame una columna indicando si el enlace es interno o no. Usaremos base, lattice o ggplot para generar este gráfico de barras, donde
#cada barra indicará la suma de enlaces para cada grupo. El grafico resultado lo uniremos con los anteriores, en una sola imagen.

df_enlaces$mediawiki <- sapply(df_enlaces$Enlace, mediawiki)

ggplot2::ggplot(data=df_enlaces)+ geom_bar(aes(x = mediawiki))


#Pregunta 2.3: Un gráfico de tarta (pie chart) indicando los porcentajes de Status de nuestro
#análisis. Por ejemplo, si hay 6 enlaces con status “200” y 4 enlaces con status “404”, la tarta mostrará un 60% con la etiqueta “200” y 
#un 40% con la etiqueta “404”. Este gráfico lo uniremos a los anteriores. El objetivo final es obtener una imagen que recopile los gráficos generados.
#Usad la capacidad de R y ggplot2 para componer gráficos en una sola figura. Si tales gráficos están compuestos directamente desde R 
#(y no en el documento memoria), se puntuará mejor.


df_Enlaces <- data_enlaces %>% count(Estado)
totalEnlaces <- sum(df_Enlaces$n)
df_Enlaces$porcentaje <- (df_Enlaces$n / totalEnlaces) * 100

df_Enlaces <- transform(df_Enlaces, Estado = as.character(Estado))

# mostrar grafico de tarta
ggplot(df_Enlaces, aes(x = "", y = porcentaje, fill = Estado)) + geom_bar(stat = "identity", width = 1) + coord_polar("y", start = 0)

ggplot2::ggplot(data=df_enlaces,aes(x="",y=enlace_activo,fill=enlace_activo))+ geom_bar(width=1,stat = "identity")+ coord_polar("y", start=0)





