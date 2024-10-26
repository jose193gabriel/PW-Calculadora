# Calculadora CGI en Perl

Este es un proyecto de calculadora simple desarrollado en Perl utilizando CGI. La calculadora permite realizar operaciones matemáticas básicas.

## Requisitos

- Docker
- Perl

## Construir la Imagen de Docker

Para construir la imagen de Docker, navega al directorio donde se encuentra tu `Dockerfile` y ejecuta el siguiente comando:

```bash
docker build -t calculadora-cgi .
```
## Ejecutar el Contenedor

Una vez que la imagen se haya construido, puedes ejecutar el contenedor con el siguiente comando:
```bash
docker run -d -p 8094:80 calculadora-cgi
```
## Accede a la Calculadora
  http://127.0.0.1:8094
