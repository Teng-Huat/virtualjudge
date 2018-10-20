*** Settings ***

Resource	Resource.robot
Library	OperatingSystem

Test Teardown	Close Browser

*** Variables ***

${MANAGE USER URL}	http://${HOST}/admin/user
${MANAGE USER ELEMENT}	jquery:body > div > main > div > div.row.mr-sm-2 > div.col-md-11 > h1:contains("Listing users currently in the system")

${MANAGE USER LIST ELEMENT}	jquery:body > div > main > div > div:nth-child(2) > div > table > tbody > tr > td:nth-child(1):contains("${ADMIN EMAIL}")

${EXPORT BTN ELEMENT}	jquery:body > div > main > div > div.row.mr-sm-2 > div.float-right > a:contains("Export")

${EXPORT FILENAME}	user_exports.csv

${USER DELETED ELEMENT}	jquery:body > div > p.alert.alert-info:contains("User deleted successfully.")
${USER UPDATED ELEMENT}	jquery:body > div > p.alert.alert-info:contains("User updated successfully.")
${EDIT USER PAGE ELEMENT}	jquery:body > div > main > div > h1:contains("Edit user info")
${EDIT USER TEAM LIST ELEMENT}	jquery:#user_team_id
${EDIT USER SUBMIT BTN ELEMENT}	jquery:body > div > main > div > form > button:contains("Submit")

${EDIT BTN ELEMENT}	jquery:body > div > main > div > div > div > table > tbody > tr > td:contains("${REGISTERED EMAIL}") ~ td > form > .btn-group > a:contains("Edit")

${DELETE BTN ELEMENT}	jquery:body > div > main > div > div > div > table > tbody > tr > td:contains("${VALID EMAIL}") ~ td > form > .btn-group > button:contains("Delete")

*** Test Cases ***

View List
	Given browser is opened to login page
	And logged into an admin account
	When admin navigate to manage user page
	Then details of all users will be listed

Export User List
	Given browser is opened to login page
	And logged into an admin account
	When admin navigate to manage user page
	And exports the user list
	Then a csv file will be downloaded

Edit User
	Given browser is opened to login page
	And logged into an admin account
	When admin navigate to manage user page
	And edits user's team
	Then the user updated successfully message will be shown

Delete User
	Given browser is opened to login page
	And logged into an admin account
	When admin navigate to manage user page
	And deletes a user
	Then then user deleted successfully message will be shown

*** Keywords ***

browser is opened to login page
	Open Browser To Login Page

then user deleted successfully message will be shown
	Page Should Contain Element	${USER DELETED ELEMENT}

the user updated successfully message will be shown
	Team List Page Should Be Open
	Page Should Contain Element	${USER UPDATED ELEMENT}

admin navigate to manage user page
	Go To	${MANAGE USER URL}
	Manage User Page Should Be Open

details of all users will be listed
	Page Should Contain Element	${MANAGE USER LIST ELEMENT}

exports the user list
	Click Element	${EXPORT BTN ELEMENT}

a csv file will be downloaded
	${home_dir}         Get Environment Variable    HOME
	${download_dir}     Join Path   ${home_dir}     Downloads
	Wait Until Keyword Succeeds	10 sec	1 sec	File Should Exist	${download_dir}/${EXPORT FILENAME}

deletes a user
	Delete User	${DELETE BTN ELEMENT}

edits user's team
	Click Element	${EDIT BTN ELEMENT}
	Edit User Page Should Be Open
	Select From List By Label	${EDIT USER TEAM LIST ELEMENT}	${TEST TEAM}
	Click Element	${EDIT USER SUBMIT BTN ELEMENT}

Manage User Page Should Be Open
	Location Should Be	${MANAGE USER URL}
    Page Should Contain Element	${MANAGE USER ELEMENT}

Edit User Page Should Be Open
	Page Should Contain Element	${EDIT USER PAGE ELEMENT}

Team List Page Should Be Open
	Location Should Be	${TEAM LIST URL}

Delete User
	[Arguments]	${delete btn element}
	Click Element 	${delete btn element}
	Handle Alert
