*** Settings ***

Resource	Resource.robot

Test Teardown	Close Browser

*** Variables ***

${TEST DELETE TEAM}	Team Team For Delete

${MANAGE TEAM PAGE ELEMENT}	jquery:body > div > main > div > h1:contains("Listing teams")
${CREATE TEAM INPUT ELEMENT}	jquery:#team_name
${CREATE TEAM BTN ELEMENT}	jquery:body > div > main > div > div > div > form > button:contains("Create")
${DELETE TEAM BTN ELEMENT}	jquery:body > div > main > div > ul > li > b:contains("${TEST DELETE TEAM}") ~ form > button:contains("Delete")

${CREATE TEAM SUCCESS ELEMENT}	jquery:body > div > p.alert.alert-info:contains("Team created successfully.")

${DELETE TEAM SUCCESS ELEMENT}	jquery:body > div > p.alert.alert-info:contains("Deleted ${TEST DELETE TEAM}")

*** Test Cases ***

Create Team
	Given browser is opened to login page
	And logged into an admin account
	When admin navigate to manage teams page
	And creates a new team
	Then a team created successfully message should be shown

Delete Team
	[Documentation]	Setup new team for deletion
	[Setup]	Create Team For Deletion
	Given browser is opened to login page
	And logged into an admin account
	When admin navigate to manage teams page
	And deletes a team
	Then a team deleted successfully message should be shown

*** Keywords ***

admin navigate to manage teams page
	Go To	${TEAM LIST URL}
	Manage Teams Page Should Be Open

creates a new team
	Create New Team	${TEST TEAM}
	
deletes a team
	Click Element	${DELETE TEAM BTN ELEMENT}
	Handle Alert

a team created successfully message should be shown
	Page Should Contain Element	${CREATE TEAM SUCCESS ELEMENT}

a team deleted successfully message should be shown
	Page Should Contain Element	${DELETE TEAM SUCCESS ELEMENT}

Manage Teams Page Should Be Open
	Location Should Be 	${TEAM LIST URL}
	Page Should Contain Element	${MANAGE TEAM PAGE ELEMENT}

Create New Team
	[Arguments]	${team name}
	Input Text	${CREATE TEAM INPUT ELEMENT}	${team name}
	Click Element	${CREATE TEAM BTN ELEMENT}

Create Team For Deletion
	Open Browser To Login Page
	Logged Into An Admin Account
	Admin Navigate To Manage Teams Page
	Create New Team	${TEST DELETE TEAM}
	Close Browser

