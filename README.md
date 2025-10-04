# 🍔 eu-comida API

Backend do projeto "Eu Comida", um aplicativo de delivery de comida que nasce com a proposta de ser um concorrente direto ao iFood.

Este projeto é construído com Java e Spring Boot, containerizado com Docker e preparado para orquestração com Kubernetes.

---

## Índice

- [Arquitetura e Tecnologias](#arquitetura-e-tecnologias)
- [Pré-requisitos](#pré-requisitos)
- [Configuração](#configuração)
  - [Perfis do Spring](#perfis-do-spring)
  - [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Como Executar](#como-executar)
  - [1. Ambiente de Desenvolvimento (IDE)](#1-ambiente-de-desenvolvimento-ide)
  - [2. Docker Compose](#2-docker-compose)
  - [3. Kubernetes (k3d/minikube/etc)](#3-kubernetes-k3dminikubeetc)
- [Processo de Build](#processo-de-build)
- [Estrutura do Banco de Dados](#estrutura-do-banco-de-dados)
- [Estratégia de Autenticação e Autorização](#estratégia-de-autenticação-e-autorização)
- [Estratégia de Escalabilidade e Segurança](#estratégia-de-escalabilidade-e-segurança)
- [🚀 MVP Inicial](#-mvp-inicial)
- [Documentação da API (Swagger)](#documentação-da-api-swagger)
- [Migrações de Banco de Dados (Flyway)](#migrações-de-banco-de-dados-flyway)

## Arquitetura e Tecnologias

- **Linguagem:** Java 21
- **Framework:** Spring Boot 3.5.4
- **Build Tool:** Apache Maven
- **Banco de Dados:** MySQL 8.0
- **Mensageria:** RabbitMQ
- **Migrações de BD:** Flyway
- **Segurança:** Spring Security & OAuth2 Authorization Server
- **Documentação da API:** Springdoc OpenAPI 3 (Swagger UI)
- **Containerização:** Docker & Docker Compose
- **Orquestração:** Kubernetes

## Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas:

- JDK 21 (ou superior)
- Apache Maven 3.9+
- Docker
- Docker Compose
- `kubectl` (para deploy em Kubernetes)
- `k3d` (para criação de cluster Kubernetes local)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)

## Configuração

O projeto utiliza um sistema de perfis do Spring para gerenciar as configurações de diferentes ambientes.

### Perfis do Spring

- **`application.yaml` (padrão/local):** Usado para desenvolvimento local. Conecta-se a serviços (MySQL, RabbitMQ) em `localhost`.
- **`application-docker.yml` (perfil `docker`):** Usado pelo Docker Compose. Conecta-se aos serviços usando os nomes da rede Docker (`eucomida-mysql`, `rabbitmq`).
- **`application-k3d.yml` (perfil `k3d`):** Usado no Kubernetes. Conecta-se aos serviços usando os nomes dos `Services` do Kubernetes (`mysql-service`, `rabbitmq-service`) e utiliza variáveis de ambiente para credenciais.

### Variáveis de Ambiente

Para o ambiente Kubernetes, as seguintes variáveis de ambiente são necessárias:

- `SPRING_PROFILES_ACTIVE`: Define o perfil ativo (ex: `k3d`).
- `SPRING_DATASOURCE_USERNAME`: Nome de usuário do MySQL.
- `SPRING_DATASOURCE_PASSWORD`: Senha do MySQL.
- `SPRING_RABBITMQ_USERNAME`: Nome de usuário do RabbitMQ.
- `SPRING_RABBITMQ_PASSWORD`: Senha do RabbitMQ.

## Como Executar

### 1. Ambiente de Desenvolvimento (IDE)

1.  **Inicie as dependências:** A forma mais fácil é usar o Docker Compose para iniciar o MySQL e o RabbitMQ.
    ```bash
    docker-compose -f docker/docker-compose.yaml up mysql rabbitmq
    ```
2.  **Execute a Aplicação:** Abra o projeto na sua IDE de preferência (IntelliJ, VS Code, Eclipse) e execute a classe principal `EuComidaApplication.java`.

A aplicação estará disponível em `http://localhost:8080`.

### 2. Docker Compose

Este método sobe a aplicação e todas as suas dependências de uma só vez.

1.  Na raiz do projeto, execute o seguinte comando:
    ```bash
    docker-compose -f docker/docker-compose.yaml up --build
    ```
    O comando `--build` garante que a imagem da sua aplicação será reconstruída caso haja alterações no código.

A aplicação estará disponível em `http://localhost:8080`.

### 3. Kubernetes com k3d e Make (Recomendado)

O `Makefile` na raiz do projeto automatiza todo o processo de deploy em um ambiente Kubernetes local usando `k3d`.

1.  **Faça o deploy da stack completa:**
    Este comando único irá:
    - Criar um cluster `k3d` chamado `eu-comida-cluster` (se não existir).
    - Mapear as portas `8080` (aplicação) e `15672` (RabbitMQ UI) para o seu `localhost`.
    - Construir a imagem Docker da aplicação.
    - Importar a imagem diretamente para o cluster `k3d`, sem a necessidade de um registro externo.
    - Aplicar todos os manifestos do diretório `k8s/` para subir o MySQL, RabbitMQ e a aplicação.

    ```bash
    make deploy
    ```

2.  **Acesse os serviços:**
    - **API `eu-comida`:** `http://localhost:8080`
    - **RabbitMQ Management:** `http://localhost:15672` (usuário/senha: `rabbitmq`)

3.  **Para remover o cluster e todos os recursos:**
    ```bash
    make delete-cluster
    ```

### 4. Deploy em Produção (Azure Kubernetes Service)

Esta seção descreve como fazer o deploy da aplicação em um ambiente de produção na Azure.

> **Nota de Infraestrutura:**
> Toda a infraestrutura necessária na Azure (Azure Kubernetes Service, Azure Container Registry, MySQL, etc.) pode ser provisionada utilizando o projeto de Infraestrutura como Código (IaC) disponível em: [https://github.com/cadugr/eucomida-azure](https://github.com/cadugr/eucomida-azure).

1.  **Build, Tag e Push da Imagem para o Azure Container Registry (ACR):**

    ```bash
    # Defina o nome do seu ACR
    ACR_NAME="seu-acr-name"

    # 1. Faça o login no seu ACR
    az acr login --name $ACR_NAME

    # 2. Construa a imagem Docker da aplicação
    docker build -t eu-comida-app:latest .

    # 3. Tagueie a imagem para o seu ACR
    docker tag eu-comida-app:latest $ACR_NAME.azurecr.io/eu-comida-app:latest

    # 4. Envie a imagem para o ACR
    docker push $ACR_NAME.azurecr.io/eu-comida-app:latest
    ```

2.  **Atualize o Manifesto Kubernetes (`k8s/app.yaml`):**

    Antes de aplicar os manifestos, você **precisa** alterar o arquivo `k8s/app.yaml` para que ele aponte para a imagem que você acabou de enviar para o ACR.

    ```yaml
    # k8s/app.yaml
    ...
      containers:
      - name: eu-comida-app
        # Altere a linha abaixo
        image: seu-acr-name.azurecr.io/eu-comida-app:latest
        imagePullPolicy: Always
    ...
    ```

3.  **Conecte-se ao Cluster AKS e Faça o Deploy:**

    ```bash
    # Defina o nome do seu Resource Group e Cluster AKS
    RESOURCE_GROUP="seu-resource-group"
    AKS_NAME="seu-aks-cluster-name"

    # 1. Obtenha as credenciais do seu cluster AKS
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

    # 2. Aplique todos os manifestos Kubernetes
    # (Opcional: você pode precisar ajustar os manifestos de mysql e rabbitmq
    # se estiver usando serviços gerenciados da Azure para eles)
    kubectl apply -f k8s/
    ```

4.  **Verifique o Deploy:**

    Após alguns instantes, a aplicação estará disponível através de um IP público. Você pode obtê-lo com o comando:

    ```bash
    kubectl get service eu-comida-service -o wide
    ```

    > [!IMPORTANT]
    > **Acesso em Produção vs. Local**
    > 
    > - **Ambiente de Produção (AKS):** Para acessar a aplicação e o painel do RabbitMQ, utilize o `EXTERNAL-IP` fornecido pelos `Services` do Kubernetes do tipo `LoadBalancer`. Você pode listar todos os IPs com `kubectl get service eu-comida-service -o wide`.
    > - **Ambientes Locais (IDE, Docker Compose, k3d):** O acesso deve ser feito sempre via `localhost`, por exemplo:
    >   - **API:** `http://localhost:8080`
    >   - **RabbitMQ:** `http://localhost:15672`

## Processo de Build

Para compilar o projeto e gerar o artefato `.jar` sem executar em um contêiner, use o Maven Wrapper:

```bash
./mvnw clean package
```

O arquivo `eu-comida-0.0.1-SNAPSHOT.jar` será gerado no diretório `target/`.


## Estrutura do Banco de Dados

A aplicação utiliza **MySQL** como banco de dados relacional. A modelagem inicial inclui as seguintes entidades:

- `User`: representa os usuários e entregadores do sistema
- `Role` e `Permission`: controle de acesso baseado em papéis e permissões
- `Order`: representa os pedidos realizados no sistema

A **evolução do banco de dados** é gerenciada utilizando o **Flyway**, uma ferramenta moderna de versionamento de migrations SQL.

### Migrations com Flyway

O Flyway detecta **automaticamente** todos os scripts `.sql` localizados na pasta:

```
src/main/resources/db/migration
```

Os arquivos devem seguir a convenção de nomenclatura:

```
V<versão>__<descrição>.sql
```

> Exemplo de script válido:
> 
> `V001__create-order-table.sql`

Esse script será executado automaticamente ao iniciar a aplicação. O Flyway mantém um histórico das migrations já aplicadas, garantindo controle e integridade do schema do banco de dados em todos os ambientes.

### Massa de dados para ambiente de desenvolvimento

Quando a aplicação é executada com o profile `dev`, uma massa de dados **para testes** é automaticamente carregada logo após a execução das migrations. Esses dados estão definidos no arquivo:

```
src/main/resources/db/testdata/afterMigrate.sql
```

Este script insere uma **massa de dados inicial para testes**, incluindo:

- Usuário `joao`, com senha `123`, do tipo USER, com a permissão `CREATE_ORDER`
- Usuária `maria`, com senha `123`, do tipo DELIVERY_MAN, com as permissões `CREATE_ORDER` e `CONSULT_ORDER_STATUS`
- Cliente `frontend-web`, necessário para o fluxo de autenticação **Authorization Code com PKCE** a ser utilizado pela aplicação frontend.

Esse script é ideal para facilitar testes locais e simulações de uso da aplicação em ambiente de desenvolvimento. Ele **não deve ser executado** em ambientes como staging ou produção.

> 🔄 A execução com profile `dev` via Docker é explicada mais adiante neste documento, na seção **Execução com Docker Compose**.


## Estratégia de Autenticação e Autorização

A autenticação e autorização são realizadas com **OAuth2** utilizando **JWT** como token de acesso.

Como as APIs REST serão consumidas por um frontend web (SPA) e por um aplicativo mobile, foi adotado o fluxo de **Authorization Code com PKCE**, por ser o mais seguro e recomendado para SPAs.

Endpoints protegidos exigem um token válido no cabeçalho `Authorization: Bearer <token>`.

### 👤 Usuários de Teste

Dois usuários são automaticamente cadastrados na base de dados ao subir a aplicação com o Flyway:

| Usuário | Senha | Tipo de usuário | Permissões atribuídas |
|--------|--------|------------------|------------------------|
| `joao` | `123`  | USER             | `CREATE_ORDER`         |
| `maria`| `123`  | DELIVERY_MAN     | `CREATE_ORDER`, `CONSULT_ORDER_STATUS` |

**Resumo:**

- `joao` poderá **apenas criar pedidos**.
- `maria` poderá **criar e consultar pedidos**.

### Passo a passo para obter um token válido:

1. **Gerar o code verifier e o code challenge no terminal:**

```bash
CODE_VERIFIER=$(openssl rand -base64 32 | tr -d '=+/' | cut -c1-43)
echo $CODE_VERIFIER

CODE_CHALLENGE=$(echo -n "$CODE_VERIFIER" | openssl dgst -sha256 -binary | openssl base64 | tr -d '=' | tr '/+' '_-')
echo $CODE_CHALLENGE
```
Os valores impressos serão usados nas próximas etapas.

2. **Iniciar o fluxo de autorização:**

Acesse a URL (substituindo <code_challenge> pelo valor gerado):

```bash
http://localhost:8080/oauth2/authorize?response_type=code&client_id=frontend-web&redirect_uri=http://localhost:4200/callback&scope=profile%20email&code_challenge=<code_challenge>&code_challenge_method=S256
```

3. **Login no Spring Security:**

Você será redirecionado para:

```bash
http://localhost:8080/login
```

Preencha com usuário e senha previamente cadastrados, por exemplo:

- usuário: joao
- senha: 123

4. **Receber o código de autorização:**

Após login, você será redirecionado para:

```bash
http://localhost:4200/callback?code=<authorization_code>
```

5. **Trocar o código pelo token de acesso:**

Execute a requisição abaixo, substituindo <authorization_code> e <code_verifier> pelos valores gerados anteriormente:

```bash
curl --request POST \
  --url http://localhost:8080/oauth2/token \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=authorization_code \
  --data client_id=frontend-web \
  --data redirect_uri=http://localhost:4200/callback \
  --data code=<authorization_code> \
  --data code_verifier=<code_verifier>
```

6. **Uso do token:**

Use o token JWT retornado para acessar os endpoints protegidos da API, informando-o no cabeçalho:

```bash
Authorization: Bearer <token>
```

## Estratégia de Escalabilidade e Segurança

- **Escalabilidade Horizontal:** aplicação preparada para rodar em múltiplas instâncias (stateless), ideal para ambientes em nuvem.
- **Segurança:**
    - Tokens JWT assinado com chave privada RSA
    - Spring Security com validações e restrições por escopo/permissão
    - Validação de entrada com `@Valid` e mensagens padronizadas
    - Tratamento global de exceções


## 🚀 MVP Inicial

O MVP entregue nesta primeira fase do projeto contém as seguintes funcionalidades:

### 1. Criação de pedidos

```http
curl --request POST \
  --url http://localhost:8080/orders \
  --header 'Content-Type: application/json' \
  --header 'Authorization: Bearer <token>' \
  --data 
  {
    "subtotal": 1300,
    "freightRate": 30,
    "totalValue": 1330
  }
```

### 2. Consulta de status do pedido

```http
curl --request GET \
  --url http://localhost:8080/orders/1/status \
  --header 'Authorization: Bearer <token>'
```

### 3. Autenticação

- Login via fluxo Authorization Code com PKCE
- Emissão e validação de tokens JWT
- Controle de acesso por permissões (`@PreAuthorize`)

## Documentação da API (Swagger)

Com a aplicação em execução, a documentação da API, gerada com Springdoc OpenAPI, fica disponível nos seguintes endpoints:

- **Swagger UI:** `http://localhost:8080/swagger-ui.html`
- **Definição OpenAPI 3 (JSON):** `http://localhost:8080/v3/api-docs`
