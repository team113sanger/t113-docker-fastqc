FROM ubuntu:18.04 as builder

USER root

# Locale
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# ALL tool versions used by opt-build.sh
ENV VER_FASTQC="0.11.9"

RUN apt-get -yq update
RUN apt-get install -yq \
  openjdk-11-jre \
  curl \
  unzip

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

FROM ubuntu:18.04

LABEL maintainer="vo1@sanger.ac.uk" \
      version="0.11.9" \
      description="FastQC"

MAINTAINER  Victoria Offord <vo1@sanger.ac.uk>

RUN apt-get -yq update

RUN apt-get install -yq --no-install-recommends \
  openjdk-11-jre \
  xvfb \
  perl-modules

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$OPT/python3/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib
ENV PYTHONPATH $OPT/python3:$OPT/python3/lib/python3.6/site-packages
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

#Create some usefull symlinks
RUN cd /usr/local/bin && \
    ln -s /usr/bin/python3 python

RUN cd $OPT/bin && \
    ln -s $OPT/FastQC/fastqc .

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
