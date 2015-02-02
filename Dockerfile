FROM ubuntu:14.04
MAINTAINER Rad Wojcik <radzhome@gmail.com>

##############################################################################
# base basic env setup
##############################################################################
#ENV DEBIAN_FRONTEND noninteractive  # Hides important output
RUN locale-gen  en_CA.UTF-8
ENV LANG en_CA.UTF-8
ENV LANGUAGE en_CA.UTF-8
ENV LC_ALL en_CA.UTF-8

##############################################################################
# update OS
##############################################################################
RUN apt-get -qq update


##############################################################################
# Install system python & tools
##############################################################################
RUN apt-get install -y build-essential python-dev
RUN apt-get install -y python python-pip vim  python-imaging wget python-software-properties
RUN apt-get install -y python-setuptools git-core

##############################################################################
# Install postgres, supervisor, libtiff, nginx
##############################################################################
RUN apt-get install -y postgresql-client-9.3 postgresql-client-common postgresql-9.3-postgis-scripts
RUN apt-get install -y supervisor python-psycopg2 nginx


##############################################################################
# Setup startup script for gunicorn WSGI service, dir for supervisord
##############################################################################
RUN groupadd webapps
RUN useradd webapp -G webapps
RUN mkdir -p /var/log/webapp/ && chmod 777 /var/log/webapp/
RUN mkdir -p /var/run/webapp/ && chmod 777 /var/run/webapp/
RUN mkdir -p /var/log/supervisor
RUN rm /etc/nginx/sites-enabled/default

##############################################################################
# Install pip requirements
##############################################################################
RUN pip install django Pillow psycopg2 gunicorn

##############################################################################
# Setup nginx
##############################################################################
ADD ./deploy/webapp.nginxconf /etc/nginx/sites-available/webapp.nginxconf
RUN ln -s /etc/nginx/sites-available/webapp.nginxconf /etc/nginx/sites-enabled/webapp.nginxconf

##############################################################################
# Configure supervisord
##############################################################################
ADD ./deploy/supervisor_conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD ./deploy/supervisor_conf.d/webapp.conf /etc/supervisor/conf.d/webapp.conf







