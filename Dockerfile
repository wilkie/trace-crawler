FROM ubuntu:18.04

RUN apt-get update -qq && \
    apt-get upgrade -yq && \
    apt-mark hold openjdk-11-jre-headless && \
    apt-get install -yq --no-install-recommends  apt-transport-https apt-utils ca-certificates curl git-core gnupg \
                                                                              jq \
                                                                         less maven  openjdk-8-jdk-headless  sudo \
                                                                        supervisor  wget tar  emacs zookeeperd gcc
RUN apt-get install -y libffi-dev libssl-dev python3.6  python3-pip libjpeg-dev python3.6-dev python3-setuptools
#RUN apt-get remove python-pip
RUN pip3 install --upgrade pip

#python3-pip
#
# Apache Storm
#
ENV STORM_VERSION=1.2.2
COPY storm-docker-conf/downloads/apache-storm-$STORM_VERSION  /usr/local/apache-storm-$STORM_VERSION
ENV STORM_HOME /usr/local/apache-storm-$STORM_VERSION
RUN groupadd storm && \
    useradd --gid storm --home-dir /home/storm \
                  --create-home --shell /bin/bash storm && \
                  chown -R storm:storm $STORM_HOME && \
                  mkdir /var/log/storm && \
                  chown -R storm:storm /var/log/storm
RUN ln -s /var/log/storm $STORM_HOME/logs
RUN ln -s $STORM_HOME/bin/storm /usr/bin/storm
#ADD etc/supervisor/conf.d/storm-*.conf   /etc/supervisor/conf.d/
#ADD etc/supervisor/conf.d/zookeeper.conf /etc/supervisor/conf.d/
#RUN chmod -R 644 /etc/supervisor/conf.d/*.conf
WORKDIR /tracer-crawler




#ADD portals-crawler/src /tracer-crawler
RUN cd /tracer-crawler
#RUN mvn clean package
RUN mkdir /warcs

RUN pip3 install --user  warcprox==2.3

#RUN pip3 install git+https://github.com/internetarchive/warcprox.git
RUN mkdir tmp
COPY portals-crawler/target/stormcapture-0.2.jar /tracer-crawler/tracer-crawler.jar
COPY storm-docker-conf/crawler-conf-docker.yaml /tracer-crawler/crawler-conf-docker.yaml
COPY seeds/seedswithtraces.txt  /tracer-crawler/seedswithtraces.txt
RUN ls -la
#inject seeds and traces to mysql
CMD storm jar tracer-crawler.jar  gov.lanl.crawler.SeedInjector  seedswithtraces.txt   -local -conf crawler-conf-docker.yaml
#CMD storm jar target/stormcrawler-0.1.jar gov.lanl.crawler.CrawlTopology -conf crawler-conf.yaml -local

