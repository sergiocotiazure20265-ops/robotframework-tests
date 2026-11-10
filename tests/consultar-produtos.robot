*** Comments ***
Teste BDD para consulta de produtos.
Autentica o administrador, cadastra um produto com código novo
e pesquisa o produto cadastrado na mesma sessão do navegador.

*** Settings ***
Documentation     Teste de consulta de produtos por código
Library           SeleniumLibrary
Library           OperatingSystem
Test Teardown     Finalizar teste

*** Variables ***
${URL_BASE}          https://sergiocotiazure20265-ops.github.io/produtos-cypress-site
${NAVEGADOR}         chrome
${EMAIL_ADMIN}       admin@bluestock.com
${SENHA_ADMIN}       Admin@123
${NOME_PRODUTO}      Notebook Teste Consulta
${CATEGORIA}         Informática
${ESTOQUE}           10
${STATUS_PRODUTO}    Ativo

*** Test Cases ***
Cenário 01 - Consultar produto com sucesso
    [Documentation]    Cadastrar um produto e consultar pelo código gerado
    [Tags]    produto    consulta    positivo

    Given Usuário está autenticado no sistema
    And Cadastra um produto com código novo
    And Acessa a página de consulta de produtos
    When Pesquisa pelo código do produto cadastrado
    Then Deve exibir o produto cadastrado nos resultados
    And Deve gerar evidência    consulta_produto_sucesso

*** Keywords ***
Usuário está autenticado no sistema
    Create Directory    ${OUTPUT DIR}${/}evidencias
    Set Selenium Timeout    10s

    Open Browser    ${URL_BASE}/index.html    ${NAVEGADOR}
    Maximize Browser Window

    Wait Until Element Is Visible    id=emailLogin
    Input Text        id=emailLogin    ${EMAIL_ADMIN}
    Input Password    id=senhaLogin    ${SENHA_ADMIN}
    Click Button      id=btnEntrar

    Wait Until Element Is Visible    id=tituloConsultaProdutos
    Location Should Be    ${URL_BASE}/produtos.html

Cadastra um produto com código novo
    ${identificador}=    Evaluate    uuid.uuid4().hex    modules=uuid
    Set Test Variable    ${IDENTIFICADOR}    ${identificador}
    Set Test Variable    ${CODIGO_PRODUTO}    QA-${identificador}

    Click Link    id=btnNovoProduto
    Wait Until Element Is Visible    id=codigoProduto

    Input Text    id=codigoProduto    ${CODIGO_PRODUTO}
    Input Text    id=nomeProduto    ${NOME_PRODUTO}
    Select From List By Label    id=categoriaProduto    ${CATEGORIA}
    Input Text    id=precoProduto    2500
    Input Text    id=estoqueProduto    ${ESTOQUE}
    Select From List By Label    id=statusProduto    ${STATUS_PRODUTO}
    Input Text
    ...    id=descricaoProduto
    ...    Produto criado para validar a consulta por código.

    Click Button    id=btnSalvarProduto

    Wait Until Element Is Visible    id=alertaFormularioProduto
    Wait Until Element Contains
    ...    id=alertaFormularioProduto
    ...    Produto cadastrado com sucesso.

    Element Text Should Be
    ...    id=alertaFormularioProduto
    ...    Produto cadastrado com sucesso.

    Log    Código gerado para pesquisa: ${CODIGO_PRODUTO}
    Deve gerar evidência    cadastro_para_consulta

Acessa a página de consulta de produtos
    Click Link    id=menuConsultaProdutos
    Wait Until Element Is Visible    id=campoBuscaProduto
    Location Should Be    ${URL_BASE}/produtos.html

Pesquisa pelo código do produto cadastrado
    Input Text    id=campoBuscaProduto    ${CODIGO_PRODUTO}

Deve exibir o produto cadastrado nos resultados
    Wait Until Keyword Succeeds
    ...    10s
    ...    500ms
    ...    Validar resultado da pesquisa

Validar resultado da pesquisa
    # Confirma que a pesquisa retornou somente uma linha.
    ${quantidade}=    Get Element Count
    ...    css=#corpoTabelaProdutos > tr
    Should Be Equal As Integers    ${quantidade}    1

    # Os IDs abaixo são gerados pelo JavaScript da aplicação.
    Element Text Should Be    id=produtoCodigo-1       ${CODIGO_PRODUTO}
    Element Text Should Be    id=produtoNome-1         ${NOME_PRODUTO}
    Element Text Should Be    id=produtoCategoria-1    ${CATEGORIA}
    Element Text Should Be    id=produtoEstoque-1      ${ESTOQUE}
    Element Text Should Be    id=produtoStatus-1       ${STATUS_PRODUTO}

    Element Should Be Visible        id=linhaProduto-1
    Element Should Not Be Visible    id=mensagemSemProdutos

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