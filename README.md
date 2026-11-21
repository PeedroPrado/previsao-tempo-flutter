# 🌦️ Previsão do Tempo — Flutter

Aplicativo mobile desenvolvido em Flutter para consulta da previsão do tempo, permitindo pesquisar cidades e visualizar informações meteorológicas utilizando dados do CPTEC/INPE.

## 📱 Sobre o projeto

O **Previsão do Tempo** foi desenvolvido como atividade acadêmica, com o objetivo de praticar desenvolvimento mobile utilizando Flutter, consumo de APIs, organização de código e persistência de dados local.

O aplicativo permite que o usuário consulte a previsão meteorológica de diferentes cidades e mantenha sua cidade selecionada mesmo após fechar e abrir o aplicativo novamente.

## ✨ Funcionalidades

- 🔍 Busca de cidades
- 🌤️ Consulta de previsão meteorológica
- 📅 Visualização da previsão por dia
- 🌎 Integração com dados do CPTEC/INPE
- 💾 Persistência da última cidade selecionada
- 🔄 Atualização das informações meteorológicas
- 🎨 Interface com tema visual personalizado

## 🛠️ Tecnologias utilizadas

- **Flutter** — Desenvolvimento da interface mobile
- **Dart** — Linguagem de programação
- **CPTEC/INPE** — Fonte dos dados meteorológicos
- **Node.js** — Servidor proxy
- **HTTP** — Requisições à API
- **SharedPreferences** — Persistência local dos dados

## 📂 Estrutura do projeto

```text
previsao_tempo/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── previsao_dia.dart
│   └── services/
│       ├── busca_cidade_screen.dart
│       ├── cptec_service.dart
│       └── previsao_service.dart
├── proxy/
│   └── server.js
├── pubspec.yaml
└── README.md
```

## 🚀 Como executar o projeto

### Pré-requisitos

- Flutter instalado
- Dart SDK
- Node.js instalado
- Emulador Android ou dispositivo físico

### 1. Clone o repositório

```bash
git clone https://github.com/PeedroPrado/previsao-tempo-flutter.git
```

### 2. Entre na pasta do projeto

```bash
cd previsao-tempo-flutter
```

### 3. Instale as dependências Flutter

```bash
flutter pub get
```

### 4. Inicie o servidor proxy

Em um terminal, execute:

```bash
node proxy/server.js
```

### 5. Execute o aplicativo

```bash
flutter run
```

## 🌐 API

O projeto utiliza dados meteorológicos disponibilizados pelo **CPTEC/INPE**, realizando as requisições por meio de um servidor proxy Node.js para auxiliar na comunicação com os serviços externos.

## 📚 Objetivos acadêmicos

Este projeto tem como objetivo aplicar conceitos de:

- Desenvolvimento de aplicações mobile;
- Consumo de APIs REST;
- Programação com Flutter e Dart;
- Organização de código em serviços e modelos;
- Persistência local de dados;
- Comunicação entre aplicação e servidor.

## 👨‍💻 Desenvolvedor

**Pedro Henrique Prado de Novaes**

Estudante de Desenvolvimento de Software Multiplataforma — Fatec Jacareí.

---

Desenvolvido como projeto acadêmico.
