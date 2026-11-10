*** Comments ***
Especificação de testes para criação de usuários.
Cada cenário gera um novo e-mail utilizando UUID.
As evidências são armazenadas na pasta evidencias do diretório de saída.

*** Settings ***
Documentation     Testes de criação de usuários com BDD
Library           SeleniumLibrary
Library           OperatingSystem
Test Teardown     Finalizar teste

*** Variables ***
${URL}                  https://sergiocotiazure20265-ops.github.io/produtos-cypress-site/cadastro.html
${NAVEGADOR}            chrome
${SENHA}               Teste@123
${MENSAGEM_SUCESSO}     Usuário cadastrado com sucesso. Você já pode fazer login.
${MENSAGEM_ERRO}        Já existe um usuário cadastrado com este e-mail.

*** Test Cases ***
Cenário 01 - Criar usuário com sucesso
    [Documentation]    Validar o cadastro de um usuário com e-mail novo
    [Tags]    cadastro    positivo

    Given Usuário está na página de criação de conta
    When Informa os dados de um novo usuário
    And Clica no botão cadastrar
    Then Deve exibir a mensagem de cadastro realizado com sucesso
    And Deve gerar evidência    criar_usuario_sucesso

Cenário 02 - Não deve permitir a criação de usuário com email já cadastrado
    [Documentation]    Validar a rejeição de cadastro com e-mail duplicado
    [Tags]    cadastro    negativo

    Given Usuário está na página de criação de conta
    And Já existe um usuário cadastrado
    When Informa os dados utilizando o email já cadastrado
    And Clica no botão cadastrar
    Then Deve exibir a mensagem de email já cadastrado
    And Deve gerar evidência    criar_usuario_email_duplicado

*** Keywords ***
Usuário está na página de criação de conta
    Create Directory    ${OUTPUT DIR}${/}evidencias
    Set Selenium Timeout    10s
    Open Browser    ${URL}    ${NAVEGADOR}
    Maximize Browser Window
    Wait Until Element Is Visible    id=nomeUsuario
    Wait Until Element Is Visible    id=emailUsuario
    Wait Until Element Is Visible    id=senhaUsuario
    Wait Until Element Is Visible    id=btnCadastrarUsuario

Informa os dados de um novo usuário
    ${identificador}=    Evaluate    uuid.uuid4().hex    modules=uuid
    Set Test Variable    ${IDENTIFICADOR}    ${identificador}
    Set Test Variable    ${EMAIL_GERADO}    qa.${identificador}@example.com

    Input Text        id=nomeUsuario     Usuário Teste QA
    Input Text        id=emailUsuario    ${EMAIL_GERADO}
    Input Password    id=senhaUsuario    ${SENHA}

    Log    E-mail gerado para o teste: ${EMAIL_GERADO}

Clica no botão cadastrar
    Click Button    id=btnCadastrarUsuario

Deve exibir a mensagem de cadastro realizado com sucesso
    Wait Until Element Is Visible    id=alertaCadastroUsuario
    Wait Until Element Contains
    ...    id=alertaCadastroUsuario
    ...    ${MENSAGEM_SUCESSO}
    Element Text Should Be
    ...    id=alertaCadastroUsuario
    ...    ${MENSAGEM_SUCESSO}

Já existe um usuário cadastrado
    Informa os dados de um novo usuário
    Clica no botão cadastrar
    Deve exibir a mensagem de cadastro realizado com sucesso
    Deve gerar evidência    preparar_usuario_para_duplicidade

Informa os dados utilizando o email já cadastrado
    Input Text        id=nomeUsuario     Outro Usuário QA
    Input Text        id=emailUsuario    ${EMAIL_GERADO}
    Input Password    id=senhaUsuario    ${SENHA}

Clica no botão voltar para login
    Click Link    id=linkLogin

Deve exibir a mensagem de email já cadastrado
    Wait Until Element Is Visible    id=alertaCadastroUsuario
    Wait Until Element Contains
    ...    id=alertaCadastroUsuario
    ...    ${MENSAGEM_ERRO}
    Element Text Should Be
    ...    id=alertaCadastroUsuario
    ...    ${MENSAGEM_ERRO}

Deve gerar evidência
    [Arguments]    ${nome}
    Capture Page Screenshot
    ...    ${OUTPUT DIR}${/}evidencias${/}${nome}_${IDENTIFICADOR}.png

Finalizar teste
    Run Keyword If Test Failed
    ...    Run Keyword And Ignore Error
    ...    Capture Page Screenshot
    ...    ${OUTPUT DIR}${/}evidencias${/}falha_{index}.png

    Close All Browsers