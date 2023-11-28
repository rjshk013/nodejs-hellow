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

