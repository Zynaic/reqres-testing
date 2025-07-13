*** Settings ***
Library           SeleniumLibrary

*** Variables ***
${URL}            https://app.reqres.in/
${VALID_EMAIL}     qwerty6@live.in
${VALID_PASS}      qwas0294
${signin_button}   xpath=//button[@component='SignInButton']
${user_list}       xpath=//div[@class='users-grid']/div[@class='user-card']
${login_button}    xpath=//button[@data-localization-key='formButtonPrimary']
${logout_button}   xpath=//button[@component='SignOutButton']
${email}           xpath=//*[@id='identifier-field']
${password}        xpath=//*[@id="password-field"]

*** Keywords ***
Login
    Open Browser                      ${URL}    chrome
    Maximize Browser Window
    Wait Until Element Is Visible     ${signin_button}    10s
    Click Element                     ${signin_button}
    Wait Until Element Is Visible     ${email}    10s
    Input Text                        ${email}    ${VALID_EMAIL}
    Click Element                     ${login_button}
    Wait Until Element Is Visible     ${password}    10s
    Input Text                        ${password}    ${VALID_PASS}
    Click Element                     ${login_button}
    Wait Until Element Contains       xpath=//div[@class='dashboard-header']/h1    Welcome, qwerty6@live.in!    10s

*** Test Cases ***
Login Valid User
    Login
    Close Browser

Verify User List Displayed
    [Setup]   Login
    Wait Until Page Contains Element    ${user_list}    10s
    Scroll Element Into View            xpath=//div[@class='user-card'][h3='Eve Holt']
    ${count}=  Get Element Count        ${user_list}
    Should Be True                      ${count} > 0
    Close Browser

Logout Redirects To Login
    [Setup]   Login
    Click Button                        ${logout_button}
    Wait Until Element Is Visible       ${signin_button}     10s
    Close Browser
