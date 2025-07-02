# ─── Stage 1: Build the JAR ───
FROM maven:3.8.5-openjdk-17 AS builder

WORKDIR /app

# Copy POM and fetch dependencies to utilize Docker cache
COPY pom.xml ./
RUN mvn -B dependency:go-offline

# Copy source code and build
COPY src ./src
RUN mvn -B clean package -DskipTests

# ─── Stage 2: Runtime Image ───
FROM openjdk:17-slim

# Create non-root user (optional but recommended)
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Copy only the built JAR
COPY --from=builder /app/target/MaxSoft-WebBot-Demo-1.0-SNAPSHOT.jar app.jar

RUN chown appuser:appgroup /app/app.jar
USER appuser

# Adjust this if your app listens on a port
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
