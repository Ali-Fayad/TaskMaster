Project TaskMaster — Technical Overview
=====================================

1. Project overview
-------------------
- Purpose: a local task manager app (TaskMaster) for creating, categorizing, prioritizing, and tracking tasks with due dates and simple statistics.
- Main features:
  - Create / edit / delete tasks
  - Categories with icon & color
  - Priorities, due dates, notifications flag
  - Task list with filters (category, status)
  - Task details view with edit/delete and mark-complete
  - Dashboard (Home) with stat cards and a pie chart of tasks by category
  - Local persistence using SQLite (sqflite)
- Architectural style: UI-driven with a clear data layer. Screens own their state and query a singleton database helper. Not strictly MVC/MVVM — more of a screens + service (DatabaseHelper) pattern.

2. Project structure (important folders & files)
------------------------------------------------
- lib/
  - main.dart — app entry, DB initialization, MaterialApp (theme + home).
  - database_helper.dart — single source of truth for all persistence (singleton), schema creation, all CRUD & statistics queries.
  - models/
    - task.dart — Task model with toMap/fromMap conversions, DateTime ↔ ISO string, bool ↔ int conversions.
    - category.dart — Category model, helper getters for Color/IconData and defaultCategories for initial seeding.
  - screens/
    - home_screen.dart — dashboard, concurrent data loading (Future.wait), pie chart (fl_chart), recent tasks.
    - task_list_screen.dart — filterable list of tasks, swipe-to-delete, uses TaskCard and AppDrawer.
    - add_task_screen.dart — add/edit form (validation, DatePicker, dropdown for categories); disposes controllers properly.
    - task_details_screen.dart — full task view, edit navigation, delete confirmation.
  - widgets/
    - app_drawer.dart — side navigation (Home, All Tasks, Add Task, About dialog).
    - task_card.dart, stats_card.dart, category_card.dart — UI building blocks used by screens.
- pubspec.yaml — dependencies include sqflite, path, fl_chart, intl, etc.
- platform folders (android/ios/macos/web) — platform integration; sqflite appears supported for desktop/mobile.

3. State management
-------------------
- Approach: Local state via StatefulWidget + setState. No external state management library (Provider/Riverpod/Bloc) is used.
- How state flows:
  - Each screen fetches its own data from DatabaseHelper in initState and holds it in private state variables (lists, counts, booleans).
  - Screens call DB operations (insert/update/delete/toggle), then call their own reload methods (_loadData) and setState to update UI.
  - Communication between screens uses Navigator (push/pop) and constructor parameters (e.g., AddTaskScreen(taskId), TaskDetailsScreen(taskId)).
- Consequence: state updates are explicit and imperative; each screen is responsible for refreshing itself after DB ops.

4. UI flow & navigation
-----------------------
- Root: main.dart initializes DB then runs TaskMasterApp which sets home to HomeScreen.
- Navigation:
  - Drawer (AppDrawer) routes to screens using Navigator.push(MaterialPageRoute(...)).
  - From lists or cards, Navigator.push to TaskDetailsScreen or AddTaskScreen, often passing taskId.
  - Confirmations and save actions use Navigator.pop with result values (booleans) where necessary.
- Typical flows:
  - Home -> Add Task (via FAB or drawer) -> save -> Navigator.pop triggers previous screen to refresh.
  - Home -> Task List -> select task -> Task Details -> edit -> returns to Task Details or pops back to list/home.
- Navigation is synchronous and simple (no named routes or deep linking).

5. Key widgets & responsibilities
---------------------------------
- AppDrawer: app-wide navigation, about dialog, links to main flows.
- StatsCard: small reusable tile for showing numeric stats on Home.
- TaskCard: list item representation of a Task (status checkbox, summary); used in recent/retrieval lists.
- CategoryCard: visual representation of a Category (used in category selection/display).
- Screens:
  - HomeScreen: aggregates stats, builds pie chart, displays recent tasks and navigation affordances.
  - TaskListScreen: provides filtering UI (DropdownButton) and Dismissible delete actions.
  - AddTaskScreen: handles both create & edit, field validation, category dropdown, date picking, and saving to DB.
  - TaskDetailsScreen: read-only detailed view with edit/delete/toggle complete actions.
- Communication: widgets pass primitive data (ids, Task objects) and rely on DB for authoritative state; screens call DB directly rather than through a controller layer.

