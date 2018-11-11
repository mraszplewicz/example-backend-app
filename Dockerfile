FROM openjdk:11-jdk-slim AS build
WORKDIR /app

COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
RUN ./gradlew --version
# Download dependencies layer
RUN ./gradlew build || return 0

COPY . .
RUN ./gradlew build

FROM openjdk:11-jre-slim
WORKDIR /app

COPY --from=build /app/build/libs/example-backend-app*.jar ./example-backend-app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "example-backend-app.jar"]