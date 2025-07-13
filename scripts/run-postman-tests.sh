echo "=== Running Postman API Tests ==="
mkdir -p api-tests/newman-reports

# Run Newman with HTML Extra reporter
newman run api-tests/postman/collections/Reqres_API_Test_Suite.json \
    -e api-tests/postman/environments/EVN.json \
    --reporters cli,htmlextra,junit \
    --reporter-htmlextra-export api-tests/newman-reports/newman-report.html \
    --reporter-junit-export api-tests/newman-reports/newman-report.xml \
    --reporter-htmlextra-title "ReqRes API Test Report" \
    --reporter-htmlextra-logs

echo "API tests completed. Reports generated in api-tests/newman-reports/"

---