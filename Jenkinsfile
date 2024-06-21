pipeline {
    agent any

    environment {
        AWS_ECR_IMAGE_URL = '905418075806.dkr.ecr.us-east-1.amazonaws.com'
    }

    stages {
        stage('Build') {
            steps {
                //cleanWs()
                sh 'docker build -t app2048_httpd .'
                withCredentials([aws(credentialsId: 'aws-creds')]) {
                    sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 905418075806.dkr.ecr.us-east-1.amazonaws.com'
                }
            }
        }
        stage('Test') {
            steps {
                echo 'Hello World'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Hello World'
            }
        }
    }
}