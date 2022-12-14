FROM jenkins/jenkins:2.375.1-lts-jdk11

# Install k8s plugin
RUN jenkins-plugin-cli --plugins kubernetes

USER jenkins
