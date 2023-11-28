Set up Jenkins server on ec2
------------------------------

Step 1. Update the System

Update the packages to their latest versions available after a fresh install of Ubuntu 22.04

sudo apt-get update -y 

Step 2. Install Apache Web Server

To install the Apache Web server execute the following command:

sudo apt install apache2 -y

Once installed, start and enable the service.

sudo systemctl enable apache2 && sudo systemctl start apache2

Check if the service is up and running:

sudo systemctl status apache2

You should receive the following output:

root@host:~# sudo systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2023-04-06 15:12:46 CDT; 10s ago
       Docs: https://httpd.apache.org/docs/2.4/
   Main PID: 794 (apache2)
      Tasks: 7 (limit: 4571)
     Memory: 23.8M
        CPU: 16.059s
     CGroup: /system.slice/apache2.service

Step 3. Install Java

To install Java OpenJDK 11, execute the following command:

sudo apt install openjdk-11-jdk -y

To check the installed Java version, execute the following command:

java --version

You should receive the following output:

root@host:~# java --version
openjdk 11.0.18 2023-01-17
OpenJDK Runtime Environment (build 11.0.18+10-post-Ubuntu-0ubuntu122.04)
OpenJDK 64-Bit Server VM (build 11.0.18+10-post-Ubuntu-0ubuntu122.04, mixed mode, sharing)

Step 4. Install Jenkins

First, we will add the Jenkins repository and Key since they are not added by default in Ubuntu 22.04:

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

Update the system and install Jenkins:

sudo apt update -y

sudo apt install jenkins -y

Once installed, start and enable the Jenkins service:

sudo systemctl start jenkins && sudo systemctl enable jenkins

To check the status of the service:

sudo systemctl status jenkins

You should get the following output:

root@host:~# sudo systemctl status jenkins
● jenkins.service - Jenkins Continuous Integration Server
     Loaded: loaded (/lib/systemd/system/jenkins.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2023-04-06 15:17:46 CDT; 4min 1s ago
   Main PID: 22232 (java)
      Tasks: 45 (limit: 4571)
     Memory: 1.2G
        CPU: 1min 32.203s
     CGroup: /system.slice/jenkins.service
             └─22232 /usr/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --webroot=/var/cache/jenkins/war --httpPort=8080

Step 5. Setting up Apache as a Reverse Proxy

To access Jenkins installation via domain, we need to configure the Apache as a Reverse Proxy:

Since Apache is already installed in the previous steps, you need to create the jenkins.conf configuration file:

cd /etc/apache2/sites-available/
sudo nano jenkins.conf

Paste the following lines of code, save and close the file.


<Virtualhost *:80>
    ServerName        yourdomain.com
    ProxyRequests     Off
    ProxyPreserveHost On
    AllowEncodedSlashes NoDecode

    <Proxy http://localhost:8080/*>
      Order deny,allow
      Allow from all
    </Proxy>

    ProxyPass         /  http://localhost:8080/ nocanon
    ProxyPassReverse  /  http://localhost:8080/
    ProxyPassReverse  /  http://yourdomain.com/
</Virtualhost>


Note: Either you can give domain name or jenkins server public ip replacing yourdomain.com 
Once you save and close the file, you need to execute the following commands:

sudo a2ensite jenkins
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod headers
sudo systemctl restart apache2

After enabling the Apache configuration and restarting the Apache service, you will be able to access your Jenkins via your domain.

Configure jenkins with required tools 
--------------------------------------
Let’s add jenkins user as an administrator and also ass NOPASSWD so that during the pipeline run it will not ask for root password.

Open the file /etc/sudoers in vi mode

$ sudo vi /etc/sudoers

Add the following line at the end of the file

$ jenkins ALL=(ALL) NOPASSWD: ALL

After adding the line save and quit the file with :wq!

Now we can use Jenkins as root user and for that run the following command

$ sudo su - jenkins

This step is very important 

-------------------------------------------------------------------------------------
Step 1— Install Docker

Remember, all these commands are run as a Jenkins user and not as Ubuntu user.

So first login as jenkins user & start install required tools
First, update your existing list of packages:

    sudo apt update

Next, install a few prerequisite packages which let apt use packages over HTTPS:

    sudo apt install apt-transport-https ca-certificates curl software-properties-common

Then add the GPG key for the official Docker repository to your system:

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

Add the Docker repository to APT sources:

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

Update your existing list of packages again for the addition to be recognized:

    sudo apt update

Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:

    apt-cache policy docker-ce

You’ll see output like this, although the version number for Docker may be different:
Output of apt-cache policy docker-ce

docker-ce:
  Installed: (none)
  Candidate: 5:20.10.14~3-0~ubuntu-jammy
  Version table:
     5:20.10.14~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.13~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages

Notice that docker-ce is not installed, but the candidate for installation is from the Docker repository for Ubuntu 22.04 (jammy).

Finally, install Docker:

    sudo apt install docker-ce

Docker should now be installed, the daemon started, and the process enabled to start on boot. Check that it’s running:

    sudo systemctl status docker

The output should be similar to the following, showing that the service is active and running:

Output
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2022-04-01 21:30:25 UTC; 22s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 7854 (dockerd)
      Tasks: 7
     Memory: 38.3M
        CPU: 340ms
     CGroup: /system.slice/docker.service
             └─7854 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Installing Docker now gives you not just the Docker service (daemon) but also the docker command line utility, or the Docker client
If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group:

    sudo usermod -aG docker ${USER}
Also add jenkins to docker group & check jenkins user can access docker:
sudo usermod -aG docker jenkins
$ sudo docker ps
$ sudo reboot --do this step if automatically it is not applied.Ec2 machine will be rebooted & available after a few minutes

 Step 2 -Install and set up AWSCLI
 ----------------------------------------
 Remember, we will be using the Jenkins user to install AWSCLI. So, after rebooting if you are in Ubuntu user, use the below command to come into Jenkins

$ sudo su - jenkins
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

Now after installing AWS CLI, let’s configure the AWS CLI so that it can authenticate and communicate with the AWS environment.

$ aws configure
------------------------------------------------------

Step 3— Install and setup kubectl
--------------------------------------
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ chmod +x ./kubectl
$ sudo mv ./kubectl /usr/local/bin
$ kubectl version
--------------------------------------------------------------------------------------
Step 4— Add Docker and Github credentials on Jenkins
--------------------------------------------------------
Setup Docker Hub Secret Text in Jenkins
You can set the docker credentials by going into -

Goto -> Jenkins -> Manage Jenkins -> Manage Credentials -> Stored scoped to jenkins -> global -> Add Credentials

Steps done to build & push docker images to ecr repo & deploy the same app to eks cluster
-----------------------------------------------------------------------------------------------
In jenkins :
1.Install AWS Credentials Plugin & configure aws credentails 
