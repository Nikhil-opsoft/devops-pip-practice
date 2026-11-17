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

    environment {
        MAVEN_OPTS = '-Xmx384m'
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
        stage('SonarQube analysis') {
            steps {
                dir('app') {
                    withSonarQubeEnv('sonarqube') {
                        sh 'mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=day5-app -Dsonar.projectName=day5-app'
                    }
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'app/target/*.jar', fingerprint: true
            }
        }
    }

    post {
        success { echo 'Pipeline passed: quality gate OK, artifact archived' }
        failure { echo 'Pipeline failed: check the red stage above' }
    }
}
