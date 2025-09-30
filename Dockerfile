# Stage 1: Build the application
FROM maven:3.9.8-eclipse-temurin-21 AS build

WORKDIR /app

# Copy the Maven project files
COPY pom.xml .
COPY .mvn .mvn

# Download dependencies
RUN mvn dependency:go-offline

# Copy the rest of the source code
COPY src src

# Build the application
RUN mvn clean install -DskipTests

# Stage 2: Create the final image
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Create a non-root user
RUN groupadd --gid 1001 appuser && \
    useradd --uid 1001 --gid 1001 -m -s /bin/bash appuser

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Set the owner of the app directory
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
