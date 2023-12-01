pipeline {
    agent any

    stages {
        stage('Git Clone') {
            steps {
                git credentialsId: 'GIT_HUB_CREDENTIALS', url: 'https://github.com/ninztec/nodejs-hellow.git', branch: 'master' 
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t ninzraju-non-prod-ecr .'
                sh 'docker image list'
            }
        }

        stage('Authenticate with AWS ECR') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'AWS_CREDENTIALS',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 446440614855.dkr.ecr.us-east-1.amazonaws.com/ninzraju-non-prod-ecr'
                }
            }
        }

        stage('Tag and Push Image to ECR') {
            steps {
                sh 'docker tag ninzraju-non-prod-ecr:latest 446440614855.dkr.ecr.us-east-1.amazonaws.com/ninzraju-non-prod-ecr:latest'
                sh 'docker push 446440614855.dkr.ecr.us-east-1.amazonaws.com/ninzraju-non-prod-ecr:latest'
            }
        }

        stage('Helm Chart Deployment') {
            steps {
                // Assuming your Helm chart is in the 'helm' directory
                dir('nodejs') {
                    sh 'helm upgrade -n default --install nodejs-eks ./nodejs/values.yaml'
                }
            }
        }
    }
}