6. Business logic & data handling
---------------------------------
- Where logic lives:
  - DatabaseHelper: all persistence logic, queries, statistics, conversions — central place for data access.
  - Screens: contain validation, filter logic, assembly of Task objects for insert/update, confirmation dialogs, and UI-side transformations (formatting dates using intl).
- Data flow:
  - User fills forms → AddTaskScreen builds Task model → calls DatabaseHelper.insertTask/updateTask → on success shows SnackBar and Navigator.pop.
  - Screens read models from DB via getAllTasks/getRecentTasks/getTasksCountByCategory/getAllCategories etc.
- Transformations:
  - Models convert DateTime ↔ ISO string and bool ↔ int for SQLite.
  - HomeScreen uses Future.wait to fetch several counts concurrently to reduce perceived load time.

7. Data & async patterns
------------------------
- Persistence: SQLite via sqflite; DatabaseHelper implements singleton pattern and _onCreate schema creation (tasks + categories) and seeds default categories.
- Models: Task & Category have toMap/fromMap which centralizes serialization concerns.
- Async handling:
  - All DB calls are async using Future and async/await.
  - Screens use patterns like setState(() => _isLoading = true); await dbCall(); setState(() => _isLoading = false).
  - HomeScreen uses Future.wait([...]) to run multiple DB queries concurrently for performance.
- No streams are used: UI updates happen after explicit refreshes following DB ops.

8. Best practices & patterns observed
------------------------------------
- Good:
  - Single DatabaseHelper singleton centralizes DB logic and prevents multiple connections.
  - Models encapsulate DB mapping (toMap/fromMap).
  - Controllers properly dispose TextEditingController in AddTaskScreen.
  - Use of ListView.builder, Dismissible, and async indicators (CircularProgressIndicator) where appropriate.
  - Uses Future.wait for concurrent DB ops.
  - Separation of UI into small widgets (cards, drawer) increases reusability.
- Pragmatic pattern: screens act as controllers (handle user interaction and talk to service layer). This is simple and effective for small apps.

9. Potential improvements
-------------------------
- Move to reactive state management:
  - Introduce Provider, Riverpod, or a ChangeNotifier/ValueNotifier-based repository so changes propagate automatically without manual reloads.
  - Alternatively, expose streams from DatabaseHelper (or use moor/Isar/Drift) to avoid manual refresh and to scale better.
- Layering & testability:
  - Introduce a repository layer (abstract interface) between screens and DatabaseHelper to make data access testable and swapable.
  - Extract business logic (filters, statistics aggregation) from widgets into controllers/services for easier unit testing.
- Error handling and resilience:
  - Add try/catch around DB operations and show meaningful error UI (SnackBar or error state) instead of assuming success.
  - Validate and guard against nulls from DB queries (defensive programming).
- Performance & UX:
  - Use const constructors where possible to reduce rebuild cost.
  - For lists with many items, consider pagination or lazy loading.
  - Cache categories in-memory to avoid repeated DB reads if they rarely change.
- Code quality & architecture:
  - Adopt named routes or a Router for complex navigation and deep links.
  - Add unit/widget tests for screens and DB helper.
  - Consider migrating to a higher-level DB package (Drift) for safer queries and compile-time checks.
- Additional improvements:
  - Add localization (intl already used for dates).
  - Add accessibility labels, semantics, and keyboard navigation for desktop.
  - Implement notification scheduling (hasNotification is a field but no platform scheduling is visible).

10. Short list of actionable next steps
--------------------------------------
- Replace manual refreshes with a simple ChangeNotifier-based repository: screens listen to repository and rebuild automatically.
- Add try/catch and show error SnackBars for DB operations.
- Add unit tests for DatabaseHelper and model conversions.
- Refactor filtering logic in TaskListScreen into a small FilterController class to keep build methods lean.
- Add simple integration tests to cover add-edit-delete flows.

Summary
-------
The codebase is a pragmatic, well-structured small Flutter app: clear separation between UI and persistence, straightforward models, and idiomatic use of async/await. It trades off reactivity for simplicity (screens manually refresh after DB operations). For maintainability and scalability, introduce a reactive/data layer (Provider/Riverpod or streams), centralize error handling, and extract business logic from widgets into services/controllers.

If you want, I can:
- Produce a short plan to migrate to Provider or Riverpod (step-by-step),
- Extract DatabaseHelper into an abstract repository and show one screen migrated as example,
- Or add error handling and unit tests for DatabaseHelper.
