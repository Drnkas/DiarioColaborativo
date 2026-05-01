<p align="center">
  <img src="./assets/images/logo_rosa.png" alt="Logo Diário Colaborativo" width="260" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Dart-%230175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
</p>

<h1 align="center">Diário Colaborativo</h1>

<p align="center">
  App mobile para registrar momentos em um diário compartilhado — posts com humor, fotos e comentários, com autenticação e dados na nuvem.
</p>

---

## Visão geral

O **Diário Colaborativo** é um aplicativo **Flutter** focado na experiência de escrever e acompanhar entradas de diário em um contexto colaborativo. A base combina **Firebase** (autenticação, armazenamento e sincronização), **Bloc/Cubit** para estado previsível e **injeção de dependências** com **GetIt**, com navegação declarativa via **go_router**.

## Funcionalidades

- **Conta e sessão** — login, cadastro e integração com **Google Sign-In**
- **Feed e detalhe** — visualização de entradas, reações e fluxo de comentários
- **Criar post** — composição com humor, público-alvo, gradientes/cores e anexos de imagem
- **Perfil** — área do usuário e ajustes relacionados à conta
- **Intro** — splash, onboarding, atualização forçada e telas de manutenção (Remote Config)
- **Qualidade e ops** — Crashlytics, Analytics e notificações (FCM) preparados no stack

## Stack técnica

| Camada | Tecnologias |
|--------|-------------|
| UI / estado | Flutter, `bloc` / `flutter_bloc`, `equatable` |
| Navegação | `go_router` |
| DI | `get_it` |
| Backend / nuvem | Firebase Auth, Cloud Firestore, Storage, Messaging, Remote Config, Analytics, Crashlytics |
| Rede / util | `dio`, validação com `formz`, `brasil_fields`, `email_validator` |
| Outros | `geolocator`, `image_picker`, `shimmer`, armazenamento local (`shared_preferences`, `flutter_secure_storage`) |

## Arquitetura

O código segue organização por **features** (auth, diary, home, profile, intro), com repositórios e datasources separando acesso a dados da UI

## Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) (SDK compatível com `pubspec.yaml`, ex.: Dart `>=3.3.0 <4.0.0`)
- Conta e projeto no [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) para gerar `firebase_options.dart` conforme seu ambiente

## Como rodar

1. Clone o repositório e entre na pasta do projeto.
2. Instale dependências:

   ```bash
   flutter pub get
   ```

3. Configure o Firebase (arquivo `firebase_options.dart` / `GoogleService-Info.plist` / `google-services.json` conforme plataforma). **Não commite chaves ou segredos** — use flavors ou variáveis de ambiente no seu fluxo real de deploy.
4. Execute:

   ```bash
   flutter run
   ```

Para builds de release, siga a [documentação oficial de Flutter](https://docs.flutter.dev/deployment) para Android e iOS.

## Estrutura (resumo)

```
lib/
├── core/          # tema, rotas, utilitários compartilhados
├── di/            # registro GetIt
├── features/      # auth, diary, home, profile, intro, …
└── main.dart      # bootstrap (Firebase, DI, Crashlytics)
```
