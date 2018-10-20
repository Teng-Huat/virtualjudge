*** Settings ***

Resource	Resource.robot

Test Teardown	Close Browser

*** Variables ***

# Webpage Elements
${EMAIL INPUT}	jquery:#session_email
${PW INPUT}	jquery:#session_password

${VALID ELEMENT}	jquery:#navbarCollapse > ul > li:nth-child(6) > a:contains("Sign out")
${INVALID ELEMENT}	jquery:body > div > p.alert.alert-danger:contains("Invalid email/password combination")

*** Test Cases ***

Valid Login
	Given browser is opened to login page
	When user logs in with "${VALID EMAIL}" and password "${VALID PW}"
	Then logged in page should be open

Empty Password
	Given browser is opened to login page
	When user logs in with "${INVALID EMAIL}" and password "${EMPTY}"
	Then invalid email/password message should be shown

Empty Email
	Given browser is opened to login page
	When user logs in with "${EMPTY}" and password "${VALID PW}"
	Then invalid email/password message should be shown

Empty Email And Password
	Given browser is opened to login page
	When user logs in with "${EMPTY}" and password "${EMPTY}"
	Then invalid email/password message should be shown

Invalid Password
	Given browser is opened to login page
	When user logs in with "${VALID EMAIL}" and password "${INVALID PW}"
	Then invalid email/password message should be shown

Invalid Email
	Given browser is opened to login page
	When user logs in with "${INVALID EMAIL}" and password "${VALID PW}"
	Then invalid email/password message should be shown

Invalid Email And Password
	Given browser is opened to login page
	When user logs in with "${INVALID EMAIL}" and password "${INVALID PW}"
	Then invalid email/password message should be shown

*** Keywords ***

browser is opened to login page
	Open Browser To Login Page

user logs in with "${email}" and password "${password}"
	Input Email    ${email}
    Input Password    ${password}
    Submit Credentials

Input Email
    [Arguments]    ${email}
    Input Text    ${EMAIL INPUT}    ${email}

Input Password
    [Arguments]    ${password}
    Input Text    ${PW INPUT}    ${password}

Submit Credentials
	Click Button   ${LOGIN BTN}