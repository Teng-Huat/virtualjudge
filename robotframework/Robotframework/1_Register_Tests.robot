*** Settings ***

Resource	Resource.robot

Test Teardown	Close Browser

*** Variables ***

${TEST EMAIL}	test@test.com
${TEST PW}	testpassword
${TEST PW CONFIRM}	${TEST PW}
${TEST NAME}	testuser
${TEST BIO}	testuser

# Password minimum length of 8 characters
${INVALID LENGTH PW}	asdd
${INVALID LENGTH PW CONFIRM}	${INVALID LENGTH PW}

${INVALID PW}	asddsaasd
${INVALID PW CONFIRM}	dsadsadsa

# Webpage Elements
${EMAIL INPUT}	jquery:#user_email
${NAME INPUT}	jquery:#user_name
${PW INPUT}	jquery:#user_password
${PW CONFIRM INPUT}	jquery:#user_password_confirmation
${BIO INPUT}	jquery:#user_bio

${VALID ELEMENT}	jquery:body > div > p.alert.alert-info:contains("User account created successfully!")
${INVALID ELEMENT}	jquery:body > div > main > div > form > div.alert.alert-danger > p:contains("Oops, something went wrong! Please check the errors below.")
${EMAIL TAKEN ELEMENT}	jquery:body > div > main > div > form > div.container-fluid > div > div:nth-child(1) > span:contains("has already been taken")
${INVALID PW ELEMENT}	jquery:body > div > main > div > form > div.container-fluid > div > div:nth-child(3) > span:contains("should be at least 8 character(s)")
${INVALID PW CONFIRM ELEMENT}	jquery:body > div > main > div > form > div.container-fluid > div > div:nth-child(4) > span:contains("does not match confirmation")

*** Test Cases ***

Valid Register
	Given browser is opened to register page
	When user enters email "${TEST EMAIL}" and password "${TEST PW}"
	And enters name "${TEST NAME}" and bio "${TEST BIO}"
	And enters password confirmation "${TEST PW CONFIRM}"
	And submit for registeration
	Then successful registeration message should be shown

Invalid Password Format
	Given browser is opened to register page
	When user enters email "${TEST EMAIL}" and password "${INVALID LENGTH PW}"
	And enters name "${TEST NAME}" and bio "${TEST BIO}"
	And enters password confirmation "${INVALID LENGTH PW CONFIRM}"
	And submit for registeration
	Then invalid password length message should be shown

Mismatched Password Confirmation
	Given browser is opened to register page
	When user enters email "${TEST EMAIL}" and password "${INVALID PW}"
	And enters name "${TEST NAME}" and bio "${TEST BIO}"
	And enters password confirmation "${INVALID PW CONFIRM}"
	And submit for registeration
	Then mismatched password confirmation message should be shown

Email Taken
	Given email "${REGISTERED EMAIL}" is registered
	And browser is opened to register page
	When user enters email "${REGISTERED EMAIL}" and password "${TEST PW}"
	And enters name "${TEST NAME}" and bio "${TEST BIO}"
	And enters password confirmation "${TEST PW CONFIRM}"
	And submit for registeration
	Then email taken message should be shown

*** Keywords ***

browser is opened to register page
	Open Browser To Register Page

user enters email "${email}" and password "${password}"
	Input Email    ${email}
    Input Password    ${password}

enters name "${name}" and bio "${bio}"
	Input Name	${name}
	Input Bio	${bio}

enters password confirmation "${password_confirmation}"
	Input Password Confirmation	${password_confirmation}

submit for registeration
	Submit Credentials

email "${registered email}" is registered
	browser is opened to register page
	user enters email "${registered email}" and password "${TEST PW}"
	enters name "${TEST NAME}" and bio "${TEST BIO}"
	enters password confirmation "${TEST PW CONFIRM}"
	submit for registeration
	Close Browser

successful registeration message should be shown
	Page Should Contain Element	${VALID ELEMENT}

invalid password length message should be shown
	Page Should Contain Element	${INVALID ELEMENT}
	Page Should Contain Element	${INVALID PW ELEMENT}

mismatched password confirmation message should be shown
	Page Should Contain Element	${INVALID ELEMENT}
	Page Should Contain Element	${INVALID PW CONFIRM ELEMENT}

email taken message should be shown
	Page Should Contain Element	${INVALID ELEMENT}
	Page Should Contain Element	${EMAIL TAKEN ELEMENT}


Input Email
    [Arguments]    ${email}
    Input Text    ${EMAIL INPUT}    ${email}

Input Password
    [Arguments]    ${password}
    Input Text    ${PW INPUT}    ${password}

Input Password Confirmation
    [Arguments]    ${password}
    Input Text    ${PW CONFIRM INPUT}    ${password}

Input Bio
    [Arguments]    ${bio}
    Input Text    ${BIO INPUT}    ${bio}

Input Name
    [Arguments]    ${name}
    Input Text    ${NAME INPUT}    ${name}

Submit Credentials
	Click Button   ${REGISTER BTN}
