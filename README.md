# Proyecto3
Proyecto 3 para Dispositivos Móviles sobre una API RES pública

# GameExplorer App

Aplicación móvil desarrollada en Flutter que permite explorar un catálogo de videojuegos utilizando la API REST pública de [RAWG](https://rawg.io/apidocs). Este proyecto fue realizado como parte del módulo de **Programación de Dispositivos Móviles**.

## Descripción

**GameExplorer** es una app que permite al usuario:

- Buscar videojuegos por nombre.
- Explorar títulos por popularidad o fecha de lanzamiento.
- Visualizar detalles como: nombre, descripción, plataformas, géneros, rating y carátula.
- Guardar juegos como "Favoritos" (almacenamiento local).

El proyecto consume la API REST pública de RAWG para mostrar datos reales y actualizados del mundo gamer.

## Tecnologías Utilizadas

- **Flutter 3.x**
- **Dart**
- **HTTP package** (para consumir la API)
- **Provider** (para gestión de estado)
- **SharedPreferences** (para persistencia local de favoritos)
- **RAWG API** (fuente externa de datos)

## Clave API de RAWG

Para utilizar la aplicación correctamente, debes obtener una API Key gratuita desde:  
[https://rawg.io/apidocs](https://rawg.io/apidocs)

