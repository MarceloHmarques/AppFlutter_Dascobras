# Aplicativo de armazém e logística 

## 📖 Sobre o Projeto

Este projeto corresponde ao aplicativo móvel do Sistema de Gerenciamento de Armazenamento Logístico, desenvolvido como atividade da disciplina de Engenharia de Software da Universidade Federal Rural do Semi-Árido (UFERSA).

A aplicação foi desenvolvida utilizando Flutter e integra-se ao backend e ao banco de dados hospedados no Supabase, permitindo o gerenciamento de produtos, clientes, vendas e estoque por meio de uma interface intuitiva e responsiva.

---

## 🎯 Objetivo do Sistema

O Sistema de Gerenciamento de Armazenamento Logístico tem como objetivo auxiliar pequenos e médios armazéns no controle e gerenciamento de estoque por meio de uma solução digital integrada. O sistema busca substituir processos manuais baseados em papel, proporcionando maior agilidade, segurança e confiabilidade no armazenamento e consulta das informações.

Além do controle de produtos, a aplicação permite o gerenciamento de clientes, vendas e movimentações de estoque, contribuindo para uma administração mais eficiente das operações logísticas e para a tomada de decisões baseada em dados atualizados em tempo real.

---

## ⚠️ Descrição do Problema

Muitos pequenos e médios armazéns ainda realizam o controle de estoque de forma manual, utilizando anotações em papel ou planilhas pouco estruturadas. Esse processo pode gerar diversos problemas operacionais, como perda de registros, inconsistências entre o estoque físico e o estoque registrado, demora na conferência de mercadorias e dificuldades no acompanhamento das entradas e saídas de produtos.

Além disso, a dependência de processos manuais aumenta a probabilidade de erros humanos, comprometendo a confiabilidade das informações e dificultando a gestão eficiente do negócio. Diante desse cenário, surgiu a necessidade de desenvolver uma solução informatizada capaz de centralizar, automatizar e organizar as informações do armazém, reduzindo falhas operacionais e melhorando o controle logístico.

---

## 🚀 Funcionalidades

### 📦 Gerenciamento de Produtos

- Cadastro de produtos;
- Consulta de produtos cadastrados;
- Atualização de informações dos produtos;
- Exclusão de produtos;
- Controle de estoque disponível.

### 🔍 Busca e Filtragem

- Busca rápida por nome de produto;
- Filtragem por categorias:
  - Bebidas
  - Massas
  - Rações
  - Refrigerantes
  - Grãos

### 🛒 Gerenciamento de Vendas

- Registro de vendas;
- Associação de vendas a clientes;
- Atualização automática do estoque após cada venda;
- Cálculo automático do valor total da compra.

### 👥 Gerenciamento de Clientes

- Cadastro de clientes;
- Consulta de clientes cadastrados;
- Associação de clientes às vendas realizadas.

### 📊 Relatórios

- Consulta de dados operacionais;
- Acompanhamento do faturamento;
- Visualização de informações para apoio à tomada de decisões.

### ⚠️ Controle de Estoque

- Monitoramento de quantidade disponível;
- Alertas para estoque crítico;
- Prevenção de estoque negativo;
- Atualização automática das quantidades.

---

## ⚙️ Como Funciona

O sistema atua como aplicativo móvel responsável pela interação dos usuários com a plataforma de gerenciamento logístico.

Por meio da aplicação, os usuários podem cadastrar produtos e clientes, registrar vendas, consultar informações do estoque e visualizar relatórios. Todas as informações são armazenadas e sincronizadas utilizando os serviços do Supabase, garantindo acesso rápido e atualizado aos dados.

A arquitetura da aplicação segue o padrão MVVM (Model-View-ViewModel), promovendo melhor organização do código e facilitando a manutenção do sistema.

---

## 🛠 Tecnologias Utilizadas

### 💻 Linguagens

- Dart
- SQL

### 🚀 Frameworks e Ferramentas

- Flutter
- Supabase
- FL Chart
- Shared Preferences
- Image Picker

### 📦 Gerenciamento de Estado

- Provider

### 🗄️ Banco de Dados

- PostgreSQL (via Supabase Database)

### ☁️ Backend as a Service (BaaS)

- Supabase Auth
- Supabase Database
- Supabase Storage
- Supabase Realtime

