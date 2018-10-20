*** Settings ***

Resource  Resource.robot

Test Teardown   Close Browser

*** Variables ***

${MANAGE PRACTICE URL}    http://${HOST}/admin/practice
${TEST PRACTICE}  Test Practice
${TEST PRACTICE RENAMED}  Test Practices

# Web Elements
${PRACTICE PAGE ELEMENT}  jquery:body > div > main > div > h1:contains("Listing all practices")
${CREATE PRACTICE BTN ELEMENT}  jquery:body > div > main > div > a:contains("New practice")

${CREATE PRACTICE NAME INPUT ELEMENT}   jquery:#practice_name
${CREATE PRACTICE SUBMIT BTN ELEMENT}   jquery:#contest-container > form > div.row > div > div > button:contains("Submit")
${CREATE PRACTICE SUCCESS ELEMENT}  jquery:body > div > p.alert.alert-info:contains("Practice created successfully.")

${DELETE PRACTICE BTN ELEMENT}  jquery:body > div > main > div > table > tbody > tr > td:contains("${TEST PRACTICE RENAMED}") ~ td > .btn-group > form > button:contains("Delete")
${DELETE PRACTICE SUCCESS ELEMENT}  jquery:body > div > p.alert.alert-info:contains("Contest deleted successfully.")

${VIEW PRACTICE BTN ELEMENT}  jquery:body > div > main > div > table > tbody > tr > td:contains("${TEST PRACTICE}") ~ td > .btn-group > a:contains("Show")
${VIEW PRACTICE SUCCESS ELEMENT}  jquery:body > div > main > div > h1:contains("${TEST PRACTICE}")

${EDIT PRACTICE BTN ELEMENT}  jquery:body > div > main > div > table > tbody > tr > td:contains("${TEST PRACTICE}") ~ td > .btn-group > a:contains("Edit")
${EDIT PRACTICE NAME INPUT ELEMENT}   jquery:#practice_name
${EDIT PRACTICE SUBMIT BTN ELEMENT}   jquery:#contest-container > form > div.row > div > div > button:contains("Submit")
${EDIT PRACTICE SUCCESS ELEMENT}  jquery:body > div > p.alert.alert-info:contains("Problem was updated successfully!")

*** Test Cases ***

Create New Practice
  Given browser is opened to login page
  And logged into an admin account
  When admin navigate to manage practices page
  And creates a new practice
  Then a practice created successfully message should be shown
  
View Practices
  Given browser is opened to login page
  And logged into an admin account
  When admin navigate to manage practices page
  And click to view practices
  Then the problems under the practice should be shown

Edit Practices
  Given browser is opened to login page
  And logged into an admin account
  When admin navigate to manage practices page
  And edits a practice details
  Then a practice updated successfully message should be shown

Delete Practices
  Given browser is opened to login page
  And logged into an admin account
  When admin navigate to manage practices page
  And deletes a practice
  Then a practice deleted successfully message should be shown


*** Keywords ***

admin navigate to manage practices page
  Go To   ${MANAGE PRACTICE URL}
  Manage Practice Page Should Be Open

Manage Practice Page Should Be Open
  Page Should Contain Element   ${PRACTICE PAGE ELEMENT}

creates a new practice
  Click Element   ${CREATE PRACTICE BTN ELEMENT}
  Input Text  ${CREATE PRACTICE NAME INPUT ELEMENT}   ${TEST PRACTICE}
  Click Element   ${CREATE PRACTICE SUBMIT BTN ELEMENT}

click to view practices
  Click Element   ${VIEW PRACTICE BTN ELEMENT}

edits a practice details
  Click Element   ${EDIT PRACTICE BTN ELEMENT}
  Input Text  ${EDIT PRACTICE NAME INPUT ELEMENT}   ${TEST PRACTICE RENAMED}
  Click Element   ${EDIT PRACTICE SUBMIT BTN ELEMENT}

deletes a practice
  Click Element   ${DELETE PRACTICE BTN ELEMENT}
  Handle Alert

a practice created successfully message should be shown
  Page Should Contain Element   ${CREATE PRACTICE SUCCESS ELEMENT}
  Location Should Be  ${MANAGE PRACTICE URL}

a practice updated successfully message should be shown
  Page Should Contain Element   ${EDIT PRACTICE SUCCESS ELEMENT}

the problems under the practice should be shown
  Page Should Contain Element   ${VIEW PRACTICE SUCCESS ELEMENT}

a practice deleted successfully message should be shown
  Page Should Contain Element   ${DELETE PRACTICE SUCCESS ELEMENT}
  Location Should Be  ${MANAGE PRACTICE URL}