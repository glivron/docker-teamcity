FROM glivron/tomcat-8

ENV TEAMCITY_VERSION 2017.2.3
ENV SLACK_NOTIFICATION_PLUGIN_VERSION 1.4.6

RUN apt-get -qq update         \
 && apt-get -qq install -y git \
 && apt-get -qq clean          \

 && sed -i 's/connectionTimeout="20000"/connectionTimeout="60000" useBodyEncodingForURI="true" socket.txBufSize="64000" socket.rxBufSize="64000"/' conf/server.xml \

 # --------------------------------------------------------------------- teamcity
 && curl -LO https://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war -d webapps/ROOT                        \
 && rm -f TeamCity-$TEAMCITY_VERSION.war                                            \

 && ls -l  webapps/ROOT/WEB-INF/lib/             \
 && rm -f  webapps/ROOT/WEB-INF/lib/tomcat-*.jar \

 && rm -f  webapps/ROOT/update/agentInstaller.exe                      \
 && rm -f  webapps/ROOT/WEB-INF/plugins/clearcase.zip                  \
 && rm -f  webapps/ROOT/WEB-INF/plugins/cloud-vmware.zip               \
 && rm -f  webapps/ROOT/WEB-INF/plugins/deploy-runner.zip              \
 && rm -f  webapps/ROOT/WEB-INF/plugins/mercurial.zip                  \
 && rm -f  webapps/ROOT/WEB-INF/plugins/eclipse-plugin-distributor.zip \
 && rm -f  webapps/ROOT/WEB-INF/plugins/vs-addin-distributor.zip       \
 && rm -f  webapps/ROOT/WEB-INF/plugins/win32-distributor.zip          \
 && rm -f  webapps/ROOT/WEB-INF/plugins/xcode-runner.zip               \
 && rm -fr webapps/ROOT/WEB-INF/plugins/ant*                           \
 && rm -fr webapps/ROOT/WEB-INF/plugins/bugzilla                       \
 && rm -fr webapps/ROOT/WEB-INF/plugins/cloud-amazon                   \
 && rm -fr webapps/ROOT/WEB-INF/plugins/charisma                       \
 && rm -fr webapps/ROOT/WEB-INF/plugins/cvs                            \
 && rm -fr webapps/ROOT/WEB-INF/plugins/feed                           \
 && rm -fr webapps/ROOT/WEB-INF/plugins/email                          \
 && rm -fr webapps/ROOT/WEB-INF/plugins/gantRunner                     \
 && rm -fr webapps/ROOT/WEB-INF/plugins/jabber                         \
 && rm -fr webapps/ROOT/WEB-INF/plugins/jira                           \
 && rm -fr webapps/ROOT/WEB-INF/plugins/Maven2                         \
 && rm -fr webapps/ROOT/WEB-INF/plugins/nt-domain-login                \
 && rm -fr webapps/ROOT/WEB-INF/plugins/gant-tool                      \
 && rm -fr webapps/ROOT/WEB-INF/plugins/starteam                       \
 && rm -fr webapps/ROOT/WEB-INF/plugins/tfs                            \
 && rm -fr webapps/ROOT/WEB-INF/plugins/svn                            \
 && rm -fr webapps/ROOT/WEB-INF/plugins/vss                            \
 && rm -fr webapps/ROOT/WEB-INF/plugins/dot*                           \
 && rm -fr webapps/ROOT/WEB-INF/plugins/usage-statistics               \
 && rm -fr webapps/ROOT/WEB-INF/plugins/visualstudiotest               \
 && rm -fr webapps/ROOT/WEB-INF/plugins/windowsTray                    \

 && echo '\n<meta name="mobile-web-app-capable" content="yes"/>' >> webapps/ROOT/WEB-INF/tags/pageMeta.tag \
 && echo '\n<meta name="theme-color" content="#18a3fa"/>'        >> webapps/ROOT/WEB-INF/tags/pageMeta.tag \

# ---------------------------------------------------- slack notification plugin
 && cd webapps/ROOT/plugins \
 && curl -LO https://github.com/PeteGoo/tcSlackBuildNotifier/releases/download/v$SLACK_NOTIFICATION_PLUGIN_VERSION/tcSlackNotificationsPlugin.zip


ENV CATALINA_OPTS                 \
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

RUN useradd -m teamcity \
 && mkdir /var/lib/logs \
 && chown -R teamcity:teamcity /var/lib/tomcat /var/lib/logs

USER teamcity
VOLUME ["/home/teamcity"]
