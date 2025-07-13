# ReqRes API Testing Project

A comprehensive testing suite for the ReqRes API that includes API testing, performance testing, and UI testing using multiple frameworks.

##Features

- **API Testing**: Postman collections with Newman CLI runner
- **Performance Testing**: JMeter test plans for load testing
- **UI Testing**: Robot Framework for web application testing
- **CI/CD Integration**: Jenkins pipeline for automated testing
- **Multiple Report Formats**: HTML, JUnit XML, and custom reports

##Project Structure

```
reqres-api-testing/
+-- api-tests/                 # Postman API tests
+-- performance-tests/         # JMeter performance tests
+-- ui-tests/                  # Robot Framework UI tests
+-- scripts/                   # Test execution scripts
+-- jenkins/                   # Jenkins configuration
+-- package.json              # Node.js dependencies
+-- requirements.txt           # Python dependencies
+-- Jenkinsfile               # Jenkins pipeline
```


### Jenkins Configuration
1. Create a new Jenkins Pipeline job
2. Configure SCM to point to your Git repository
3. Set the pipeline script path to `Jenkinsfile`
4. Configure global tools:
   - NodeJS (version 18)
   - JDK (version 11)

### Environment Variables
Set these in Jenkins if needed:
- `NODEJS_VERSION`: Node.js version (default: 18)
- `PYTHON_VERSION`: Python version (default: 3.9)
- `JAVA_VERSION`: Java version (default: 11)


##Test Scenarios

### API Tests
- List Users (pagination)
- Get Single User
- Get Invalid User (404 testing)
- List Resources
- Get Single Resource
- Delayed Response testing
- Create User (POST)
- Update User (PUT)
- Delete User (DELETE)

### Performance Tests
- Load testing with 10 concurrent users
- Response time validation
- Throughput testing
- Error rate monitoring

### UI Tests
- User login validation
- Dashboard navigation
- User list verification
- Logout functionality

