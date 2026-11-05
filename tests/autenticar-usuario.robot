*** Comments ***
Especificação de teste para autenticação de usuário no sistema.

*** Settings ***
Documentation     Testes de autenticação de usuários no sistema
Library           SeleniumLibrary

*** Test Cases ***

Cenário 01 - Autenticar usuário com sucesso
    [Documentation]    Validar autenticação com credenciais válidas
    [Tags]    login    positivo

    Given Usuário está na página de login
    When Informa um email válido
    And Informa uma senha válida
    And Clica no botão entrar
    Then Deve ser redirecionado para a página inicial do sistema

Cenário 02 - Autenticar usuário com acesso negado
    [Documentation]    Validar autenticação com senha incorreta
    [Tags]    login    negativo

    Given Usuário está na página de login
    When Informa um email válido
    And Informa uma senha inválida
    And Clica no botão entrar
    Then Deve ser negado o acesso ao sistema

*** Keywords ***

Usuário está na página de login
    Open Browser    https://sergiocotiazure20265-ops.github.io/produtos-cypress-site/index.html   chrome
    Maximize Browser Window
    Sleep    2s

Informa um email válido
    Input Text     id=emailLogin    admin@bluestock.com
    Sleep          2s

Informa uma senha válida
    Input Text     id=senhaLogin    Admin@123
    Sleep          2s

Clica no botão entrar
    Click Button   btnEntrar
    Sleep          2s

Deve ser redirecionado para a página inicial do sistema
    Page Should Contain        Consulta de produtos
    Page Should Contain        Pesquise, edite e exclua produtos cadastrados.
    Capture Page Screenshot    evidencias/autenticacao_usuario_sucesso.png
    Close Browser

Informa uma senha inválida
    Input Text     id=senhaLogin    SenhaInvalida@123
    Sleep          2s

Deve ser negado o acesso ao sistema
    Page Should Contain        E-mail ou senha inválidos.
    Capture Page Screenshot    evidencias/autenticacao_usuario_negado.png
    Close Browser