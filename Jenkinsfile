pipeline {
    agent any
    
    environment {
        NODEJS_VERSION = '22'
        PYTHON_VERSION = '3.8'
        JAVA_VERSION = '17'
    }
    
    tools {
        nodejs "${NODEJS_VERSION}"
        jdk "${JAVA_VERSION}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.BUILD_NUMBER = "${BUILD_NUMBER}"
                    env.GIT_COMMIT_SHORT = bat(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        
        stage('Create Report Directories') {
            steps {
                bat '''
                    mkdir -p api-tests/newman-reports
                    mkdir -p performance-tests/reports
                    mkdir -p ui-tests/reports
                '''
            }
        }
        
        stage('Run Tests') {
            parallel {
                stage('API Tests (Postman/Newman)') {
                    steps {
                        script {
                            try {
                                bat '''
                                    echo "Running Postman API tests..."
                                    newman run api-tests/postman/collections/Reqres_API_Test_Suite.json \
                                        -e api-tests/postman/environments/EVN.json \
                                        --reporters cli,htmlextra,junit \
                                        --reporter-htmlextra-export api-tests/newman-reports/newman-report-${BUILD_NUMBER}.html \
                                        --reporter-junit-export api-tests/newman-reports/newman-report-${BUILD_NUMBER}.xml \
                                        --reporter-htmlextra-title "ReqRes API Test Report - Build ${BUILD_NUMBER}" \
                                        --reporter-htmlextra-logs
                                '''
                            } catch (Exception e) {
                                currentBuild.result = 'UNSTABLE'
                                echo "API tests failed: ${e.getMessage()}"
                            }
                        }
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'api-tests/newman-reports',
                                reportFiles: "newman-report-${BUILD_NUMBER}.html",
                                reportName: 'Newman API Test Report'
                            ])
                        }
                    }
                }
                
                stage('Performance Tests (JMeter)') {
                    steps {
                        script {
                            try {
                                bat '''
                                    echo "Running JMeter performance tests..."
                                    ./apache-jmeter-5.6.3/bin/jmeter -n -t performance-tests/jmeter/ReqResTesting.jmx \
                                        -l performance-tests/reports/results-${BUILD_NUMBER}.jtl \
                                        -e -o performance-tests/reports/html-report-${BUILD_NUMBER} \
                                        -Jjmeter.reportgenerator.overall_granularity=60000
                                '''
                            } catch (Exception e) {
                                currentBuild.result = 'UNSTABLE'
                                echo "Performance tests failed: ${e.getMessage()}"
                            }
                        }
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: "performance-tests/reports/html-report-${BUILD_NUMBER}",
                                reportFiles: 'index.html',
                                reportName: 'JMeter Performance Test Report'
                            ])
                        }
                    }
                }
                
                stage('UI Tests (Robot Framework)') {
                    steps {
                        script {
                            try {
                                bat '''
                                    echo "Running Robot Framework UI tests..."
                                    . venv/bin/activate
                                    robot --outputdir ui-tests/reports \
                                          --output output-${BUILD_NUMBER}.xml \
                                          --log log-${BUILD_NUMBER}.html \
                                          --report report-${BUILD_NUMBER}.html \
                                          --variable BROWSER:headlesschrome \
                                          ui-tests/robot/reqres-dashboard-tests.robot
                                '''
                            } catch (Exception e) {
                                currentBuild.result = 'UNSTABLE'
                                echo "UI tests failed: ${e.getMessage()}"
                            }
                        }
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'ui-tests/reports',
                                reportFiles: "report-${BUILD_NUMBER}.html",
                                reportName: 'Robot Framework UI Test Report'
                            ])
                        }
                    }
                }
            }
        }
        
        stage('Test Results Processing') {
            steps {
                script {
                    // Process JUnit XML reports
                    if (fileExists('api-tests/newman-reports/newman-report-${BUILD_NUMBER}.xml')) {
                        junit 'api-tests/newman-reports/newman-report-${BUILD_NUMBER}.xml'
                    }
                    
                    if (fileExists('ui-tests/reports/output-${BUILD_NUMBER}.xml')) {
                        step([
                            $class: 'RobotPublisher',
                            outputPath: 'ui-tests/reports',
                            outputFileName: "output-${BUILD_NUMBER}.xml",
                            reportFileName: "report-${BUILD_NUMBER}.html",
                            logFileName: "log-${BUILD_NUMBER}.html",
                            disableArchiveOutput: false,
                            passThreshold: 100,
                            unstableThreshold: 80,
                            otherFiles: "**/*.png,**/*.jpg"
                        ])
                    }
                }
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '''
                    api-tests/newman-reports/**/*,
                    performance-tests/reports/**/*,
                    ui-tests/reports/**/*
                ''', allowEmptyArchive: true
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'All tests passed successfully!'
            emailext (
                subject: "ReqRes API Tests - Build ${BUILD_NUMBER} - SUCCESS",
                body: '''
                    <h2>Test Execution Summary</h2>
                    <p>Build Number: ${BUILD_NUMBER}</p>
                    <p>Git Commit: ${GIT_COMMIT_SHORT}</p>
                    <p>Status: <span style="color: green;">SUCCESS</span></p>
                    <p>All test suites executed successfully.</p>
                    <p>Check the Jenkins build for detailed reports.</p>
                ''',
                mimeType: 'text/html',
                to: "${env.CHANGE_AUTHOR_EMAIL ?: 'dev-team@company.com'}"
            )
        }
        failure {
            echo 'Tests failed!'
            emailext (
                subject: "ReqRes API Tests - Build ${BUILD_NUMBER} - FAILURE",
                body: '''
                    <h2>Test Execution Summary</h2>
                    <p>Build Number: ${BUILD_NUMBER}</p>
                    <p>Git Commit: ${GIT_COMMIT_SHORT}</p>
                    <p>Status: <span style="color: red;">FAILURE</span></p>
                    <p>Some tests failed. Please check the Jenkins build logs and reports.</p>
                ''',
                mimeType: 'text/html',
                to: "${env.CHANGE_AUTHOR_EMAIL ?: 'dev-team@company.com'}"
            )
        }
        unstable {
            echo 'Some tests failed, but build is unstable.'
            emailext (
                subject: "ReqRes API Tests - Build ${BUILD_NUMBER} - UNSTABLE",
                body: '''
                    <h2>Test Execution Summary</h2>
                    <p>Build Number: ${BUILD_NUMBER}</p>
                    <p>Git Commit: ${GIT_COMMIT_SHORT}</p>
                    <p>Status: <span style="color: orange;">UNSTABLE</span></p>
                    <p>Some tests failed but the build continued. Please review the reports.</p>
                ''',
                mimeType: 'text/html',
                to: "${env.CHANGE_AUTHOR_EMAIL ?: 'dev-team@company.com'}"
            )
        }
    }
}