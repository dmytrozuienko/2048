pipeline {
    agent any

    environment {
        AWS_ECR_IMAGE_URL = '905418075806.dkr.ecr.us-east-1.amazonaws.com'
//        DOCKER_IMAGE = 'app2048_httpd'
    }

    stages {
        stage('Test') {
            steps {
                echo 'SonarQube'
            }
        }
        stage('Build') {
            steps {
                //cleanWs()
                sh 'docker build -t app2048_httpd .'
                //withCredentials([aws(credentialsId: 'aws-creds')]) {
                //    sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 905418075806.dkr.ecr.us-east-1.amazonaws.com'
                //}
            }
        }
        stage('Push') {
            steps {
                script {
                    docker.withRegistry(
                        'https://905418075806.dkr.ecr.us-east-1.amazonaws.com',
                        'ecr:us-east-1:aws-creds') {
                            def myImage = docker.build('app2048_httpd')
                            myImage.push('v0.5')
                        }
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'AWS ECS Service Update'
                withAWS(credentials: 'aws-creds', region:'us-east-1') {
                    sh "aws ecs update-service --cluster app2048_httpd --service app2048_httpd --force-new-deployment"
                }
            }
        }
    }
}