# Sistema de Login com Banco de Dados

> Projeto de portfólio focado em demonstrar, em produção, um fluxo completo de autenticação por sessão: cadastro, login, logout e uma rota protegida — usando bcrypt, express-session e PostgreSQL.

Sistema web desenvolvido em Node.js/Express, com autenticação por sessão persistida em banco de dados, senhas com hash via bcrypt e uma área autenticada que exibe o nome do usuário e a data de registro, buscados diretamente do banco.

## Demonstração

Quer testar o sistema em funcionamento?

**Acesse a versão em produção:**
**https://SEU-DEPLOY-AQUI.onrender.com**

> **Observação:** dependendo do provedor de hospedagem, a primeira visita pode levar alguns segundos para o servidor iniciar (hibernação em planos gratuitos).

## 🚧 Projeto em Desenvolvimento

> Este projeto nasceu como uma demonstração enxuta de autenticação e está em evolução constante — novas telas e ajustes de segurança podem ser adicionados com o tempo.

---

# Sumário

- [Sobre o Projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Demonstração](#demonstração)
- [Arquitetura do Projeto](#arquitetura-do-projeto)
- [Fluxo da Aplicação](#fluxo-da-aplicação)
  - [Cadastro de Usuário](#cadastro-de-usuário)
  - [Login](#login)
  - [Logout](#logout)
  - [Consultar Perfil (rota protegida)](#consultar-perfil-rota-protegida)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Design System](#design-system)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Instalação](#instalação)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Banco de Dados](#banco-de-dados)
- [Executando o Projeto](#executando-o-projeto)
- [Documentação da API](#documentação-da-api)
  - [Autenticação](#autenticação)
  - [Perfil (rota protegida)](#perfil-rota-protegida)
- [Segurança](#segurança)
- [Melhorias Futuras](#melhorias-futuras)
- [Como Contribuir](#como-contribuir)
- [Licença](#licença)
- [Autor](#autor)

---

# Sobre o Projeto

O Sistema de Login com Banco de Dados foi criado para mostrar, de forma direta e sem distrações, como implementar autenticação de usuários em produção: cadastro com validação, login com verificação de senha via bcrypt, sessão persistida no PostgreSQL e uma rota protegida no back-end — que nunca entrega conteúdo para quem não está autenticado, mesmo que a pessoa tente acessar a URL diretamente.

## Funcionalidades

- ✔ Cadastro de usuário com validação de nome, e-mail e senha
- ✔ Confirmação de senha e aceite de termos no registro
- ✔ Login com verificação de credenciais via bcrypt
- ✔ Sessão de usuário persistida em banco de dados (não em memória)
- ✔ Rota protegida por middleware — bloqueia acesso de quem não está logado, sem depender apenas do    front-end
- ✔ Logout que efetivamente destrói a sessão no servidor
- ✔ Endpoint de perfil que retorna nome e data/hora de registro do usuário autenticado
- ✔ Botão de acesso demonstrativo ("login como recrutador") para facilitar avaliação do projeto
- ✔ Mensagens de erro e sucesso tratadas tanto no front quanto no back-end

---
#  Demonstração



Exemplo:

## Tela do Login
![Telas](./docs/Login.PNG)

## Tela do Register
![Telas](./docs/Register.PNG)

## Tela de "Página não encontrada"
![Telas](./docs/??.png)

## Tela de Dashboard protegida por sessão logada 
![Telas](./docs/Dashboard.PNG)



---


# Arquitetura do Projeto

```
Usuário
   |
   ↓
Frontend (login, registro, área autenticada)
   |
   ↓
API Backend (Express)
   |
   ├── Middlewares (sessão/autenticação)
   |
   ├── Controllers (auth)
   |
   └── Banco de Dados (PostgreSQL)
          ├── users     (dados do usuário e senha em hash)
          └── session   (sessões ativas — gerenciada por connect-pg-simple)
```

---

# Fluxo da Aplicação

Fluxo de execução das principais requisições, da chegada ao cliente até a resposta.

## Pipeline Base

```text
Cliente → Express (server.js) → Middleware de Sessão → Controller → PostgreSQL → Resposta HTTP
```

## Cadastro de Usuário

`POST /auth/register`

```text
Cliente → Validação de campos (nome, e-mail, senha, confirmação, termos)
   → Auth Controller → Hash da senha (bcrypt) → INSERT em users → PostgreSQL
   → Resposta HTTP
```

## Login

`POST /auth/login`

```text
Cliente → Auth Controller → SELECT em users pelo e-mail
   → Comparação de senha (bcrypt) → Criação da sessão → Session Cookie
   → Resposta HTTP (redirectTo)
```

## Logout

`POST /auth/logout`

```text
Cliente → Destruição da sessão no servidor → Limpeza do cookie → Resposta HTTP
```

## Consultar Perfil (rota protegida)

`GET /api/me`

```text
Cliente → Middleware de Sessão (bloqueia se não houver sessão ativa)
   → Auth Controller (obterPerfil) → SELECT name, created_at em users pelo id da sessão
   → Resposta HTTP { nome, registradoEm }
```

> **Observação:** essa rota é a base da área autenticada, que exibe "Olá {nome}, você está logado =)" junto com a data de registro do usuário.

---

# Tecnologias Utilizadas

## Backend

- Node.js
- Express.js
- PostgreSQL (`pg`)
- express-session (com persistência via `connect-pg-simple`)
- Bcrypt para hash de senha

## Frontend

- HTML5
- CSS3 (inline, sem framework)
- JavaScript (vanilla)

## Ferramentas

- Git
- GitHub
- DBeaver (administração do banco)

## Hospedagem

- Render / VPS / Cloud

---

# Design System

O projeto segue um tema escuro consistente em todas as telas (login, registro e área autenticada):

- **Fontes:** Inter (interface) e JetBrains Mono (badges, status e mensagens de sistema)
- **Cores principais:** fundo `#0b1120`, cards `#151e32`, azul de destaque `#4f8dfd`, verde de sucesso `#34c98f`, vermelho de erro `#f0716f`
- **Componentes:** cards com `border-radius: 16px`, inputs e botões com `border-radius: 10px`, badges com `border-radius: 6px`

Detalhes completos de tokens de cor, tipografia e componentes estão documentados em [`design-system.md`](./design-system.md).

---

# Estrutura de Pastas

```
sistema-login-com-banco-de-dados
│
├── backend (ou src)
│   │
│   ├── controllers
│   │   └── authController.js       (obterPerfil, e demais funções de auth)
│   │
│   ├── routes
│   │   └── authRoutes.js           (/register, /login, /logout, /me)
│   │
│   ├── middleware
│   │   └── authMiddleware.js       (exige sessão ativa)
│   │
│   ├── config
│   │   └── db.js                   (pool de conexão com o PostgreSQL)
│   │
│   ├── database
│   │   └── schema.sql
│   │
│   └── server.js
│
├── frontend
│   │
│   ├── pages
│   │   ├── login.html
│   │   ├── register.html
│   │   └── logado.html             (área autenticada)
│   │
│   └── design-system.md
│
├── .env
├── package.json
└── README.md
```

---

# Instalação

## Pré-requisitos

Antes de iniciar, tenha instalado:

- Node.js 18+
- Git
- PostgreSQL 13+ configurado

## Clonar o projeto

```bash
git clone https://github.com/rikael7/Sistema-de-login-com-banco-de-dados.git
```

Acesse a pasta:

```bash
cd Sistema-de-login-com-banco-de-dados
```

## Instalar dependências

```bash
npm install
```

Dependências principais usadas no projeto:

```bash
npm install express express-session pg bcrypt connect-pg-simple dotenv
```

---

# Configuração do Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
PORT=3000
DATABASE_URL=postgres://usuario:senha@localhost:5432/sistema_login
SESSION_SECRET=sua_chave_secreta
```

> ⚠️ Nunca versione o `.env`. Confirme que ele está no `.gitignore`.

---

# Banco de Dados

O script de criação de tabelas está em `database/schema.sql`. Para aplicar:

```bash
psql -U seu_usuario -d sistema_login -f schema.sql
```

Ou, se preferir, rode direto no DBeaver.

## Tabelas

| Tabela    | Descrição                                                   |
|-----------|--------------------------------------------------------------|
| `users`   | Usuários: `id`, `name`, `email`, `password` (hash), `created_at` |
| `session` | Sessões ativas, gerenciada automaticamente por `connect-pg-simple` |

---

# Executando o Projeto

Modo desenvolvimento:

```bash
npm run dev
```

ou:

```bash
npm start
```

Servidor disponível em:

```
http://localhost:3000
```

---

# Documentação da API

## Autenticação

### Criar usuário

```
POST /auth/register
```

Exemplo de envio:

```json
{
  "name": "Usuário Teste",
  "email": "usuario@email.com",
  "password": "Senha123"
}
```

### Login

```
POST /auth/login
```

Exemplo de envio:

```json
{
  "email": "usuario@email.com",
  "password": "Senha123",
  "remember": false
}
```

Resposta:

```json
{
  "redirectTo": "/logado.html"
}
```

### Logout

```
POST /auth/logout
```

---

## Perfil (rota protegida)

```
GET /api/me
```

Requer sessão ativa (cookie de sessão enviado automaticamente pelo navegador).

Resposta:

```json
{
  "nome": "Usuário Teste",
  "registradoEm": "2026-08-11T14:32:00.000Z"
}
```

Sem sessão válida:

```json
{
  "erro": "Nenhuma sessão ativa."
}
```
`401 Unauthorized`

---

# Segurança

O projeto utiliza:

- Hash de senha com **bcrypt** (nunca texto puro)
- Sessão persistida em banco de dados via **connect-pg-simple**, não em memória
- Cookie de sessão `httpOnly`, para não ser acessível via JavaScript no navegador
- Rota protegida validada no **back-end** — o front-end nunca é a única barreira de acesso
- Mensagens de erro de login genéricas (não revelam se o e-mail existe ou não na base)
- Variáveis de ambiente para credenciais e chaves sensíveis

---

# Melhorias Futuras

- [ ] Implementar recuperação de senha
- [ ] Adicionar autenticação social (Google)
- [ ] Expirar sessões automaticamente após período de inatividade
- [ ] Adicionar testes automatizados
- [ ] Criar página de erro 404 personalizada

---

# Como Contribuir

Contribuições são bem-vindas.

1. Faça um fork do projeto
2. Crie uma branch:

```bash
git checkout -b minha-feature
```

3. Faça suas alterações
4. Commit:

```bash
git commit -m "feat: minha nova funcionalidade"
```

5. Envie para o GitHub:

```bash
git push origin minha-feature
```

6. Abra um Pull Request

---

# Licença

Este projeto está sob a licença MIT.

---

# Autor

**Rikael**

- GitHub: https://github.com/rikael7

---

Se este projeto foi útil, considere deixar uma estrela no repositório.