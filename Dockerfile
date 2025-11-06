# ---------- 1️⃣ Build Stage ----------
FROM maven:3.8.4-openjdk-17 AS build

# Set working directory inside the container
WORKDIR /app

# Copy only the pom.xml first to leverage Docker layer caching
COPY pom.xml .

# Download all project dependencies (helps cache builds)
RUN mvn dependency:go-offline

# Copy the rest of the project files
COPY src ./src

# Build the application without running tests
RUN mvn clean package -DskipTests


# ---------- 1️⃣ Build Stage ----------
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests


# ---------- 2️⃣ Runtime Stage ----------
FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app
COPY --from=build /app/target/email-writer-sb-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

