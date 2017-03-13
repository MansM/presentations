---
title: Docker & Jenkins
theme: white
revealOptions:
    transition: slide
    backgroundTransition: slide

---

TODO: add process of how docker slaves are being setup
TODO: remix types in scale out


---

# Docker & Jenkins


* Mans Matulewicz
* Dev Engineer

----

<table>
<tr>
<td>
<img src="../images/2016-Docker_Jenkins/me.jpg" width="150">
</td><td style="vertical-align:middle">
<ul>
<li>@Mans_M</li>
<li>github.com/MansM</li>
<li>mans@mansm.io</li>
</ul>

</td></tr></table>


----

* Ordina (employer)
* ING (assignment)
* Anything in this presentation is solely my opinion, it doesn't have to reflect the opinions of ING or Ordina

---

## Topics



* What is Docker/Jenkins
* Running Jenkins in a container
* Using Dockerized build slaves
* Pipelines

---

## What is Docker?

* Docker is a tool for building and running containers
* Containers are like a vm without an OS
* Multiple containers can run on a server
* Lightweight

---

## What is Jenkins?

* Continuous integration
* Orchestrator
* Plugin based
* Pipelines as code (key feature of Jenkins 2)

---

# Jenkins in a container

----

## Why? 

<table>
<tr>
<td style="vertical-align:middle">
<img src="../images/2016-Docker_Jenkins/JenkinsContainer.png" width="350">
</td><td style="vertical-align:middle; align:right">
<ul>
<li>Easy to use</li>
<li>Repeatable</li>
</ul>
</td></tr></table>

----

## How?

```
FROM jenkins:2.7.3

RUN /usr/local/bin/install-plugins.sh \
    workflow-aggregator git token-macro docker-plugin:0.16.0

#config
COPY jobs/buildslavedemo-jenkinsfile.xml \
     /usr/share/jenkins/ref/jobs/buildslavedemo/config.xml
COPY config.xml /usr/share/jenkins/ref/config.xml
COPY credentials.xml /usr/share/jenkins/ref/credentials.xml

USER root
#Adding Jenkins to correct user groups
RUN usermod -a -G users,staff jenkins
RUN usermod -a -G 100 jenkins
USER jenkins
```

----

## Plugins

* For everything there is a plugin
* Today we are talking about:
  - Pipeline/workflow
  - Docker-cloud
* Plugin dependencies can be tricky

----

## Everything happyflow?

![](unicorn.jpg)

----

## Caveats

* Not a really good method for credentials
* New job -> new build
* Build numbers are reset on new container (at ING we circumvent this by versioning packages with git-tag numbers)

----

## Demo

* Jenkins in a Container

---

# Docker Build-slaves

----


<table>
<tr>
<td style="vertical-align:middle">
<img src="../images/2016-Docker_Jenkins/JenkinsBuildslaves.png" width="350">
</td><td style="vertical-align:middle; align:right">
<ul>
<li>What are buildslaves?</li>
<li>Why buildslaves?</li>
<li>What kind of buildslaves?</li>
</ul>
</td></tr></table>

----

## What?

* Building on a different machine
* Spinning up a Docker container as buildslave

----

## Why?

* Building for multiple platforms
* Don't overload your buildmachine
* Use a cluster of build slaves for use by multiple projects

----

## For every purpose a container 

* Different OS (EL6 or EL7) 
* Different programming language (C/Java/Go/Puppet)
* Vendor code base + additional code
* Testing tools

----

## How?

```
FROM centos:7

RUN yum update -y && yum install -y \
    openssh-server sudo git java-1.8.0-openjdk-headless && \
    yum clean all

#configuring sshd
RUN sed 's/UsePAM yes/UsePAM no/' -i /etc/ssh/sshd_config
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN mkdir -p /var/run/sshd  && chmod -rx /var/run/sshd

#jenkins user
RUN useradd -u 1000 -m -s /bin/bash jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    mkdir -p /home/jenkins && chown -R jenkins:jenkins /home/jenkins 

EXPOSE 22
```

----

## (Docker) slave types

* Docker-cloud
* Kubernetes-cloud
* Nomad-cloud
* Mesos-cloud
* Swarm-cloud

----

## Demo 

* Docker buildslaves

---

# Pipeline as Code

----

## What?

* Old: clicking everything together
* Jenkinsfile
* Can be in your Git repo with your code

----

## Why?

* Project evolves, buildsteps as well
* Versioning Everything Rocks!™
* Crash, no more AAAAARRGGGHHHHHHHH

----

## How?
```

node() {
  
  stage ('git clone'){
    checkout scm
    sh 'BNUMBER=$(git tag | awk -F- \'{print $NF} END { if (NR==0) print "0"}\' | sort -V | tail -1) ;  echo $BNUMBER > .bnumber'
    def BNUMBER = readFile('.bnumber').trim()
    env.BNUMBER = BNUMBER
  }

  stage ('centos6'){
    node('uildslave-centos6') {
      checkout scm
      withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'Other_User', usernameVariable: 'OTHER_USERNAME', passwordVariable: 'OTHER_PASSWORD']]) {
        sh "sed -i \"s#CHANGEME#${env.OTHER_PASSWORD}#g\" somefile.json"
        sh "./do_something_centos_sixish.sh"
      }
    }
  }

  stage ('centos7'){
    node('uildslave-centos7') {
      checkout scm
      withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'Other_User', usernameVariable: 'OTHER_USERNAME', passwordVariable: 'OTHER_PASSWORD']]) {
        sh "sed -i \"s#CHANGEME#${env.OTHER_PASSWORD}#g\" somefile.json"
        sh "./do_something_centos_sevenish.sh"
      }
    }
  }

}
```

----


## Modulesync

* Original used for maintaining lots of puppet modules
* I use it to sync Jenkinsfile (and other files) to multiple repo’s
* Same Jenkinsfile for lots of repo’s (by example standardized RPM builds)

---

# Questions?









