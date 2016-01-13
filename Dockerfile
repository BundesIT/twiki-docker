FROM ubuntu:14.04
MAINTAINER Thomas Berger <th.berger@it.piratenpartei.de>

ENV TWIKI_VERSION 6.0.2

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get -y dist-upgrade && apt-get -y install apache2 rcs diffutils zip cron make gcc g++ pkg-config libssl-dev

ADD http://sourceforge.net/projects/twiki/files/TWiki%20for%20all%20Platforms/TWiki-${TWIKI_VERSION}/TWiki-${TWIKI_VERSION}.tgz/download ./TWiki-${TWIKI_VERSION}.tgz
RUN mkdir -p /var/www && tar xfv TWiki-${TWIKI_VERSION}.tgz -C /var/www && rm TWiki-${TWIKI_VERSION}.tgz

ADD perl/cpanfile /tmp/cpanfile
ADD http://cpansearch.perl.org/src/THALJEF/Pinto-0.09995/etc/cpanm /tmp/cpanm

RUN chmod +x /tmp/cpanm && /tmp/cpanm -l /var/www/twiki/lib/CPAN --installdeps /tmp/ && rm -rf /.cpanm /tmp/cpanm /tmp/cpanfile /var/www/twiki/lib/CPAN/man

ADD configs/vhost.conf /etc/apache2/sites-available/twiki.conf
ADD configs/LocalLib.cfg  /var/www/twiki/bin/LocalLib.cfg
ADD configs/LocalSite.cfg /var/www/twiki/lib/LocalSite.cfg
ADD configs/setlib.cfg /var/www/twiki/bin/setlib.cfg
ADD bin/prepare-env.sh /prepare-env.sh
ADD bin/run.sh /run.sh
RUN a2enmod cgi expires && a2dissite '*' && a2ensite twiki.conf && chown -cR www-data: /var/www/twiki && chmod +x /prepare-env.sh

VOLUME ["/data"]
ENTRYPOINT "/run.sh"

EXPOSE 80
