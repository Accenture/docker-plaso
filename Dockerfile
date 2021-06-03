FROM ubuntu:focal
MAINTAINER @accenturecifr

ENV version 1.1.0
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq -y update && \
        apt-get -qq -y --no-install-recommends install \
            software-properties-common \
            apt-transport-https \
            apt-utils \
            debfoster \
            software-properties-common && \
        add-apt-repository -u -y ppa:gift/stable
RUN     apt-get -qq -y update && \
            apt-get -y --no-install-recommends install \
            curl \
            python3-plaso \
            plaso-tools \
            plaso-data

RUN curl -s -o /usr/bin/cdqr.py https://raw.githubusercontent.com/orlikoski/CDQR/master/src/cdqr.py
RUN chmod 755 /usr/bin/cdqr.py

RUN echo plaso-tools > /var/lib/debfoster/keepers && \
                echo y | debfoster -f && \
            apt-get -qq -y clean && \
            apt-get -qq -y autoclean && \
            apt-get -qq -y autoremove


RUN useradd plaso

WORKDIR /home/plaso/
ENV HOME /home/plaso

RUN chown -R plaso /home/plaso/

VOLUME ["/data"]
USER plaso
