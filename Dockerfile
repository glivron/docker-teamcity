FROM glivron/tomcat-8

RUN apt-get -qq update         \
 && apt-get -qq install -y git \
 && apt-get -qq clean

RUN useradd -m teamcity \
 && mkdir /logs         \
 && chown -R teamcity:teamcity /apache-tomcat /logs

USER teamcity
WORKDIR /apache-tomcat

ENV CATALINA_OPTS                \
 -server                         \
 -Xms1g                          \
 -Xmx2g                          \
 -Xss256k                        \
 -XX:+UseCompressedOops          \
 -XX:ReservedCodeCacheSize=350m  \
 -Djsse.enableSNIExtension=false \
 -Djava.awt.headless=true        \
 -Dfile.encoding=UTF-8           \
 -Duser.timezone=Europe/Paris

RUN sed -i 's/connectionTimeout="20000"/connectionTimeout="60000" useBodyEncodingForURI="true" socket.txBufSize="64000" socket.rxBufSize="64000"/' conf/server.xml

VOLUME ["/home/teamcity"]
EXPOSE 8080 9875
CMD ["./bin/catalina.sh", "run"]

# --------------------------------------------------------------------- teamcity
ENV TEAMCITY_VERSION 10.0.4

RUN curl -LO http://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war -d webapps/teamcity                   \
 && rm -f TeamCity-$TEAMCITY_VERSION.war                                           \

 && rm -f  webapps/teamcity/WEB-INF/plugins/clearcase.zip                  \
 && rm -f  webapps/teamcity/WEB-INF/plugins/mercurial.zip                  \
 && rm -f  webapps/teamcity/WEB-INF/plugins/eclipse-plugin-distributor.zip \
 && rm -f  webapps/teamcity/WEB-INF/plugins/vs-addin-distributor.zip       \
 && rm -f  webapps/teamcity/WEB-INF/plugins/win32-distributor.zip          \
 && rm -fR webapps/teamcity/WEB-INF/plugins/tfs                            \
 && rm -fR webapps/teamcity/WEB-INF/plugins/vss                            \
 && rm -fR webapps/teamcity/WEB-INF/plugins/dot*                           \
 && rm -fR webapps/teamcity/WEB-INF/plugins/visualstudiotest               \
 && rm -fR webapps/teamcity/WEB-INF/plugins/windowsTray                    \

 && echo '\n<meta name="mobile-web-app-capable" content="yes"/>' >> webapps/teamcity/WEB-INF/tags/pageMeta.tag \
 && echo '\n<meta name="theme-color" content="#18a3fa"/>'        >> webapps/teamcity/WEB-INF/tags/pageMeta.tag

# ---------------------------------------------------- slack notification plugin
ENV SLACK_NOTIFICATION_PLUGIN_VERSION 1.4.6

RUN cd webapps/teamcity/WEB-INF/plugins \
 && curl -LO https://github.com/PeteGoo/tcSlackBuildNotifier/releases/download/v$SLACK_NOTIFICATION_PLUGIN_VERSION/tcSlackNotificationsPlugin.zip
 
# -------------------------------------------------------- browser notify plugin
ENV BROWSER_NOTIFY_PLUGIN_VERSION 1.0.1

RUN cd webapps/teamcity/WEB-INF/plugins \
 && curl -LO https://github.com/grundic/teamcity-browser-notify/releases/download/v$BROWSER_NOTIFY_PLUGIN_VERSION/teamcity-browser-notify-$BROWSER_NOTIFY_PLUGIN_VERSION.zip
