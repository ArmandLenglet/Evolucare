FROM debian:buster

RUN apt-get update \
&& apt-get install -y software-properties-common bc unzip libmpfr6 libsigsegv2 curl wget liblocale-gettext-perl \ libtext-iconv-perl \ libtext-wrapi18n-perl \ libtext-charwidth-perl \ \
&& rm -rf /var/lib/apt/lists/*

COPY C:\Users\a.lenglet\OneDrive - EVOLUCARE TECHNOLOGIES\Documents\Dev_downloads\package-bdd.zip /home/depotbdd/

RUN cd /home/depotbdd/ \
&& unzip package-bdd.zip \
&& chmod +x install.sh \
&& ./install.sh