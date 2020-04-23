FROM quay.io/quarkus/centos-quarkus-maven:19.3.1-java11
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
USER root
RUN chown -R quarkus /usr/src/app
USER quarkus
RUN mvn -f /usr/src/app/pom.xml -Pnative clean package
RUN mv /usr/src/app/target/*-runner /usr/src/app/target/application