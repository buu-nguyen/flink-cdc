#/*
# * Licensed to the Apache Software Foundation (ASF) under one or more
# * contributor license agreements.  See the NOTICE file distributed with
# * this work for additional information regarding copyright ownership.
# * The ASF licenses this file to You under the Apache License, Version 2.0
# * (the "License"); you may not use this file except in compliance with
# * the License.  You may obtain a copy of the License at
# *
# *      http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# */

FROM flink:1.17

# Update packages of base image
RUN set -ex; \
    apt-get update; \
    apt-get -y dist-upgrade; \
    rm -rf /var/lib/apt/lists/*

ARG FLINK_CDC_VERSION=3.2.0

ENV FLINK_CDC_HOME /opt/flink-cdc
ARG FLINK_USRLIB_DIR=/opt/flink/usrlib
RUN mkdir -p ${FLINK_CDC_HOME} ${FLINK_USRLIB_DIR}

COPY flink-cdc-dist/target/flink-cdc-${FLINK_CDC_VERSION}-bin.tar.gz /tmp/
RUN tar -xzvf /tmp/flink-cdc-${FLINK_CDC_VERSION}-bin.tar.gz -C /tmp/ && \
    mv /tmp/flink-cdc-${FLINK_CDC_VERSION}/* ${FLINK_CDC_HOME} && \
    mv ${FLINK_CDC_HOME}/lib/flink-cdc-dist-${FLINK_CDC_VERSION}.jar ${FLINK_CDC_HOME}/lib/flink-cdc-dist.jar && \
    rm -rf /tmp/flink-cdc-${FLINK_CDC_VERSION} /tmp/flink-cdc-${FLINK_CDC_VERSION}-bin.tar.gz

# copy jars to cdc libs
## Pipeline connectors
COPY flink-cdc-connect/flink-cdc-pipeline-connectors/flink-cdc-pipeline-connector-doris/target/flink-cdc-pipeline-connector-doris-${FLINK_CDC_VERSION}.jar ${FLINK_USRLIB_DIR}/flink-cdc-pipeline-connector-doris-${FLINK_CDC_VERSION}.jar
COPY flink-cdc-connect/flink-cdc-pipeline-connectors/flink-cdc-pipeline-connector-mysql/target/flink-cdc-pipeline-connector-mysql-${FLINK_CDC_VERSION}.jar ${FLINK_USRLIB_DIR}/flink-cdc-pipeline-connector-mysql-${FLINK_CDC_VERSION}.jar
## Source connectors
COPY flink-cdc-connect/flink-cdc-source-connectors/flink-sql-connector-postgres-cdc/target/flink-sql-connector-postgres-cdc-${FLINK_CDC_VERSION}.jar ${FLINK_USRLIB_DIR}/flink-sql-connector-postgres-cdc-${FLINK_CDC_VERSION}.jar

# Download dependencies jars
## MySQL connector
RUN wget -O ${FLINK_USRLIB_DIR}/mysql-connector-java-8.0.28.jar \
    https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar
