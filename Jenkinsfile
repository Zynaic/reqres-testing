pipeline {
    agent any

    environment {
        NODEJS_HOME = tool name: 'nodejs'
        PATH = "${NODEJS_HOME}\\bin;${env.PATH}"
        PYTHON_ENV = 'python'
        LOCAL_REPO_PATH = 'F:\\reqres-testing'
    }

    options {
        skipDefaultCheckout()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                dir("${env.LOCAL_REPO_PATH}") {
                    git url: 'https://github.com/Zynaic/reqres-testing.git', branch: 'main'
                }
            }
        }

        stage('API Tests (Newman)') {
            steps {
                script {
                    bat 'mkdir "F:\\reqres-testing\\api-tests\\newman-reports"'

                    def result = bat(
                        script: '''
                            cd F:\\reqres-testing
                            newman run collection\\reqres.postman_collection.json ^
                                -e collection\\reqres.postman_environment.json ^
                                -r cli,htmlextra,junit ^
                                --reporter-htmlextra-export api-tests\\newman-reports\\results.html ^
                                --reporter-junit-export api-tests\\newman-reports\\results.xml
                        ''',
                        returnStatus: true
                    )

                    if (result != 0) {
                        error("Newman API tests failed.")
                    }
                }
            }
            post {
                always {
                    script {
                        def junitReport = "${env.LOCAL_REPO_PATH}\\api-tests\\newman-reports\\results.xml"
                        def htmlReport = "${env.LOCAL_REPO_PATH}\\api-tests\\newman-reports\\results.html"

                        if (fileExists(junitReport)) {
                            junit junitReport
                        } else {
                            echo "Newman JUnit report not found."
                        }

                        if (fileExists(htmlReport)) {
                            publishHTML(target: [
                                reportDir: "${env.LOCAL_REPO_PATH}\\api-tests\\newman-reports",
                                reportFiles: 'results.html',
                                reportName: 'Newman API Tests',
                                allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true
                            ])
                        } else {
                            echo "Newman HTML report not found."
                        }
                    }
                }
            }
        }

        stage('Performance Tests (JMeter)') {
            steps {
                script {
                    bat 'mkdir "F:\\reqres-testing\\jmeter\\reports\\html"'

                    def result = bat(
                        script: '''
                            cd F:\\reqres-testing
                            jmeter -n -t jmeter\\reqres_test_plan.jmx ^
                                   -l jmeter\\reports\\results.jtl ^
                                   -e -o jmeter\\reports\\html
                        ''',
                        returnStatus: true
                    )

                    if (result != 0) {
                        error("JMeter test execution failed.")
                    }
                }
            }
            post {
                always {
                    script {
                        def jmeterReport = "${env.LOCAL_REPO_PATH}\\jmeter\\reports\\html\\index.html"

                        if (fileExists(jmeterReport)) {
                            publishHTML(target: [
                                reportDir: "${env.LOCAL_REPO_PATH}\\jmeter\\reports\\html",
                                reportFiles: 'index.html',
                                reportName: 'JMeter Performance Tests',
                                allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true
                            ])
                        } else {
                            echo "JMeter HTML report not found."
                        }
                    }
                }
            }
        }

        stage('UI Tests (Robot Framework)') {
            steps {
                script {
                    bat 'mkdir "F:\\reqres-testing\\ui-tests\\reports"'

                    def result = bat(
                        script: '''
                            cd F:\\reqres-testing\\ui-tests
                            robot -d reports tests
                        ''',
                        returnStatus: true
                    )

                    if (result != 0) {
                        error("Robot Framework UI tests failed.")
                    }
                }
            }
            post {
                always {
                    script {
                        def robotReport = "${env.LOCAL_REPO_PATH}\\ui-tests\\reports\\report.html"

                        if (fileExists(robotReport)) {
                            publishHTML(target: [
                                reportDir: "${env.LOCAL_REPO_PATH}\\ui-tests\\reports",
                                reportFiles: 'report.html',
                                reportName: 'Robot Framework UI Tests',
                                allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true
                            ])
                        } else {
                            echo "Robot Framework report not found."
                        }
                    }
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
