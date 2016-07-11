# This image provides a base for building and running WildFly applications.
# It builds using maven and runs the resulting artifacts on WildFly 10.0.0 Final

FROM openshift/base-centos7

MAINTAINER Ben Parees <bparees@redhat.com>

EXPOSE 8080
EXPOSE 8009 
ENV TOMCAT_VERSION=8.0.36 \
    MAVEN_VERSION=3.3.9 \
    CATALINA_HOME=/usr/local/tomcat \
    PATH=$CATALINA_HOME/bin:$PATH  


LABEL io.k8s.description="Platform for building and running JEE applications on Tomcat8.0.23" \
      io.k8s.display-name="Tomcat8.0.23" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,tomcat,tomcat8,maven,java8" \
      io.openshift.s2i.destination="/opt/s2i/destination" 

ADD apache-tomcat.tar.gz /usr/local/

# Install Tomcat8.0.23
RUN INSTALL_PKGS="bc java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    mv /usr/local/apache-tomcat-8.0.36 $CATALINA_HOME && \
    rm -fr $CATALINA_HOME/webapps/* && \  
    mkdir -p /opt/s2i/destination

# Add s2i wildfly customizations
#ADD ./contrib/wfmodules/ /wildfly/modules/
#ADD ./contrib/wfbin/standalone.conf /wildfly/bin/standalone.conf
#ADD ./contrib/wfcfg/standalone.xml /wildfly/standalone/configuration/standalone.xml
#ADD ./contrib/settings.xml $HOME/.m2/

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./.s2i/bin/ $STI_SCRIPTS_PATH
#COPY ./.s2i/bin/ /usr/local/s2i

RUN chown -R 1001:0 $CATALINA_HOME && chown -R 1001:0 $HOME && \
    chmod -R ug+rw $CATALINA_HOME && \ 
    chmod -R g+rw /opt/s2i/destination && \
    chown -R 1001:1001 $HOME

USER 1001

CMD $STI_SCRIPTS_PATH/usage
