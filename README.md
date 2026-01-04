# TaskMaster

A task management application built with Flutter — the final university project. TaskMaster helps create, organize and track tasks with a local SQLite store and simple charts to visualize task status.

---

[Repository on GitHub](https://github.com/Ali-Fayad/TaskMaster) • Note: I inspected pubspec.yaml, README.md and the top-level layout to prepare this README. The file listing from the inspection may be incomplete — view the repo or run a code search on GitHub to explore all files.

---

## Quick summary

- Primary framework: Flutter (Dart)
- Key packages: fl_chart, sqflite, intl, path
- Purpose: Local task management app with visualization (pie/bar charts) and local SQLite persistence
- Platforms: Android, iOS, Web, Desktop targets (project contains platform folders)

---

## Visual concepts

These diagrams give a clear, fast overview of the app structure, UI flows, and runtime components.

1) High-level architecture (components and data flow)

+----------------+        +-----------------+        +----------------+
|   User UI      | <----> |  Flutter App    | <----> | Local Storage  |
| (Widgets in    |        | (Dart code in   |        | (SQLite via    |
|  lib/)         |        |  lib/*)         |        |  sqflite)      |
+----------------+        +-----------------+        +----------------+
          ^                        |
          |                        v
     Input/Events             Visualizations
                              (fl_chart & intl)

Explanation:
- The UI (screens & widgets) triggers CRUD operations.
- The app layer implements models, services and database helpers.
- Storage layer persists tasks; charts are computed from stored data.

2) UI flow (typical user journeys)

[Create Task]
   |
   v
[Task Form Screen] --(save)--> [DB: tasks table]
   |
   v
[Task List Screen] --(select)--> [Task Details Screen]
   |
   v
[Dashboard Screen] --(computes)--> [Charts: fl_chart]

3) Local data model (conceptual)
- tasks
  - id (int, PK)
  - title (text)
  - description (text)
  - due_date (datetime)
  - status (text) — e.g., pending / done / in-progress
  - priority (int)
  - created_at (datetime)
  - updated_at (datetime)

This is a conceptual schema—refer to the DB helper in lib/ for the actual implementation.

4) Folder structure (top-level example)
- android/        — Android native project files
- ios/            — iOS native project files
- lib/            — Dart source (main app code)
  - main.dart     — app entrypoint (typical)
  - screens/
  - widgets/
  - models/
  - services/
  - db/
- web/            — web target files (optional)
- macos/, linux/, windows/ — desktop embedding projects
- pubspec.yaml    — dependencies & project metadata
- pubspec.lock
- README.md
- .gitignore

---

## Languages & technologies used

- Dart / Flutter — Primary app language and UI framework (~69% of repo).
- C++ / CMake / C — Present due to Flutter engine and/or native plugin/build tooling (~28% combined).
- Swift — iOS platform files, small portion.
- HTML — Web build artifacts or web entry files.
- SQLite — Persistent local database (via sqflite package).

In short: you develop and extend the app mainly in Dart. Native code exists for platform support and is managed by Flutter.

---

## Running the app with Docker

Below are two practical Docker-based approaches: (A) quick development run (web), and (B) production-style web build served by nginx. These let you run the app without installing Flutter locally.

A) Quick development run (web-server, hot reload is limited in container):
```bash
docker run --rm -it -v "$PWD":/app -w /app cirrusci/flutter:stable bash -lc "\
  flutter pub get && \
  flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080"
```
Open: http://localhost:8080

Notes:
- To run on Android/emulators inside Docker you need appropriate Android SDK setup (and possibly privileged containers). For local device development, running Flutter locally is easier.

B) Two-stage Dockerfile: build web and serve with nginx

Dockerfile.build-and-serve:
```dockerfile
FROM cirrusci/flutter:stable AS builder
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

FROM nginx:stable-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Build and run:
```bash
docker build -f Dockerfile.build-and-serve -t taskmaster-web .
docker run --rm -p 8080:80 taskmaster-web
```
Open: http://localhost:8080

C) docker-compose (optional)
```yaml
version: "3.8"
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.build-and-serve
    ports:
      - "8080:80"
```
Then: docker compose up --build

---

## How to explore & develop locally

1. Clone and open:
   - git clone https://github.com/Ali-Fayad/TaskMaster.git
   - cd TaskMaster

2. Fetch packages:
   - flutter pub get

3. Run:
   - flutter run (choose device or simulator) or use the Docker commands above for web builds.

4. Inspect main entry:
   - Look for lib/main.dart — it is typically the entrypoint and where routes/screens are registered.

5. Database and charts:
   - Search for `sqflite` usage and `fl_chart` imports to find where DB and charts are implemented.

---

## Screenshots & assets (placeholder)

You can add screenshots to improve the README visual appeal. Place images in an `assets/screenshots/` directory and add these lines under `flutter:` in pubspec.yaml:

```yaml
flutter:
  assets:
    - assets/screenshots/home.png
    - assets/screenshots/dashboard.png
```

Then embed images in the README:
```markdown
![Home screen](assets/screenshots/home.png)
![Dashboard](assets/screenshots/dashboard.png)
```

---

## Developer tips & next steps

- Start by reading the `lib/` folder — that shows the app logic.
- If you want a CI pipeline to build web or Android artifacts, I can provide a GitHub Actions workflow (or GitLab CI) that uses the same Docker build flow.
- If you'd like, I can:
  - create a CONTRIBUTING.md and ISSUE_TEMPLATE.md,
  - generate a sample Dockerfile to build Android APKs in CI (requires keystore handling),
  - or add diagrams in SVG/PNG for the README.

---

## Acknowledgements & license

- Built with Flutter and community packages (fl_chart, sqflite, intl).
- This README is based on repository inspection (pubspec.yaml, README.md and top-level structure). For full details, inspect the repository on GitHub: https://github.com/Ali-Fayad/TaskMaster

---

If you'd like, I can now:
- Add generated mermaid diagrams (rendered on GitHub),
- Create a CONTRIBUTING.md,
- Or produce a ready-to-copy Dockerfile and GitHub Actions workflow tailored for Android or web releases. Which would you prefer next?
