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

#Inclusión de Librerias
library(XML)
library(httr)
library(rvest)
library(xml2)
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
view(df)

##############################################################################


## Gráficos en R

##Pregunta 2.1: Elaborar n histograma con la frecuencia de aparición de 
#los enlaces, pero separado por URLs absolutas (con “http…”) y URLs relativas.

pagina <- "https://www.mediawiki.org/wiki/MediaWiki" 
html <- rvest::read_html(pagina)
enlaces <- html %>% html_elements("a")
df <- data.frame(
  url = enlaces %>% html_attr("href")
)
# Identificar URLs absolutas y relativas
urls_absolutas <- df[str_detect(df, "^https?://")]
urls_relativas <- df[str_detect(df, "^https?://")]
# Crear un data frame para el gráfico de barras
datos_grafico <- data.frame(
Tipo = df(rep("Absolutas", length(urls_absolutas)), rep("Relativas", length(urls_relativas))),
  Frecuencia = df(table(urls_absolutas), table(urls_relativas))
)

# Crear el histograma
ggplot(datos_grafico, aes(x = Frecuencia, fill = Tipo)) +
  geom_bar(stat = "count", position = "dodge") +
  labs(title = "Histograma de Frecuencia de Enlaces por Tipo",
       x = "Frecuencia",
       y = "Número de Enlaces") +
  theme_minimal()












