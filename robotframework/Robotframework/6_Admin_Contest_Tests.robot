*** Settings ***

Resource  Resource.robot
Library	OperatingSystem

Test Teardown   Close Browser

*** Variables ***

${MANAGE CONTESTS URL}    http://${HOST}/admin/contest
${TEST CONTEST TITLE}  Test Contest
${TEST CONTEST DATE}	10/14/2018 4:32 PM
${TEST CONTEST DURATION}	100
${TEST CONTEST DESCRIPTION}	Test Contest Description
${TEST CONTEST REDATED}  10/15/2018 4:32 PM
${EXPORT FILENAME}	Test_Contest.csv

# Web Elements
${CONTEST PAGE ELEMENT}  jquery:body > div > main > div > h2:contains("Listing contests")
${CREATE CONTEST BTN ELEMENT}  jquery:body > div > main > div > a:contains("New contest")

${CREATE CONTEST TITLE INPUT ELEMENT}   jquery:#contest-container > form > div > div > div > label:contains("Title") + input
${CREATE CONTEST STARTTIME INPUT ELEMENT}	jquery:#contest-container > form > div > div > div > label:contains("Start time") + input
${CREATE CONTEST DURATION INPUT ELEMENT}	jquery:#contest-container > form > div > div > div > label:contains("Duration (in mins)") + input
${CREATE CONTEST DESC INPUT ELEMENT}	jquery:#contest-container > form > div > div > div > label:contains("Description") + textarea
${CREATE CONTEST SUBMIT BTN ELEMENT}   jquery:#contest-container > form > div > div > div > button:contains("Submit")

${CREATE CONTEST SUCCESS ELEMENT}  jquery:body > div > p.alert.alert-info:contains("Contest created successfully.")

${DELETE CONTEST BTN ELEMENT}  jquery:body > div > main > div > table > tbody > tr > td:contains("${TEST CONTEST TITLE}") ~ td > .btn-group > form > button:contains("Delete")
${DELETE CONTEST SUCCESS ELEMENT}  jquery:body > div > p.alert.alert-info:contains("Contest deleted successfully.")

${VIEW CONTEST BTN ELEMENT}  jquery:body > div > main > div > table > tbody > tr > td:contains("${TEST CONTEST TITLE}") ~ td > .btn-group > a:contains("Show")
${VIEW CONTEST SUCCESS ELEMENT}  jquery:body > div > main > div > h1:contains("Showing contest details")

${EDIT CONTEST BTN ELEMENT}  jquery:body > div > main > div > table > tbody > tr > td:contains("${TEST CONTEST TITLE}") ~ td > .btn-group > a:contains("Edit")
${EDIT CONTEST STARTTIME INPUT ELEMENT}   jquery:#contest-container > form > div > div > div > label:contains("Start time") + input
${EDIT CONTEST SUBMIT BTN ELEMENT}   jquery:#contest-container > form > div > div > div > button:contains("Submit")
${EDIT CONTEST SUCCESS ELEMENT}  jquery:body > div > p.alert.alert-info:contains("Contest updated successfully.")


${EXPORT CONTEST RESULTS BTN ELEMENT}	jquery:body > div > main > div > p > a:contains("Export contest results")

*** Test Cases ***

Create Contest
	Given browser is opened to login page
  	And logged into an admin account
  	When admin navigate to manage contests page
  	And creates a new contest
  	Then a contest created successfully message should be shown

View Contest
	Given browser is opened to login page
  	And logged into an admin account
  	When admin navigate to manage contests page
  	And click to view contest
  	Then the details under the contests should be shown

Edit Contest
	Given browser is opened to login page
  	And logged into an admin account
  	When admin navigate to manage contests page
  	And edits a contests details
  	Then a contest updated successfully message should be shown

Export Contest Results
	Given browser is opened to login page
  	And logged into an admin account
  	When admin navigate to manage contests page
  	And click to view contest
  	And export contest results
  	Then a csv file should be downloaded

Delete Contest
	Given browser is opened to login page
  	And logged into an admin account
  	When admin navigate to manage contests page
  	And deletes a contests details
  	Then a contest deleted successfully message should be shown


*** Keywords ***

admin navigate to manage contests page
	Go To   ${MANAGE CONTESTS URL}
  	Manage Contests Page Should Be Open

Manage Contests Page Should Be Open
  	Page Should Contain Element   ${CONTEST PAGE ELEMENT}

creates a new contest
	Click Element 	${CREATE CONTEST BTN ELEMENT}
	Input Text	${CREATE CONTEST TITLE INPUT ELEMENT}	${TEST CONTEST TITLE}
	Input Text 	${CREATE CONTEST STARTTIME INPUT ELEMENT}	${TEST CONTEST DATE}
	Input Text	${CREATE CONTEST DURATION INPUT ELEMENT}	${TEST CONTEST DURATION}
	Input Text	${CREATE CONTEST DESC INPUT ELEMENT}	${TEST CONTEST DESCRIPTION}
	Click Element 	${CREATE CONTEST SUBMIT BTN ELEMENT}

click to view contest
	Click Element 	${VIEW CONTEST BTN ELEMENT}

export contest results
	Click Element 	${EXPORT CONTEST RESULTS BTN ELEMENT}

edits a contests details
	Click Element 	${EDIT CONTEST BTN ELEMENT}
	Input Text	${EDIT CONTEST STARTTIME INPUT ELEMENT}	${TEST CONTEST REDATED}
	Click Element 	${EDIT CONTEST SUBMIT BTN ELEMENT}

deletes a contests details
	Click Element 	${DELETE CONTEST BTN ELEMENT}
	Handle Alert

the details under the contests should be shown
	Page Should Contain Element	${VIEW CONTEST SUCCESS ELEMENT}

a contest created successfully message should be shown
	Page Should Contain Element	${CREATE CONTEST SUCCESS ELEMENT}

a contest updated successfully message should be shown
	Page Should Contain Element	${EDIT CONTEST SUCCESS ELEMENT}

a contest deleted successfully message should be shown
	Page Should Contain Element	${DELETE CONTEST SUCCESS ELEMENT}

a csv file should be downloaded
	${home_dir}         Get Environment Variable    HOME
	${download_dir}     Join Path   ${home_dir}     Downloads
	File Should Exist	${download_dir}/${EXPORT FILENAME}