# Simple runtime image — uses pre-built WAR from local mvn package
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY webapp/target/*.war app.war
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.war", "--spring.profiles.active=docker"]
