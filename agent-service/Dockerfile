FROM eclipse-temurin:17-jre-alpine
VOLUME /tmp
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
EXPOSE 8086
ENTRYPOINT ["java", "-Xmx768m", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]
