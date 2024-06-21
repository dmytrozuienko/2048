pipeline {
    agent any

    environment {
        AWS_ECR_IMAGE_URL = ''
    }

    stages {
        stage('Build') {
            steps {
                cleanWs()
                sh 'docker build -t app2048_httpd .'
                sh 'docker -v'
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