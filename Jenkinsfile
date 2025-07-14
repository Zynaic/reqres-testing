pipeline {
    agent any

    environment {
        NODEJS_HOME = tool name: 'nodejs'
        JAVA_HOME = tool name: 'jdk17'
        PATH = "${NODEJS_HOME}/bin;${JAVA_HOME}/bin;${env.PATH}"
        WORKDIR = 'F:\\reqres-testing'
    }

    options {
        skipDefaultCheckout()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                dir("${env.WORKDIR}") {
                    git url: 'https://github.com/Zynaic/reqres-testing.git', branch: 'main'
                }
            }
        }

        stage('API Tests (Newman)') {
            steps {
                dir("${env.WORKDIR}") {
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
            }
            post {
                always {
                    junit 'F:/reqres-testing/api-tests/newman-reports/results.xml'
                    publishHTML(target: [
                        reportDir: 'F:/reqres-testing/api-tests/newman-reports',
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
                dir("${env.WORKDIR}") {
                    script {
                        bat 'mkdir jmeter\\reports'
                        bat 'dir jmeter'

                        def result = bat(script: '''
                            jmeter -n -t jmeter\\reqres_test_plan.jmx -l jmeter\\reports\\results.jtl -e -o jmeter\\reports\\html
                        ''', returnStatus: true)

                        if (result != 0) {
                            error("JMeter test execution failed.")
                        }
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportDir: 'F:/reqres-testing/jmeter/reports/html',
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
                dir("${env.WORKDIR}") {
                    script {
                        bat 'mkdir ui-tests\\reports'
                        bat 'dir ui-tests\\tests'

                        def result = bat(script: '''
                            robot -d ui-tests\\reports ui-tests\\tests
                        ''', returnStatus: true)

                        if (result != 0) {
                            error("Robot Framework UI tests failed.")
                        }
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportDir: 'F:/reqres-testing/ui-tests/reports',
                        reportFiles: 'report.html',
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
