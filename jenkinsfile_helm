pipeline {
    agent any
    
    stages {
        stage("Git Clone") {
            steps {
                git credentialsId: 'GIT_HUB_CREDENTIALS', url: 'https://github.com/ninztec/nodejs-hellow.git', branch: 'master'
            }
        }
        
        stage("Build") {
            steps {
                script {
                    sh 'docker build . -t rjshk013/node-hellow:latest'
                    sh 'docker image list'
                }
            }
        }

        stage("Docker Login") {
            steps {
                withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD', variable: 'PASSWORD')]) {
                    script {
                        sh 'docker login -u rjshk013 -p $PASSWORD'
                    }
                }
            }
        }

        stage("Push Image to Docker Hub") {
            steps {
                script {
                    sh 'docker push rjshk013/node-hellow:latest'
                }
            }
        }

        stage("Kubernetes Deployment") {
            steps {
                script {
                    sh 'sudo helm upgrade nodejs-app nodejs -f nodejs/dev-values.yaml'
                }
            }
        }
    }
}