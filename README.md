# GameExplorer App

Es una app desarrollada en Flutter que permite explorar un catálogo de videojuegos utilizando la API REST pública de RAWG(https://rawg.io/apidocs). Permitiendole al usuario cumplir el sueño de tener toda la información sobre sus títulos favoritos en un solo lugar

## Descripción

**GameExplorer** es una app que permite al usuario:

- Buscar videojuegos por nombre
- Filtrar búsqueda por categorías, consolas, año de lanzamiento y restricción de edad.
- Crear una biblioteca digital personal con todos tus juegos favoritos
- Leer información sobre cada título
- Ver una reseña general del mismo
- Visualizar detalles de cada videojugo como: nombre, descripcion, plataforma, género, año de lanzamiento, reseña y carátula.
- Explorar videojuegos por popularidad y ver recomendaciones que la app te ofrece para jugar.

El proyecto consume la API REST pública de RAWG para mostrar datos reales y actualizados del mundo gamer.

## Pruebas de funcionamiento 
Para validar el correcto funcionamiento de la API de RAWG en la aplicación se realizaron las siguientes pruebas:
- Se consumió el endpoint 'https://api.rawg.io/api/games' con una API KEY pública válida.
- Se mostraron videojuegos populares correctamente en la aplicación.
- Se verificó que se accede al detalle de un juego, mostrando su nombre, imagen y rating.

## Evidencias
![Consola con respuesta exitosa](assets/screenshot2.png)  
![Resultado visual de la lista de juegos](assets/screenshot1.png)

## Estructura del Proyecto

### 📂 api/
- rawg_api.dart = Servicio para consumir la API de RAWG
### 📂 models/ Representa los objetos que trae la API (Game, Genre, etc.).
- game.dart = Modelo de datos del videojuego.
### 📂 providers/ Uno para los juegos cargados y búsqueda, otro para favoritos.
- game_provider.dart = Estado de búsqueda y resultados.
- favorites_provider.dart = Estado de favoritos.
### 📂 screens/ Separar permite modularidad y navegación clara.
- home_screen.dart = Pantalla principal con juegos populares
- search_screen.dart = Pantalla con filtros y resultados de búsqueda.
- detail_screen.dart = Pantalla de detalle de un juego.
- favorites_screen.dart = Biblioteca personal (favoritos).
### 📂 widgets/ Componentes reutilizables como tarjetas, buscador, filtros, etc.
- game_card.dart = Widget para mostrar juego en lista.
- filter_drawer.dart = Widget para los filtros de búsqueda.
- search_bar.dart = Widget para buscar.
### 📂 utils/ API key
- api_key.dart = Clave privada de la API.
### 📂 constants/ formatos, helpers o listas constantes (como restricciones de edad).
- filters.dart = Listas fijas de géneros, edades, plataformas.
### 📂 assets/
- Evidencias de las pruebas de API
### 📂 themes/
- theme.dart
- util.dart
## Tecnologías Utilizadas

- **Flutter 3.x**
- **Dart**
- **HTTP package** (para consumir la API)
- **Provider** (para gestión de estado)
- **SharedPreferences** (para persistencia local de favoritos)
- **RAWG API** (fuente externa de datos)

## API de RAWG

La clave API fue sacada directamente desde la página de RAWG.IO tras crear una cuenta dentro de la página y solicitando acceso a la API KEY que nos permitió trabajar directamente con esta API RES pública.
[https://rawg.io/apidocs](https://rawg.io/apidocs)

