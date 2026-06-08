# 📱 Pokédex Flutter

Aplicativo mobile de Pokédex desenvolvido em **Flutter + Dart** como projeto da disciplina de Computação para Dispositivos Móveis. O app consome a [PokeAPI](https://pokeapi.co/) para exibir informações detalhadas dos pokémons, com suporte a favoritos e histórico de visualizações salvos localmente.

---

## 👥 Equipe

| Nome | GitHub |
|---|---|
| Stenio Calado | [@StenioCalado](https://github.com/StenioCalado) |
| Wesley Almeida | [@idkWhisper] (https://github.com/idkWhisper) |
| Jeniffer Vitória | — |

---

## ✨ Funcionalidades

- 📋 **Listagem** de pokémons com scroll infinito
- 🔍 **Busca** por nome ou número
- 🏷️ **Filtro por tipo** com seleção múltipla (ex: Elétrico + Voador)
- 📄 **Tela de detalhes** com:
  - Imagem oficial
  - Tipos com cores dinâmicas
  - Estatísticas base com barras de progresso
  - Altura e peso
  - Descrição do pokémon
  - Cadeia de evolução clicável
- ⭐ **Favoritos** salvos localmente com SQLite
- 🕓 **Histórico** dos últimos 30 pokémons visitados

---

## 🛠️ Tecnologias

- [Flutter](https://flutter.dev/) + [Dart](https://dart.dev/)
- [PokeAPI](https://pokeapi.co/) — API REST gratuita
- [sqflite](https://pub.dev/packages/sqflite) — banco de dados SQLite local
- [http](https://pub.dev/packages/http) — requisições HTTP
- [cached_network_image](https://pub.dev/packages/cached_network_image) — cache de imagens

---

## 🗂️ Estrutura do Projeto

```
lib/
├── main.dart                  # Ponto de entrada
├── app.dart                   # Navegação principal (bottom nav)
├── models/
│   ├── pokemon.dart           # Modelo de dados do pokémon
│   └── evolution.dart         # Modelo da cadeia de evolução
├── services/
│   └── poke_api_service.dart  # Integração com a PokeAPI
├── repositories/
│   └── database_repository.dart  # Acesso ao banco SQLite
├── screens/
│   ├── home_screen.dart       # Tela principal com listagem e filtros
│   ├── detail_screen.dart     # Tela de detalhes do pokémon
│   ├── favorites_screen.dart  # Tela de favoritos
│   └── history_screen.dart    # Tela de histórico
└── widgets/
    ├── pokemon_card.dart      # Card do pokémon na listagem
    ├── type_chip.dart         # Badge de tipo com cor
    ├── stat_bar.dart          # Barra de estatística
    └── evolution_chain.dart   # Cadeia de evolução visual
```

---

## 🚀 Como Rodar

**Pré-requisitos:** Flutter SDK instalado e um dispositivo Android ou emulador configurado.

```bash
# Clone o repositório
git clone https://github.com/StenioCalado/Pokedex.git

# Entre na pasta do projeto
cd Pokedex/pokedex_flutter

# Instale as dependências
flutter pub get

# Rode o app
flutter run
```

---

## 📦 Gerar APK

```bash
flutter build apk --release
```

O APK gerado estará em `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📡 API Utilizada

Este projeto utiliza a [PokéAPI](https://pokeapi.co/), uma API REST pública e gratuita com dados completos de todos os pokémons. Nenhuma autenticação é necessária.

Endpoints utilizados:
- `GET /pokemon/{id}` — dados do pokémon
- `GET /pokemon-species/{id}` — descrição e species
- `GET /evolution-chain/{id}` — cadeia de evolução
- `GET /type/{type}` — pokémons por tipo
