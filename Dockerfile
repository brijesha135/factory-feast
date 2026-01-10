# Stage 1: Build Stage
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app

# Now that Root Directory is 'factory-backend',
# these files will be found correctly.
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# Stage 2: Runtime Stage
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]