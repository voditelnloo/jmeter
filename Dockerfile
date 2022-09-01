FROM alpine:3.16.2

ARG JMETER_VERSION="5.5"

ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN  ${JMETER_HOME}/bin
ENV MIRROR_HOST https://archive.apache.org/dist/jmeter
ENV JMETER_DOWNLOAD_URL ${MIRROR_HOST}/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_PLUGINS_FOLDER ${JMETER_HOME}/lib/ext/
ENV JMETER_LIB_FOLDER ${JMETER_HOME}/lib/

RUN    apk update \
	&& apk upgrade \
	 && apk add --no-cache nss \
	&& apk add ca-certificates \
	&& update-ca-certificates \
            && apk add --update openjdk8-jre tzdata curl unzip bash \
            && cp /usr/share/zoneinfo/Europe/Kiev /etc/localtime \
            && echo "Europe/Kiev" >  /etc/timezone \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies
RUN chmod g+rwx launch.sh

COPY plugins/ ${JMETER_PLUGINS_FOLDER}
#COPY lib ${JMETER_LIB_FOLDER}
#COPY bin/ ${JMETER_BIN}

RUN curl -L https://jmeter-plugins.org/get/ > \
        $JMETER_PLUGINS_FOLDER/plugins-manager.jar && \
    curl -L http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar > \
        $JMETER_LIB_FOLDER/cmdrunner-2.2.jar && \
    java -cp $JMETER_PLUGINS_FOLDER/plugins-manager.jar \
        org.jmeterplugins.repository.PluginManagerCMDInstaller
#
RUN $JMETER_BIN/PluginsManagerCMD.sh install \
        jpgc-casutg,jpgc-tst,jpgc-ffw,jpgc-csl,jpgc-autostop,jpgc-functions,jpgc-dummy,jpgc-json,jpgc-sense
#
RUN $JMETER_BIN/PluginsManagerCMD.sh install-all-except

ENV PATH $PATH:$JMETER_BIN

COPY launch.sh /

WORKDIR ${JMETER_HOME}

ENTRYPOINT ["/launch.sh"]

