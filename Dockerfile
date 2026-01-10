# --- Stage 1: Build the application ---
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app

# Copy the pom.xml and source code to the container
COPY pom.xml .
COPY src ./src

# Build the application and skip tests to save time and memory
RUN mvn clean package -DskipTests

# --- Stage 2: Create the runtime image ---
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy only the built JAR from the first stage
COPY --from=build /app/target/*.jar app.jar

# Expose port 8080 (standard for Spring Boot)
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]