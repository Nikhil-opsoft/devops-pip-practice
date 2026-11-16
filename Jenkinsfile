pipeline {
    agent any

    tools {
        maven 'maven-3.9'
    }

    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --oneline'
            }
        }
        stage('Build') {
            steps {
                dir('app') {
                    sh 'mvn -B clean package -DskipTests'
                }
            }
        }
        stage('Test') {
            steps {
                dir('app') {
                    sh 'mvn -B test'
                }
            }
            post {
                always {
                    junit 'app/target/surefire-reports/*.xml'
                }
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'app/target/*.war', fingerprint: true
            }
        }
    }

    post {
        success { echo 'Pipeline passed: artifact archived' }
        failure { echo 'Pipeline failed: check the red stage above' }
    }
}
