mv -f integration_test/gherkin/reports/report_0.json ../../html-report/cucumber-results.json
cd ../../html-report || exit
node index.js
cp test.html "test_$(date "+%Y_%m_%d-%H_%M_%S").html" # save current for later use
