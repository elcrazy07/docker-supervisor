FROM        ubuntu:14.04
MAINTAINER  Elcrazy07 info@dicotraining.com


# Update the package repository
RUN apt-get update -y && apt-get upgrade -yqq


# Install base system
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl


# Install PHP 5.5
RUN apt-get update; apt-get install -y php5-cli php5 php5-mcrypt php5-curl php5-pgsql

# Install openssh
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd

# Add the student user with sudo permission
RUN useradd -m -d /home/student -s /bin/bash student
RUN echo student:student | chpasswd
RUN usermod -aG sudo student
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Configuracion of the supervisor
RUN mkdir -p /var/log/supervisor
COPY ./supervisord.conf /etc/supervisor/supervisord.conf

# Configure apache
ADD ./config/001-docker.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/001-docker.conf /etc/apache2/sites-enabled/


# Set Apache environment variables (can be changed on docker run with -e)
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www

EXPOSE 80 22
COPY ./scripts/info.php /var/www/html/info.php
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
