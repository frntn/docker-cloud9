# --- Cloud9 ---

FROM node
MAINTAINER Matthieu Fronton <fronton@ekino.com>

RUN git clone https://github.com/c9/core.git /opt/cloud9
WORKDIR /opt/cloud9
RUN scripts/install-sdk.sh
RUN sed -i -e 's/127.0.0.1/0.0.0.0/g' /opt/cloud9/configs/standalone.js 

########################
#   START ekino/base
#
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
# prerequisites
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y curl supervisor vim unzip
# cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
# configure
ENV TIMEZONE Europe/Paris
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure tzdata
# ekino user/group
RUN groupadd -g 42310 ekino && useradd -g 42310 -u 42310 -d /home/ekino -m -s /bin/bash ekino
# supervisor conf
ADD supervisord.conf /etc/supervisor/conf.d/cloud9.conf
#
#   END ekino/base
######################

RUN mkdir /workspace
EXPOSE 80
CMD ["supervisord","-n","-e","trace","-c","/etc/supervisor/supervisord.conf"]
