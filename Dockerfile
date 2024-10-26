# Usar Minideb como imagen base
FROM bitnami/minideb:latest

# Instalar Apache, Perl y el módulo CGI de Perl
RUN install_packages apache2 perl libapache2-mod-perl2 && \
    install_packages libcgi-pm-perl # Instalar CGI.pm para Perl

# Habilitar CGI en Apache
RUN a2enmod cgi && a2enmod perl

# Configurar Apache para ejecutar scripts CGI en /cgi-bin/ si no está definido previamente
RUN sed -i '/^ScriptAlias \/cgi-bin/d' /etc/apache2/conf-enabled/serve-cgi-bin.conf && \
    echo "ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/" >> /etc/apache2/conf-enabled/serve-cgi-bin.conf && \
    echo "<Directory \"/usr/lib/cgi-bin\">\n    AllowOverride None\n    Options +ExecCGI\n    Require all granted\n</Directory>" >> /etc/apache2/conf-enabled/serve-cgi-bin.conf

# Definir el ServerName para evitar advertencias
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copiar el archivo index.html al directorio raíz de Apache
COPY index.html /var/www/html/

# Copiar los archivos CSS al directorio raíz de Apache
COPY css /var/www/html/css

# Copiar la carpeta de imágenes al directorio raíz de Apache
COPY imagenes /var/www/html/imagenes

# Crear el directorio cgi-bin y copiar el script calcul.pl
COPY cgi-bin/calcul.pl /usr/lib/cgi-bin/
RUN chmod +x /usr/lib/cgi-bin/calcul.pl

# Exponer el puerto 80
EXPOSE 80

# Iniciar Apache en primer plano
CMD ["apachectl", "-D", "FOREGROUND"]