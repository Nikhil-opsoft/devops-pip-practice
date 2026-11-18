pipeline {
    agent any
    tools { maven 'maven-3.9' }
    options { skipDefaultCheckout(); buildDiscarder(logRotator(numToKeepStr: '10')) }
    triggers { githubPush() }
    parameters {
        string(name: 'IMAGE', defaultValue: 'nikhilopsoft/day5-app:1.0', description: 'Image scanned by the Trivy gate')
    }
    environment {
        MAVEN_OPTS = '-Xmx384m'
        TRIVY = '/var/jenkins_home/bin/trivy'
    }
    stages {
        stage('Checkout') { steps { checkout scm; sh 'git log -1 --oneline' } }
        stage('Build') { steps { dir('app') { sh 'mvn -B clean package -DskipTests' } } }
        stage('Test') {
            steps { dir('app') { sh 'mvn -B test' } }
            post { always { junit 'app/target/surefire-reports/*.xml' } }
        }
        stage('SonarQube analysis') {
            steps { dir('app') { withSonarQubeEnv('sonarqube') {
                sh 'mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=day5-app -Dsonar.projectName=day5-app'
            } } }
        }
        stage('Quality Gate') {
            steps { timeout(time: 5, unit: 'MINUTES') { waitForQualityGate abortPipeline: true } }
        }
        stage('Trivy: Dockerfile') {
            steps {
                sh '$TRIVY config --exit-code 1 --severity HIGH,CRITICAL --ignorefile .trivyignore.yaml app/'
            }
        }
        stage('Trivy: image') {
            steps {
                sh '''
                    $TRIVY image --image-src remote --scanners vuln --no-progress \
                        --ignorefile .trivyignore.yaml --format table -o trivy-report.txt "$IMAGE"
                    $TRIVY image --image-src remote --scanners vuln --no-progress \
                        --ignorefile .trivyignore.yaml --severity HIGH,CRITICAL --exit-code 1 "$IMAGE"
                '''
            }
            post { always { archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true } }
        }
        stage('Archive') { steps { archiveArtifacts artifacts: 'app/target/*.jar', fingerprint: true } }
    }
    post {
        success { echo 'Pipeline passed: quality gate OK, no HIGH/CRITICAL vulnerabilities, artifact archived' }
        failure { echo 'Pipeline failed: check the red stage above' }
    }
}
