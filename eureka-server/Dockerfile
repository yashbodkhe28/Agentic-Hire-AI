FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="AgentHire AI Team"
LABEL description="Eureka Service Discovery Server"

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY target/eureka-server-*.jar app.jar

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8761

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8761/actuator/health || exit 1

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
