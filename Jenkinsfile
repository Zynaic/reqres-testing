pipeline {
    agent any

    environment {
        NODEJS_HOME = tool name: 'nodejs'
        PATH = "${NODEJS_HOME}/bin:${env.PATH}"
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
                    bat """
                        if not exist ${env.LOCAL_REPO_PATH}\\api-tests\\newman-reports mkdir ${env.LOCAL_REPO_PATH}\\api-tests\\newman-reports
                        newman run ${env.LOCAL_REPO_PATH}\\collection\\reqres.postman_collection.json ^
                          -e ${env.LOCAL_REPO_PATH}\\collection\\reqres.postman_environment.json ^
                          -r cli,htmlextra,junit ^
                          --reporter-htmlextra-export ${env.LOCAL_REPO_PATH}\\api-tests\\newman-reports\\results.html ^
                          --reporter-junit-export ${env.LOCAL_REPO_PATH}\\api-tests\\newman-reports\\results.xml
                    """
                }
            }
            post {
                always {
                    script {
                        if (fileExists("${env.LOCAL_REPO_PATH}/api-tests/newman-reports/results.xml")) {
                            junit "${env.LOCAL_REPO_PATH}/api-tests/newman-reports/results.xml"
                        } else {
                            echo "Newman JUnit report not found."
                        }

                        if (fileExists("${env.LOCAL_REPO_PATH}/api-tests/newman-reports/results.html")) {
                            publishHTML target: [
                                reportDir: "${env.LOCAL_REPO_PATH}/api-tests/newman-reports",
                                reportFiles: 'results.html',
                                reportName: 'Newman API Tests',
                                allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true
                            ]
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
                    bat """
                        if not exist ${env.LOCAL_REPO_PATH}\\jmeter\\reports mkdir ${env.LOCAL_REPO_PATH}\\jmeter\\reports
                        jmeter -n -t ${env.LOCAL_REPO_PATH}\\jmeter\\reqres_test_plan.jmx ^
                          -l ${env.LOCAL_REPO_PATH}\\jmeter\\reports\\results.jtl ^
                          -e -o ${env.LOCAL_REPO_PATH}\\jmeter\\reports\\html
                    """
                }
            }
            post {
                always {
                    script {
                        def jmeterReport = "${env.LOCAL_REPO_PATH}/jmeter/reports/html/index.html"
                        if (fileExists(jmeterReport)) {
                            publishHTML target: [
                                reportDir: "${env.LOCAL_REPO_PATH}/jmeter/reports/html",
                                reportFiles: 'index.html',
                                reportName: 'JMeter Performance Tests',
                                allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true
                            ]
                        } else {
                            echo "JMeter report not found at ${jmeterReport}"
                        }
                    }
                }
            }
        }

        stage('UI Tests (Robot Framework)') {
            steps {
                script {
                    bat """
                        if not exist ${env.LOCAL_REPO_PATH}\\ui-tests\\reports mkdir ${env.LOCAL_REPO_PATH}\\ui-tests\\reports
                        cd ${env.LOCAL_REPO_PATH}\\ui-tests
                        robot -d reports tests
                    """
                }
            }
            post {
                always {
                    def robotReport = "${env.LOCAL_REPO_PATH}/ui-tests/reports/report.html"
                    if (fileExists(robotReport)) {
                        publishHTML target: [
                            reportDir: "${env.LOCAL_REPO_PATH}/ui-tests/reports",
                            reportFiles: 'report.html',
                            reportName: 'Robot Framework UI Tests',
                            allowMissing: true,
                            alwaysLinkToLastBuild: true,
                            keepAll: true
                        ]
                    } else {
                        echo "Robot report.html not found at ${robotReport}"
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
