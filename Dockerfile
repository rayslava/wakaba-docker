FROM ubuntu:14.04
MAINTAINER Slava Barinov <rayslava@gmail.com>
ENV WAKABA_VER="3.0.9"

RUN apt-get -qq dist-upgrade -y
RUN apt-get -qq update -y
RUN apt-get -qq --yes --force-yes install python-software-properties
RUN apt-get -qq --yes --force-yes install software-properties-common 
RUN apt-get -qq update -y

# Setting up build environment
RUN apt-get -qq --yes --force-yes install curl perl libdbd-sqlite3-perl unzip perlmagick nginx libfcgi-perl libjpeg-turbo-progs netpbm

# Setting up FastCGI for nginx
RUN curl http://nginxlibrary.com/downloads/perl-fcgi/fastcgi-wrapper -o /usr/bin/fastcgi-wrapper.pl
RUN curl http://nginxlibrary.com/downloads/perl-fcgi/perl-fcgi -o /etc/init.d/perl-fcgi
RUN chmod +x /usr/bin/fastcgi-wrapper.pl
RUN chmod +x /etc/init.d/perl-fcgi
RUN update-rc.d perl-fcgi defaults

RUN cd /root && curl -OL "https://wakaba.c3.cx/releases/Wakaba/wakaba_${WAKABA_VER}.zip" && unzip wakaba_${WAKABA_VER}.zip && rm wakaba_${WAKABA_VER}.zip
RUN cd /root/wakaba 
RUN sed -e '/FASTCGI_USER/s/=.*/=root/' -i /etc/init.d/perl-fcgi
RUN sed -e '/^user.*;$/s/user.*/user root;/' -i /etc/nginx/nginx.conf
ADD ./nginx.conf /etc/nginx/sites-available/wakaba.conf
RUN ln -s /etc/nginx/sites-available/wakaba.conf /etc/nginx/sites-enabled/wakaba.conf
RUN rm /etc/nginx/sites-enabled/default
RUN service nginx restart

ADD ./startup.sh /root/startup.sh
ADD ./config.pl /root/wakaba/config.pl
RUN chmod +x /root/startup.sh
RUN chmod +x /root/wakaba/config.pl

EXPOSE 80

ENTRYPOINT ["/root/startup.sh"]
