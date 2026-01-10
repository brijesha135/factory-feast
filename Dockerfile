# Use a lightweight Java runtime
FROM eclipse-temurin:17-jdk-alpine

# Add a volume for temporary files
VOLUME /tmp

# Copy the built jar file from the target folder to the container
# Note: Ensure you have run 'mvn clean package' locally first
COPY target/*.jar app.jar

# Run the jar file
ENTRYPOINT ["java","-jar","/app.jar"]

# Expose the port (Render uses 10000 by default but will map 8080)
EXPOSE 8080