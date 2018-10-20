*** Settings ***
Documentation	A resource file with common keywords and variables.

Library  Selenium2Library

*** Variables ***

${DELAY}	0
${HOST}		localhost:4000
${HOST URL}		http://${HOST}/
${LOGIN URL}	http://${HOST}/sign_in/new
${REGISTER URL}	http://${HOST}/sign_up/new
${TEAM LIST URL}	http://${HOST}/admin/team

${BROWSER}	chrome

${VALID EMAIL}	test@test.com
${INVALID EMAIL}	asd@asd.com
${VALID PW}	testpassword
${INVALID PW}	asdasdasd
${REGISTERED EMAIL}	test@registered.com

${TEST TEAM}	Test Team

${ADMIN EMAIL}	admin@test.com
${ADMIN PW}	adminpassword

# Web Elements
${LOGIN BTN}	jquery:body > div > main > div > form > div > div > div > div > button:contains("Log in")
${REGISTER BTN}	jquery:body > div > main > div > form > div > div > div > div > button:contains("Register")

${EMAIL INPUT}	jquery:#session_email
${PW INPUT}	jquery:#session_password

*** Keywords ***

Browser Is Opened To Login page
	Open Browser To Login Page

Open Browser To Login Page
	Open Browser    ${LOGIN URL}    browser=${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Login Page Should Be Open

Open Browser To Register Page
    Open Browser    ${REGISTER URL}    browser=${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Register Page Should Be Open

Login Page Should Be Open
    Page Should Contain Element	${LOGIN BTN}

Register Page Should Be Open
    Page Should Contain Element	${REGISTER BTN}

Go To Login Page
    Go To    ${LOGIN URL}
    Login Page Should Be Open

Logged In Page Should Be Open
	Location Should Be    ${HOST URL}

Invalid Email/Password Message Should Be Shown
	Page Should Contain Element	${INVALID ELEMENT}


Logged Into An Admin Account
	Input Login Email	${ADMIN EMAIL}
	Input Login Password	${ADMIN PW}
	Submit Login Credentials

Input Login Email
    [Arguments]    ${email}
    Input Text    ${EMAIL INPUT}    ${email}

Input Login Password
    [Arguments]    ${password}
    Input Text    ${PW INPUT}    ${password}

Submit Login Credentials
	Click Button   ${LOGIN BTN}
