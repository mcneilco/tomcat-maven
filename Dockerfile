FROM centos:centos6

USER    root

#UTILITIES
RUN		yum install -y wget
RUN		yum install -y tar

#JAVA (OPENJDK 8)
ENV JAVA_VERSION 1.8.0

RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

ENV JAVA_HOME /usr/lib/jvm/java

#TOMCAT 6
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME


ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.79

RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    mv apache-tomcat-${TOMCAT_MINOR_VERSION}/* . && \
    rm -rf apache-tomcat-*

#MAVEN
ENV MAVEN_VERSION_MAJOR 3
ENV MAVEN_VERSION_MINOR 5.2

RUN    wget http://apache.mirrors.pair.com/maven/maven-${MAVEN_VERSION_MAJOR}/${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}/binaries/apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}-bin.tar.gz
RUN tar xvf apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}-bin.tar.gz
RUN rm apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}-bin.tar.gz
RUN mv apache-maven-${MAVEN_VERSION_MAJOR}.${MAVEN_VERSION_MINOR}  /usr/local/apache-maven
ENV M2_HOME=/usr/local/apache-maven
ENV M2=$M2_HOME/bin
ENV PATH=$M2:$PATH

CMD  java -version && mvn -version
