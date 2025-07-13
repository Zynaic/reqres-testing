echo "=== Running JMeter Performance Tests ==="
mkdir -p performance-tests/reports

# Check if JMeter is installed
if [ ! -f "apache-jmeter-5.6.3/bin/jmeter" ]; then
    echo "JMeter not found. Downloading..."
    wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.3.zip
    unzip apache-jmeter-5.6.3.zip
    chmod +x apache-jmeter-5.6.3/bin/jmeter
fi

# Run JMeter test
./apache-jmeter-5.6.3/bin/jmeter -n -t performance-tests/jmeter/ReqResTesting.jmx \
    -l performance-tests/reports/results.jtl \
    -e -o performance-tests/reports/html-report \
    -Jjmeter.reportgenerator.overall_granularity=60000

echo "Performance tests completed. Reports generated in performance-tests/reports/"

---