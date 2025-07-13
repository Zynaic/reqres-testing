pipeline {
    agent any

    environment {
        NODEJS_HOME = tool name: 'nodejs'
        PATH = "${NODEJS_HOME}/bin:${env.PATH}"
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
                    bat '''
                        if not exist api-tests\\newman-reports mkdir api-tests\\newman-reports
                        newman run collection\\reqres.postman_collection.json ^
                          -e collection\\reqres.postman_environment.json ^
                          -r cli,htmlextra,junit ^
                          --reporter-htmlextra-export api-tests\\newman-reports\\results.html ^
                          --reporter-junit-export api-tests\\newman-reports\\results.xml
                    '''
                }
            }
            post {
                always {
                    script {
                        if (fileExists('api-tests/newman-reports/results.xml')) {
                            junit 'api-tests/newman-reports/results.xml'
                        } else {
                            echo "Newman JUnit report not found."
                        }

                        if (fileExists('api-tests/newman-reports/results.html')) {
                            publishHTML target: [
                                reportDir: 'api-tests/newman-reports',
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
                    bat '''
                        if not exist jmeter\\reports mkdir jmeter\\reports
                        jmeter -n -t jmeter\\reqres_test_plan.jmx -l jmeter\\reports\\results.jtl -e -o jmeter\\reports\\html
                    '''
                }
            }
            post {
                always {
                    script {
                        if (fileExists('jmeter/reports/html/index.html')) {
                            publishHTML target: [
                                reportDir: 'jmeter/reports/html',
                                reportFiles: 'index.html',
                                reportName: 'JMeter Performance Tests',
                                allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true
                            ]
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
                    bat '''
                        if not exist ui-tests\\reports mkdir ui-tests\\reports
                        cd ui-tests
                        robot -d reports tests
                        cd ..
                    '''
                }
            }
            post {
                always {
                    script {
                        if (fileExists('ui-tests/reports/report.html')) {
                            publishHTML target: [
                                reportDir: 'ui-tests/reports',
                                reportFiles: 'report.html',
                                reportName: 'Robot Framework UI Tests',
                                allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true
                            ]
                        } else {
                            echo "Robot report.html not found."
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
