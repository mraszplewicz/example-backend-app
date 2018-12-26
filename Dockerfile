FROM openjdk:8-jdk-alpine AS build
WORKDIR /app

COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
RUN ./gradlew --version
# Download dependencies layer
RUN ./gradlew build 2>/dev/null || return 0

COPY . .
RUN ./gradlew build

FROM openjdk:8-jre-alpine

RUN apk --no-cache add bash

WORKDIR /app

COPY scripts/docker-entrypoint.sh .
COPY --from=build /app/build/libs/example-backend-app*.jar ./application.jar

EXPOSE 8080

ENTRYPOINT ["./docker-entrypoint.sh"]
