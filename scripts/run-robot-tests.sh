echo "=== Running Robot Framework UI Tests ==="
mkdir -p ui-tests/reports

# Activate virtual environment
source venv/bin/activate

# Run Robot Framework tests
robot --outputdir ui-tests/reports \
      --output output.xml \
      --log log.html \
      --report report.html \
      --variable BROWSER:headlesschrome \
      ui-tests/robot/reqres-dashboard-tests.robot

echo "UI tests completed. Reports generated in ui-tests/reports/"

deactivate