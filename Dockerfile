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
ENV TEAMCITY_VERSION 2017.1.1

RUN curl -LO https://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war -d webapps/teamcity                    \
 && rm -f TeamCity-$TEAMCITY_VERSION.war                                            \

 && rm -f  webapps/teamcity/WEB-INF/lib/tomcat-*.jar                                \
 && rm -f  webapps/teamcity/WEB-INF/lib/atmosphere-runtime-*.jar                    \

 && rm -f  webapps/teamcity/update/agentInstaller.exe                               \
 && rm -f  webapps/teamcity/WEB-INF/plugins/clearcase.zip                           \
 && rm -f  webapps/teamcity/WEB-INF/plugins/deploy-runner.zip                       \
 && rm -f  webapps/teamcity/WEB-INF/plugins/mercurial.zip                           \
 && rm -f  webapps/teamcity/WEB-INF/plugins/eclipse-plugin-distributor.zip          \
 && rm -f  webapps/teamcity/WEB-INF/plugins/vs-addin-distributor.zip                \
 && rm -f  webapps/teamcity/WEB-INF/plugins/win32-distributor.zip                   \
 && rm -fr webapps/teamcity/WEB-INF/plugins/ant*                                    \
 && rm -fr webapps/teamcity/WEB-INF/plugins/cloud-amazon                            \
 && rm -fr webapps/teamcity/WEB-INF/plugins/charisma                                \
 && rm -fr webapps/teamcity/WEB-INF/plugins/cvs                                     \
 && rm -fr webapps/teamcity/WEB-INF/plugins/feed                                    \
 && rm -fr webapps/teamcity/WEB-INF/plugins/email                                   \
 && rm -fr webapps/teamcity/WEB-INF/plugins/jabber                                  \
 && rm -fr webapps/teamcity/WEB-INF/plugins/Maven2                                  \
 && rm -fr webapps/teamcity/WEB-INF/plugins/gant-tool                               \
 && rm -fr webapps/teamcity/WEB-INF/plugins/tfs                                     \
 && rm -fr webapps/teamcity/WEB-INF/plugins/vss                                     \
 && rm -fr webapps/teamcity/WEB-INF/plugins/dot*                                    \
 && rm -fr webapps/teamcity/WEB-INF/plugins/usage-statistics                        \
 && rm -fr webapps/teamcity/WEB-INF/plugins/visualstudiotest                        \
 && rm -fr webapps/teamcity/WEB-INF/plugins/windowsTray                             \

 && echo '\n<meta name="mobile-web-app-capable" content="yes"/>' >> webapps/teamcity/WEB-INF/tags/pageMeta.tag \
 && echo '\n<meta name="theme-color" content="#18a3fa"/>'        >> webapps/teamcity/WEB-INF/tags/pageMeta.tag \

 && cd webapps/teamcity/WEB-INF/lib \
 && curl -LO https://jcenter.bintray.com/org/atmosphere/atmosphere-runtime/2.2.10/atmosphere-runtime-2.2.10.jar

# ---------------------------------------------------- slack notification plugin
ENV SLACK_NOTIFICATION_PLUGIN_VERSION 1.4.6

RUN cd webapps/teamcity/WEB-INF/plugins \
 && curl -LO https://github.com/PeteGoo/tcSlackBuildNotifier/releases/download/v$SLACK_NOTIFICATION_PLUGIN_VERSION/tcSlackNotificationsPlugin.zip
