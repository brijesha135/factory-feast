# Stage 1: Build Stage
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app

# Copy all files from the current folder into the container
COPY . .

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime Stage
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]