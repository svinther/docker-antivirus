FROM logiva/cgi-microservice:1.1

LABEL maintainer="Steffen Vinther Sørensen <svs@logiva.dk>"

RUN apt -y update \
&& apt -y install clamav-daemon python3 \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean

RUN sed -i \
-e 's/Foreground.*/Foreground true/' \
-e 's/MaxScanSize.*/MaxScanSize 250M/' \
-e 's/MaxFileSize.*/MaxFileSize 150M/' \
-e '/^LogFile.*/d' \
/etc/clamav/clamd.conf

COPY freshclam.conf /etc/clamav/freshclam.conf
RUN freshclam

ADD 30-start-clamd.sh /poorman-init.d/
ADD 40-start-freshclam.sh /poorman-init.d/
RUN chmod +x /poorman-init.d/30-start-clamd.sh /poorman-init.d/40-start-freshclam.sh

ADD index.html /var/www/html
ADD antivirus.py /usr/lib/cgi-bin/
RUN chmod +x /usr/lib/cgi-bin/antivirus.py

RUN sed -i '/url.rewrite-once/d' /etc/lighttpd/lighttpd.conf \
&& echo 'url.rewrite-once += ( "^/av$" => "/cgi-bin/antivirus.py" )' >> /etc/lighttpd/lighttpd.conf \
&& echo 'url.rewrite-once += ( "^/avform$" => "/index.html" )' >> /etc/lighttpd/lighttpd.conf \
&& echo 'url.rewrite-once += ( "^/$" => "/index.html" )' >> /etc/lighttpd/lighttpd.conf

VOLUME /var/lib/clamav/

