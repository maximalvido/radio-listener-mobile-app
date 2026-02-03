# RadioWave

Flutter app to browse and stream radio stations from the [Radio Browser API](https://api.radio-browser.info/). Includes favorites, search, filters, mini player, full-screen player with wave animation, vote up, and share. Built with **Clean Architecture** and **BLoC**.

---

## Features

- **All Stations** 
  - Infinite scroll
  - Search (Debounced)
  - Filters (Top Votes, Top Clicks, Recent Clicks)
  - Staggered list animation
  - Empty state
- **Favorites**
  - Save stations locally (SharedPreferences)
- **Player** 
  - Full-screen player with artwork placeholder, station info (name, genre, country, bitrate), live indicator, animated wave chart (particle effect tied to playback and bitrate)
  - Volume slider control, and mute/unmute.
  - Play/pause
  - List navigation, Prev/next station
  - Slide-down to dismiss
- **Mini player** 
  - Bar at the bottom when something is playing, tap to open full player
- **Vote up** 
  - Vote for a station via the API, voted state persisted locally.
- **Share**
  - Share current station (text + stream URL) via the system (share_plus).

---

## Quick setup

1. **Clone** the repo and open the project.
2. **Environment** – Copy `.env.example` to `.env` and set `API_BASE_URL` (default: `https://de1.api.radio-browser.info`).
3. **Run:**

```bash
flutter pub get
flutter run
```

No API keys required. Android/iOS network config is already set for HTTP.

---

## Architecture

The project follows **Clean Architecture**: domain at the centre, data and presentation depend on it.

```
lib/
├── main.dart                  # DI: datasources → repos → use cases → blocs
├── app.dart                   
├── core/
│   └── theme/                 # Theme constats
├── components/                # Reusable UI
├── domain/                    # Business rules
│   ├── entities/              
│   ├── repositories/          
│   └── usecases/
│       ├── favorites/         
│       ├── playback/          
│       ├── stations/          
│       └── vote/              
├── data/                      # Implementations
│   ├── datasources/
│   │   ├── local/             # Favorites (SharedPreferences), UserStations (JSON)
│   │   └── remote/            # StationsRemoteDataSource (HTTP, Radio Browser API)
│   ├── models/                # StationModel (JSON ↔ Entity)
│   └── repositories/          # *Impl for each domain repository (JustAudio for playback)
└── features/
    ├── splash/                
    ├── stations/              
    ├── favorites/             
    └── player/                
```

- **Domain**: Entities and repository interfaces only. No imports from `data` or `flutter`.
- **Data**: Implements repositories, contains HTTP, persistence, and JustAudio. Abstract datasources + impl classes.
- **Presentation**: BLoC + views. Blocs depend on use cases (and playback repo for streams), views use `BlocBuilder` / `context.read<>()`. Theme constants live in `core/theme`.

---

## Guidelines

- **New feature** → New folder under `features/` with bloc + events + state + view. Register bloc and dependencies in `main.dart`.
- **New API or persistence** → New datasource in `data/datasources/` (abstract + impl). Keep repository interfaces in domain; implementations in `data/repositories/`.
- **New app action** → New use case in `domain/usecases/` that calls a repository.
- **Reusable UI** → `lib/components/` or `core/theme/`. Keep views thin, no business logic in widgets.
- **State** → Use BLoC for screen/feature state. Repositories expose streams where the UI must react.
- **Naming** → `*_bloc.dart`, `*_event.dart`, `*_state.dart`, `*_view.dart` for features. Repositories: `FooRepository` (domain), `FooRepositoryImpl` (data). Datasources: `BarDataSource` (abstract), `BarDataSourceImpl` (data).
