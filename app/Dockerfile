# syntax=docker/dockerfile:1

# ---------- Stage 1: build the jar with Maven ----------
FROM maven:3.9.11-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
COPY .mvn .mvn
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B package

# ---------- Stage 2: small runtime image ----------
FROM eclipse-temurin:17-jre
WORKDIR /app
RUN useradd --system --uid 10001 --no-create-home appuser
COPY --from=build /src/target/day5-app-1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
USER appuser
ENTRYPOINT ["java", "-cp", "/app/app.jar", "com.opsoft.pip.App"]
