FROM debian:buster-20210621

RUN apt-get update \
&& apt-get upgrade -y \
&& apt-get install -y curl software-properties-common wget unzip \
&& rm -rf /var/lib/apt/lists/*

COPY C:/tmp/imgprd-appdeb10-9.0.1.3v3.tar.gz /home/depotapp/

RUN useradd -s /bin/bash -m support \
&& export PATH=$PATH:/usr/sbin

RUN apt-get update && apt-get install -y \
    fontconfig \
    libaudio2:amd64 \
    libfontconfig1:amd64 \
    libglx-mesa0:amd64 \
    libglx0:amd64 \
    libice6:amd64 \
    libllvm7:amd64 \
    libqt4-opengl:amd64 \
    libqtgui4:amd64 \
    libsm6:amd64 \
    libxcb-dri2-0:amd64 \
    libxcb-dri3-0:amd64 \
    libxcb-glx0:amd64 \
    libxcb-present0:amd64 \
    libxcb-sync1:amd64 \
    libxdamage1:amd64 \
    libxfixes3:amd64 \
    libxrender1:amd64 \
    libxt6:amd64 \
    libxxf86vm1:amd64 \
    qt-at-spi:amd64 \
    libgl1-mesa-dri:amd64 \
    libgl1:amd64 \
    libcgi-fast-perl \
    libcgi-pm-perl \
    libclass-accessor-perl \
    libencode-locale-perl \
    libfcgi-perl \
    libhtml-parser-perl \
    libhtml-tagset-perl \
    libhttp-date-perl \
    libhttp-message-perl \
    libio-html-perl \
    libio-string-perl \
    liblwp-mediatypes-perl \
    libparse-debianchangelog-perl \
    libsub-name-perl \
    libtimedate-perl \
    liburi-perl \
    binfmt-support \
    mono-runtime-common \
    mono-runtime-sgen \
    mono-runtime \
    ca-certificates-mono \
    libmono-corlib4.5-cil \
    libmono-i18n-west4.0-cil \
    libmono-i18n4.0-cil \
    libmono-system-configuration4.0-cil \
    libmono-system-core4.0-cil \
    libmono-system-numerics4.0-cil \
    libmono-system-xml4.0-cil \
    libmono-system4.0-cil \
    libglib2.0-cil \
    libmono-security4.0-cil \
    libmono-system-security4.0-cil

RUN cd /home/depotapp \
&& tar -zxvf /home/depotapp/imgprd-appdeb10-9.0.1.3v3.tar.gz \
&& cd imgprd-appdeb10/ \
&& bash install.sh prod