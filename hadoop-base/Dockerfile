#
# This image is modified version of sequenceiq/hadoop-docker
#   * sequenceiq/hadoop-docker <https://github.com/sequenceiq/hadoop-docker>
#
# The modifications are
#   * Use local hadoop package
#   * Change template files to indicate docker master node
#   * Modify bootstrap script
#
# Author: Kai Sasaki
# Date:   2015 Sep,13
#
# Creates multi node hadoop cluster on Docker

FROM sequenceiq/pam:ubuntu-14.04
MAINTAINER lewuathe

USER root

# install dev tools
RUN apt-get update
RUN apt-get install -y curl tar sudo openssh-server openssh-client rsync

# passwordless ssh
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# java
RUN mkdir -p /usr/java/default && \
     curl -Ls 'http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz' -H 'Cookie: oraclelicense=accept-securebackup-cookie' | \
     tar --strip-components=1 -xz -C /usr/java/default/

# ADD jdk-8u112-linux-x64.tar.gz /usr/java
# RUN sudo ln -s /usr/java/jdk1.8.0_112/ /usr/java/default

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin:/usr/local/hadoop/bin

# download native support
RUN mkdir -p /tmp/native
RUN curl -Ls http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-2.7.0.tar | tar -x -C /tmp/native

ENV HADOOP_VERSION=2.7.3
ADD hadoop-${HADOOP_VERSION}.tar.gz /usr/local/
WORKDIR /usr/local
RUN ln -s /usr/local/hadoop-${HADOOP_VERSION} /usr/local/hadoop

ADD spark-2.0.1-bin-without-hadoop.tgz /usr/local
WORKDIR /usr/local
RUN ln -s /usr/local/spark-2.0.1-bin-without-hadoop /usr/local/spark

ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV HADOOP_LOG_DIR /var/log/hadoop

RUN mkdir /var/log/hadoop
RUN mkdir /var/log/spark
RUN mkdir /tmp/spark-events

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export YARN_CONF_DIR/ s:.*:export YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
#RUN . $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

RUN cp -p /usr/local/spark/conf/spark-env.sh.template /usr/local/spark/spark-env.sh
RUN echo 'export SPARK_DIST_CLASSPATH=$(/usr/local/hadoop/bin/hadoop classpath)/' >> /usr/local/spark/conf/spark-env.sh

# With explicit path to 'hadoop' binary
#RUN sed -i '/^export SPSPARK_DIST_CLASSPATH=/usr/local/hadoop/bin/hadoop classpath)

# Passing a Hadoop configuration directory
#export SPARK_DIST_CLASSPATH=$(hadoop --config /path/to/configs classpath)


RUN mkdir $HADOOP_PREFIX/input
RUN cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

ADD core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
ADD log4j.properties $HADOOP_PREFIX/etc/hadoop/log4j.properties

RUN $HADOOP_PREFIX/bin/hdfs namenode -format

# fixing the libhadoop.so like a boss
RUN rm -rf /usr/local/hadoop/lib/native
RUN mv /tmp/native /usr/local/hadoop/lib

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN echo "export PATH=$PATH:/usr/local/spark/bin" > /root/.bashrc

RUN echo "slave1\nslave2\nslave3\nslave4\nslave5" > /usr/local/spark/conf/slaves

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

# Hdfs ports
EXPOSE 9000 50010 50020 50070 50075 50090
# See https://issues.apache.org/jira/browse/HDFS-9427
EXPOSE 9871 9870 9820 9869 9868 9867 9866 9865 9864
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088 8188
#Other ports
EXPOSE 49707 2122 4040 37722 40346