### 🏗️ Arquitetura

- MVVM (Model-View-ViewModel)

### 🔄 Controle de Versão

- Git
- GitHub

### 🔐 Autenticação e Segurança

- Login e Cadastro com Supabase Auth
- Autenticação Biométrica (`local_auth`)
- Controle de Sessão
- Persistência de Autenticação

### 📱 Desenvolvimento Mobile

- Android
- Interface Responsiva
- Navegação entre Telas

### ✅ Formulários e Validações

- Validação de CPF
- Validação de CNPJ
- Validação de CEP
- Validação de E-mail
- Máscaras de Entrada

### 📚 Principais Bibliotecas Flutter

- `provider`
- `supabase_flutter`
- `local_auth`
- `mask_text_input_formatter`
- `intl`
- `shared_preferences`
- `fl_chart`
- `image_picker`
- `cached_network_image`
- `printing`
- `pdf`

---

## 📂 Estrutura do Projeto

O projeto segue a arquitetura MVVM (Model-View-ViewModel), promovendo organização, reutilização de código e facilidade de manutenção.

```text
lib/
├── app/
│   ├── assets/
│   │   └── img/
│   ├── model/
│   ├── pages/
│   │   ├── client/
│   │   ├── home/
│   │   ├── login/
│   │   ├── register/
│   │   ├── reports/
│   │   ├── sales/
│   │   └── widgets/
│   ├── service/
│   └── viewmodels/
│       ├── client_viewmodel/
│       ├── home_viewmodel/
│       ├── login_viewmodel/
│       ├── register_viewmodel/
│       ├── reports_viewmodel/
│       ├── sale_viewmodel/
│       └── splash_viewmodel/
│
└── main.dart
```

### Descrição das Pastas

- **assets/**: imagens e recursos visuais da aplicação.
- **model/**: entidades e modelos de dados.
- **pages/**: telas da aplicação.
- **service/**: serviços e integrações externas.
- **viewmodels/**: gerenciamento de estado e regras de apresentação.
- **main.dart**: ponto de entrada da aplicação.

---

## ▶️ Instruções de Execução

### Pré-requisitos

- Flutter SDK 3.11.5 ou superior
- Dart SDK
- Android Studio ou VS Code
- Git

### Clonar o Repositório

```bash
git clone https://github.com/DaviFreita/appflutter.git
```

### Acessar a Pasta do Projeto

```bash
cd appflutter
```

### Instalar Dependências

```bash
flutter pub get
```

### Executar a Aplicação

```bash
flutter run
```

### Gerar Build Android

```bash
flutter build apk
```

---

## 🎨 Link do Protótipo

Protótipo disponível no Figma:

https://www.figma.com/design/Fqm6snmQq3kKHZqKHD32Up/Sem-t%C3%ADtulo?node-id=0-1&t=nEhTsZnB4IvxOPzZ-1

---

## 📌 Status Atual do Desenvolvimento

🚧 Em desenvolvimento

O sistema encontra-se em desenvolvimento e aprimoramento contínuo pela equipe do projeto.

---

<h2 id="colab" align="center">👥 Colaboradores</h2>

<div align="center">
  <table>
    <tr>
      <td align="center">
        <a href="https://github.com/MarceloHmarques">
          <img src="https://github.com/MarceloHmarques.png" width="100px;" alt="Marcelo Henrique"/><br>
          <sub><b>Marcelo Henrique de Lima Marques</b></sub>
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/alissonricarte">
          <img src="https://github.com/alissonricarte.png" width="100px;" alt="Alisson Ricarte"/><br>
          <sub><b>Alisson Lima Ricarte</b></sub>
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/DaviFreita">
          <img src="https://github.com/DaviFreita.png" width="100px;" alt="Davi Freitas"/><br>
          <sub><b>Davi da Silva Freitas</b></sub>
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/Juanpablouf">
          <img src="https://github.com/Juanpablouf.png" width="100px;" alt="Juan Pablo"/><br>
          <sub><b>Juan Pablo Silva Valdivino</b></sub>
        </a>
      </td>
    </tr>
  </table>

  <br>
</div>
<img width=100% src="https://capsule-render.vercel.app/api?type=waving&height=110&color=F9F9F4&section=footer&reversal=false"/>

---
