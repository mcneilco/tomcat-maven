FROM centos:centos8

USER    root

#UTILITIES
RUN		dnf install -y wget
RUN		dnf install -y tar

# NODE
ENV NPM_CONFIG_LOGLEVEL warn
ENV NODE_VERSION 14.15.1

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm -f "node-v$NODE_VERSION-linux-x64.tar.gz" \
  && npm install -g npm@latest \
  && npm install -g coffeescript properties underscore underscore-deep-extend properties-parser flat glob dotenv dotenv-expand
ENV NODE_PATH /usr/local/lib/node_modules

#JAVA (OPENJDK 8)
ENV JAVA_VERSION 1.8.0

RUN dnf install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

ENV JAVA_HOME /usr/lib/jvm/java

#TOMCAT
RUN	useradd -u 1000 -ms /bin/bash runner
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME" && chown runner:runner "$CATALINA_HOME"
ENV M2_HOME=/usr/local/apache-maven
ENV M2=$M2_HOME/bin
ENV PATH=$M2:$PATH
RUN mkdir -p "$M2_HOME" && chown runner:runner "$M2_HOME"

USER runner
WORKDIR $CATALINA_HOME


ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.5.70
ENV TOMCAT_LISTEN_ADDRESS=0.0.0.0

RUN wget -q https://downloads.apache.org/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://downloads.apache.org/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.sha512 | sha512sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    mv apache-tomcat-${TOMCAT_MINOR_VERSION}/* . && \
    sed -i 's/<Connector port="8080"/<Connector address="${listen.address}" port="8080"/' conf/server.xml && \
    rm -rf apache-tomcat-*

#MAVEN
ENV MAVEN_VERSION_MAJOR 3
ENV MAVEN_VERSION_MINOR 5.4

RUN wget -q http://apache.mirrors.pair.com/maven/maven-${MAVEN_VERSION_MAJOR}/${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}/binaries/apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}-bin.tar.gz
RUN tar xvf apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}-bin.tar.gz
RUN rm apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}-bin.tar.gz
RUN mv apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}/*  /usr/local/apache-maven/ && rmdir apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}

COPY --chown=runner:runner wait-for-it.sh ./wait-for-it.sh
RUN chmod 755 wait-for-it.sh
CMD  java -version && mvn -version
