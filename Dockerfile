# Stage 1: Build
FROM maven:3.8.5-openjdk-17 AS builder
WORKDIR /app

# Copy project files
COPY pom.xml ./
COPY src ./src
COPY ext/MaxSoft-WebBot-1.0-SNAPSHOT.jar ./ext/

# Install the external jar into local Maven repo
RUN mvn install:install-file \
  -Dfile=ext/MaxSoft-WebBot-1.0-SNAPSHOT.jar \
  -DgroupId=com.maxsoft.webbot \
  -DartifactId=MaxSoft-WebBot \
  -Dversion=1.0-SNAPSHOT \
  -Dpackaging=jar

# Resolve dependencies then build
RUN mvn -B dependency:go-offline
RUN mvn -B clean package -DskipTests

# Stage 2: Runtime
FROM openjdk:17-slim
WORKDIR /app
COPY --from=builder /app/target/MaxSoft-WebBot-Demo-1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
