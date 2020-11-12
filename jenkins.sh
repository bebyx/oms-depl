#!/bin/bash

sudo dnf install -y @maven wget git

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
sudo dnf install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sleep 120

sudo wget http://localhost:8080/jnlpJars/jenkins-cli.jar
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("admin", "admin")' | sudo java -jar jenkins-cli.jar -s "http://localhost:8080" -auth admin:`sudo cat /var/lib/jenkins/secrets/initialAdminPassword` -noKeyAuth groovy =
sudo java -jar jenkins-cli.jar -s "http://localhost:8080" -auth admin:admin install-plugin maven-plugin trilead-api jdk-tool workflow-support script-security command-launcher workflow-cps bouncycastle-api handlebars  locale javadoc momentjs structs workflow-step-api scm-api workflow-api junit apache-httpcomponents-client-4-api pipeline-input-step display-url-api mailer credentials ssh-credentials jsch maven-plugin git-server token-macro pipeline-stage-step run-condition matrix-project conditional-buildstep parameterized-trigger git git-client workflow-scm-step cloudbees-folder timestamper pipeline-milestone-step workflow-job jquery-detached jackson2-api branch-api ace-editor pipeline-graph-analysis pipeline-rest-api pipeline-stage-view pipeline-build-step plain-credentials credentials-binding pipeline-model-api pipeline-model-extensions workflow-cps-global-lib workflow-multibranch authentication-tokens docker-commons durable-task workflow-durable-task-step workflow-basic-steps docker-workflow pipeline-stage-tags-metadata pipeline-model-declarative-agent pipeline-model-definition workflow-aggregator lockable-resources github -deploy

sudo bash -c "cat <<-EOF > /var/lib/jenkins/hudson.tasks.Maven.xml
<?xml version='1.1' encoding='UTF-8'?>
<hudson.tasks.Maven_-DescriptorImpl>
  <installations>
    <hudson.tasks.Maven_-MavenInstallation>
      <name>M3</name>
      <home>/usr/share/maven</home>
      <properties/>
    </hudson.tasks.Maven_-MavenInstallation>
  </installations>
</hudson.tasks.Maven_-DescriptorImpl>
EOF"
sudo chown jenkins:jenkins /var/lib/jenkins/hudson.tasks.Maven.xml

sudo mkdir /var/lib/jenkins/.ssh
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh/
sudo cp /tmp/terraform.pem /var/lib/jenkins/.ssh/terraform.pem
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/terraform.pem
sudo chmod 600 /var/lib/jenkins/.ssh/terraform.pem

sudo java -jar jenkins-cli.jar -s "http://localhost:8080" -auth admin:admin safe-restart
sudo systemctl restart jenkins
