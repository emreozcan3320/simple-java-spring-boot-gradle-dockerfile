# ! Use official images
# 1) Starts from the Gradle image
FROM gradle:jdk8-alpine as builder
# ! Builder should contain
	# a) Linux shell and some tools – I prefer Alpine Linux
	# b) JDK (version) – for the javac compiler
	# c) Gradle (version) – Java build tool
	# d) Project dependencies

ENV APP_HOME=/home/gradle/src

# 2) Copies the Java source code inside the container
COPY --chown=gradle:gradle . $APP_HOME
WORKDIR $APP_HOME
# ! Chaine all commands into one RUN to bust the cache easily
# 3) Compiles the code and runs unit tests (with Gradle build)
# 4) Discards the Gradle image with all the compiled classes/unit test results etc.
RUN gradle build --no-daemon

# 5) Starts again from the JRE (We only need a JRE because the application is already built) image and copies only the JAR file created before
FROM openjdk:8-jre-slim
# ! Specific COPY to not break cache busts
# 6) copy application WAR (with libraries inside)
COPY --from=builder /home/gradle/src/build/libs/cloudwise-cool-wizard-*.jar /cloudwise-cool-wizard-api.jar
# ! Use the container memory hints for Java 8: -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap. With Java 11 this is automatic by default.
CMD ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap","-Djava.security.egd=file:/dev/./urandom","-Dserver.port=${PORT}","-jar","/cloudwise-cool-wizard-api.jar"]

# FOR READING
# https://spring.io/guides/topicals/spring-boot-docker/
# https://codefresh.io/docker-tutorial/java_docker_pipeline/
# http://paulbakker.io/java/docker-gradle-multistage/
# https://shekhargulati.com/2019/01/23/the-ultimate-dockerfile-for-spring-boot-maven-and-gradle-applications/

# gcloud builds submit --tag gcr.io/codeshake-sandbox/cloudwise-cool-wizard-api
# gcloud builds submit --tag gcr.io/codeshake-sandbox/cloudwise-cool-wizard-api

