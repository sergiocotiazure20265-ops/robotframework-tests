*** Comments ***
Testes BDD para cadastro de produtos.
Cada cenário gera um código novo utilizando UUID.
O cenário de duplicidade reutiliza o código cadastrado no próprio teste.

*** Settings ***
Documentation     Testes de cadastro de produtos com autenticação
Library           SeleniumLibrary
Library           OperatingSystem
Test Teardown     Finalizar teste

*** Variables ***
${URL_BASE}             https://sergiocotiazure20265-ops.github.io/produtos-cypress-site
${NAVEGADOR}            chrome
${EMAIL_ADMIN}          admin@bluestock.com
${SENHA_ADMIN}          Admin@123
${MENSAGEM_SUCESSO}     Produto cadastrado com sucesso.
${MENSAGEM_ERRO}        Já existe um produto com este código.

*** Test Cases ***
Cenário 01 - Cadastrar produto com sucesso
    [Documentation]    Validar cadastro de produto com código novo
    [Tags]    produto    cadastro    positivo

    Given Usuário está autenticado e na página de cadastro de produto
    When Informa os dados de um novo produto
    And Clica no botão salvar produto
    Then Deve exibir a mensagem de produto cadastrado com sucesso
    And Deve gerar evidência    cadastro_produto_sucesso

Cenário 02 - Não deve permitir o cadastro de produtos com o mesmo código
    [Documentation]    Validar rejeição de cadastro com código duplicado
    [Tags]    produto    cadastro    negativo

    Given Usuário está autenticado e na página de cadastro de produto
    And Já existe um produto cadastrado
    When Informa os dados utilizando o código já cadastrado
    And Clica no botão salvar produto
    Then Deve exibir a mensagem de código já cadastrado
    And Deve gerar evidência    cadastro_produto_codigo_duplicado

*** Keywords ***
Usuário está autenticado e na página de cadastro de produto
    Create Directory    ${OUTPUT DIR}${/}evidencias
    Set Selenium Timeout    10s

    Open Browser    ${URL_BASE}/index.html    ${NAVEGADOR}
    Maximize Browser Window

    Wait Until Element Is Visible    id=emailLogin
    Input Text        id=emailLogin    ${EMAIL_ADMIN}
    Input Password    id=senhaLogin    ${SENHA_ADMIN}
    Click Button      id=btnEntrar

    Wait Until Keyword Succeeds
    ...    10s
    ...    500ms
    ...    Location Should Be
    ...    ${URL_BASE}/produtos.html

    Go To    ${URL_BASE}/produto-form.html
    Wait Until Element Is Visible    id=codigoProduto
    Element Text Should Be
    ...    id=tituloFormularioProduto
    ...    Cadastrar produto

Informa os dados de um novo produto
    ${identificador}=    Evaluate    uuid.uuid4().hex    modules=uuid
    Set Test Variable    ${IDENTIFICADOR}    ${identificador}
    Set Test Variable    ${CODIGO_PRODUTO}    QA-${identificador}

    Preencher formulário do produto
    ...    ${CODIGO_PRODUTO}
    ...    Notebook Teste QA

    Log    Código gerado para o teste: ${CODIGO_PRODUTO}

Preencher formulário do produto
    [Arguments]    ${codigo}    ${nome}

    Input Text    id=codigoProduto    ${codigo}
    Input Text    id=nomeProduto    ${nome}
    Select From List By Label    id=categoriaProduto    Informática
    Input Text    id=precoProduto    2500
    Input Text    id=estoqueProduto    10
    Select From List By Label    id=statusProduto    Ativo
    Input Text
    ...    id=descricaoProduto
    ...    Produto cadastrado pelo teste automatizado com Robot Framework.

Clica no botão salvar produto
    Click Button    id=btnSalvarProduto

Deve exibir a mensagem de produto cadastrado com sucesso
    Wait Until Element Is Visible    id=alertaFormularioProduto
    Wait Until Element Contains
    ...    id=alertaFormularioProduto
    ...    ${MENSAGEM_SUCESSO}

    Element Text Should Be
    ...    id=alertaFormularioProduto
    ...    ${MENSAGEM_SUCESSO}

Já existe um produto cadastrado
    Informa os dados de um novo produto
    Clica no botão salvar produto
    Deve exibir a mensagem de produto cadastrado com sucesso
    Deve gerar evidência    preparacao_produto_duplicidade

    Go To    ${URL_BASE}/produto-form.html
    Wait Until Element Is Visible    id=codigoProduto

Informa os dados utilizando o código já cadastrado
    Preencher formulário do produto
    ...    ${CODIGO_PRODUTO}
    ...    Outro Produto Teste QA

Deve exibir a mensagem de código já cadastrado
    Wait Until Element Is Visible    id=alertaFormularioProduto
    Wait Until Element Contains
    ...    id=alertaFormularioProduto
    ...    ${MENSAGEM_ERRO}

    Element Text Should Be
    ...    id=alertaFormularioProduto
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