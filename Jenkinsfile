pipeline {
    agent any

    environment {
        NODEJS_HOME = tool name: 'nodejs'
        JAVA_HOME = tool name: 'jdk17'
        PATH = "${NODEJS_HOME}/bin;${JAVA_HOME}/bin;${env.PATH}"
        PYTHON_ENV = 'python'
    }

    options {
        skipDefaultCheckout()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Zynaic/reqres-testing.git', branch: 'main'
            }
        }

        stage('API Tests (Newman)') {
            steps {
                script {
                    bat 'mkdir api-tests\\newman-reports'

                    def result = bat(script: '''
                        newman run api-tests\\reqres.postman_collection.json ^
                          -e api-tests\\reqres.postman_environment.json ^
                          -r cli,htmlextra,junit ^
                          --reporter-htmlextra-export api-tests\\newman-reports\\results.html ^
                          --reporter-junit-export api-tests\\newman-reports\\results.xml
                    ''', returnStatus: true)

                    if (result != 0) {
                        error("Newman API tests failed.")
                    }
                }
            }
            post {
                always {
                    junit 'api-tests/newman-reports/results.xml'
                    publishHTML(target: [
                        reportDir: 'api-tests/newman-reports',
                        reportFiles: 'results.html',
                        reportName: 'Newman API Tests',
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true
                    ])
                }
            }
        }

        stage('Performance Tests (JMeter)') {
            steps {
                script {
                    bat 'mkdir performance-tests\\jmeter\\reports'
                    bat 'mkdir performance-tests\\jmeter\\reports\\html'

                    def result = bat(script: '''
                        jmeter -n -t performance-tests\\jmeter\\ReqResTesting.jmx ^
                          -l performance-tests\\jmeter\\reports\\results.jtl ^
                          -e -o performance-tests\\jmeter\\reports\\html
                    ''', returnStatus: true)

                    if (result != 0) {
                        error("JMeter test execution failed.")
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportDir: 'performance-tests/jmeter/reports/html',
                        reportFiles: 'index.html',
                        reportName: 'JMeter Performance Tests',
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true
                    ])
                }
            }
        }

        stage('UI Tests (Robot Framework)') {
            steps {
                script {
                    bat 'mkdir ui-tests\\reports'

                    def result = bat(script: '''
                        robot -d ui-tests\\reports ui-tests\\tests
                    ''', returnStatus: true)

                    if (result != 0) {
                        error("Robot Framework UI tests failed.")
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportDir: 'ui-tests/reports',
                        reportFiles: 'report.html,report.js,log.html,log.js',
                        reportName: 'Robot Framework UI Tests',
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true
                    ])
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
