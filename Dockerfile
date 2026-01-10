# --- Stage 1: Build Stage ---
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app

# Copy files directly from the root of your repo
COPY pom.xml .
COPY src ./src

# Build the JAR
RUN mvn clean package -DskipTests

# --- Stage 2: Run Stage ---
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]