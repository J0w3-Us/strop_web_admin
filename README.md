# Strop Admin Panel — Especificación y Guía Rápida

Este README describe cómo funciona el prototipo web "Strop", los flujos de usuario, los datos que utiliza, las rutas, y cómo ejecutar y probar la aplicación.

Fecha: 2025-10-21

---

## 1. Resumen del prototipo

- Tecnologías: Flutter Web, go_router, Provider (ChangeNotifier) como gestor de estado.
- Arquitectura: App shell con Sidebar persistente, Topbar, y contenido anidado usando `ShellRoute`.
- Objetivo: Prototipo de panel administrativo con dashboard dinámico, CRUD básico de proyectos (simulado) y pantalla de configuración de cuenta.

---

## 2. Flujos de usuario principales

- Login
  - Ruta: `/login`
  - Flujo: autenticación (simulada) → redirige a `/app/dashboard`.

- Navegación global
  - Sidebar y Topbar permiten navegar a Dashboard, Proyectos, Incidencias, Autorizaciones y Configuración.
  - Search (Topbar): al presionar Enter navega a `/app/projects?q=<query>`.

- Dashboard
  - Ruta: `/app/dashboard`
  - Muestra KPIs y tarjetas (Proyectos Activos, Total Proyectos, Acciones Pendientes, Avance General, Control de Costos, Incidencias, Cronograma y Avance Mensual).
  - Consume el estado desde `DashboardProvider`.
  - Si no hay datos, muestra ceros / "Sin datos".

- Proyectos
  - Lista: `/app/projects` — tabla con búsqueda, crear, abrir y eliminar.
  - Crear: `/app/projects/new` → formulario.
  - Editar: `/app/projects/:id` → carga proyecto y permite editar.
  - Acciones: ver (navegar al detalle), eliminar (actualiza repo y provider).

- Configuración de cuenta
  - Ruta: `/app/settings`
  - Formulario: validar email (envío simulado de código), cambiar contraseña (validación y confirmación).

---

## 3. Rutas (go_router)

- `/login` (LoginScreen)
- `/app/dashboard` (DashboardScreen)
- `/app/projects` (ProjectListScreen)
  - `/app/projects/new` (ProjectDetailScreen — crear)
  - `/app/projects/:id` (ProjectDetailScreen — editar)
- `/app/incidents` (placeholder)
- `/app/authorizations` (placeholder)
- `/app/settings` (AccountSettingsScreen)

---

## 4. Modelos de datos (shapes)

- Project (en `lib/domain/projects/project.dart`)
  - id: String
  - code: String
  - name: String
  - description?: String
  - status: ProjectStatus (planned, inProgress, completed, onHold)
  - startDate?: DateTime
  - endDate?: DateTime
  - members: List<String>
  - documents: List<String>

- Incident (en `lib/domain/incidents/incident.dart`)
  - id: String
  - title: String
  - description: String
  - priority: IncidentPriority (low, medium, high, critical)
  - status: IncidentStatus (open, inProgress, resolved, closed)
  - projectId?, reportedBy?, assignedTo?, createdAt?, resolvedAt?

- DashboardProvider state
  - projects: List<Project>
  - incidents: List<Incident>
  - totalBudget: double
  - totalExpenses: double
  - monthlyProgress: Map<String, double> (ej. {'Ene': 0.4})

---

## 5. Estado y persistencia (simulada)

- `DashboardProvider` (ChangeNotifier) actúa como base de datos temporal. Métodos para añadir/editar/eliminar proyectos e incidencias, registrar gastos y actualizar progreso mensual.
- `ProjectRepository` es una implementación simulada de API (metodos `Future` con delay 500ms): `getAll`, `search`, `getById`, `upsert`, `delete`.
- En el prototipo actual, `ProjectRepository` inicia vacío (sin seed) y el `DashboardProvider` se sincroniza con los resultados del repositorio.

---

## 6. Interacciones y comportamiento UI

- Sidebar: auto-hide al salir/entrar con el mouse, Drawer para pantallas pequeñas.
- Topbar: búsqueda (navega a proyectos), notificaciones (menú), cuenta (perfil/configuración/logout).
- Dashboard: widgets reactivos via `Consumer<DashboardProvider>`. Si no hay datos, mostrará ceros y mensajes "Sin datos".
- Proyectos: DataTable con scroll horizontal. Crear/Editar via formulario con validación (código y nombre requeridos, fechas opcionales).
- Configuración: validar email (regex) y cambiar contraseña (min 8 chars + match).

---

## 7. Validaciones y mensajes

- Validaciones principales implementadas:
  - Email: regex básico.
  - Campos de proyecto: `code` y `name` requeridos.
  - Password: mínimo 8 caracteres + confirmación igual.
- UX: Snackbars para éxito/errores, `CircularProgressIndicator` para operaciones asíncronas.

---

## 8. Cómo ejecutar y probar (Windows / pwsh)

1. Obtener dependencias:
```powershell
flutter pub get
```

2. Analizar código:
```powershell
flutter analyze
```

3. Tests (unitarios existentes):
```powershell
flutter test
```

4. Ejecutar en navegador Edge:
```powershell
flutter run -d edge
```

Notas: el proyecto está configurado para Flutter Web y se probó en Edge durante el desarrollo.

---

## 9. Archivos clave

- `lib/main.dart` — inicializa `MultiProvider` y arranca la app.
- `lib/app.dart` — `MaterialApp.router` con `AppRouter`.
- `lib/core/routes/app_router.dart` — rutas y `ShellRoute`.
- `lib/core/providers/dashboard_provider.dart` — gestor de estado principal.
- `lib/domain/projects/project.dart` — modelo Project.
- `lib/domain/projects/project_repository.dart` — repositorio simulado (API fake).
- `lib/domain/incidents/incident.dart` — modelo Incident.
- `lib/feactures/layout/screens/main_layout_screen.dart` — app shell (sidebar/topbar/breadcrumbs).
- `lib/feactures/dashboard/screens/dashboard_screen.dart` — pantalla principal del dashboard.
- `lib/feactures/projects/screens/project_list_screen.dart` — lista de proyectos.
- `lib/feactures/projects/screens/project_detail_screen.dart` — formulario de proyecto.
- `lib/feactures/settings/screens/account_settings_screen.dart` — pantalla de configuración de cuenta.

---

## 10. Advertencias actuales y mejoras sugeridas

- Advertencias del analyzer (no bloqueantes):
  - `use_build_context_synchronously` en algunos lugares con `await` antes de usar `context`.
  - campos que pueden ser `final` en `DashboardProvider`.

- Mejoras recomendadas (prioridad):
  1. Corregir las advertencias de analyzer (usar `mounted` y marcar `final`).
  2. Añadir tests widget (flujo: login → dashboard → crear proyecto → verificar KPI).
  3. Añadir persistencia real (back-end o local) con abstracción `IProjectRepository`.
  4. Implementar autenticación real y controles de acceso.

---


## 12. Datos que utiliza la lógica integrada

La aplicación calcula varios KPIs y comportamientos a partir de los modelos principales (`Project` e `Incident`) y datos agregados (presupuestos/gastos, progreso mensual). A continuación se describen los campos utilizados por la lógica y cómo se interpretan para las tarjetas del dashboard.

- Campos de `Project` usados por la lógica:
  - `id` (String): identificador único. Usado para relacionar incidencias y operaciones CRUD.
  - `code` (String): código legible del proyecto. Mostrado en listas y usado en búsquedas.
  - `name` (String): nombre para mostrar.
  - `status` (String / enum): controla conteos de proyectos activos vs completados. Ej.: `inProgress` = activo.
  - `startDate` / `endDate` (DateTime): estimaciones de cronograma. Se usan para calcular porcentaje de avance temporal (cronograma) comparando fechas actuales y duración total.
  - `members` (List<String>): recuento de participantes; puede influir en estimaciones y filtrado.
  - `budget` (double) — opcional: presupuesto asignado al proyecto. Si está presente, se suma al `totalBudget`.
  - `expenses` (double) — opcional: gastos consumidos. Se suma a `totalExpenses`.

- Campos de `Incident` usados por la lógica:
  - `id`, `projectId`: relación con proyecto.
  - `priority`: determina si se cuenta como crítica/alta para la tarjeta de incidencias.
  - `status`: `open`/`inProgress` cuentan como incidencias abiertas.

- Datos agregados / Derived fields en `DashboardProvider`:
  - `activeProjectsCount`: número de proyectos con `status == inProgress`.
  - `totalProjectsCount`: longitud de la lista de proyectos.
  - `openIncidentsCount`: número de incidencias con `status` abierto o en progreso.
  - `generalProgress`: promedio ponderado de progreso por proyecto (si los proyectos contienen `progress` ó a partir de milestones). Si no hay valores, se muestra 0.
  - `budgetUsagePercentage`: (totalExpenses / totalBudget) * 100 si `totalBudget > 0`, de lo contrario se muestra 0.
  - `monthlyProgress`: Map<String,double> donde cada clave es una etiqueta de mes y el valor es porcentaje 0..1. Se utiliza para renderizar la tarjeta de Avance Mensual; si está vacío se muestra "Sin datos" o ceros.

Cómo se calculan (resumen):
- Para el control de costos: sumar `budget` y `expenses` de todos los proyectos visibles. Mostrar porcentaje y una tarjeta de advertencia si `expenses > budget`.
- Para cronograma: si `startDate` y `endDate` existen, calcular (now - start) / (end - start) y limitar a 0..1.
- Para KPIs de conteo: filtrar por `status` y `priority` según corresponda.

---

## 13. Pasos para integrar una API REST y mapping de endpoints

Abajo están los pasos detallados y los esquemas JSON recomendados para sustituir el `ProjectRepository` simulado por una implementación real que consuma una API REST.

1) Definir endpoints API

- Autenticación (opcional, JWT)
  - POST /api/auth/login
    - Request: { "username": "string", "password": "string" }
    - Response: { "token": "string", "user": { "id":"", "email":"" } }

- Proyectos
  - GET /api/projects
    - Query params opcionales: `q`, `page`, `pageSize`
    - Response: { "items": [Project], "total": number }
  - GET /api/projects/:id
    - Response: Project
  - POST /api/projects
    - Request: Project (sin `id`)
    - Response: Project (creado con `id`)
  - PUT /api/projects/:id
    - Request: Project
    - Response: Project (actualizado)
  - DELETE /api/projects/:id
    - Response: { "ok": true }

- Incidencias (ejemplo)
  - GET /api/incidents?projectId=:projectId
  - POST /api/incidents
  - PUT /api/incidents/:id
  - DELETE /api/incidents/:id

2) Esquema JSON mínimo para `Project` (ejemplo)

```
{
  "id": "string",
  "code": "PROJ-001",
  "name": "Proyecto ejemplo",
  "description": "...",
  "status": "inProgress",
  "startDate": "2025-10-01T00:00:00Z",
  "endDate": "2026-03-01T00:00:00Z",
  "members": ["user1","user2"],
  "documents": ["/files/doc1.pdf"],
  "budget": 100000.0,
  "expenses": 25000.0,
  "progress": 0.25
}
```

3) Implementar cliente HTTP en Flutter

- Recomendado: usar `http` o `dio`. Crear una nueva implementación `RemoteProjectRepository implements ProjectRepository` (o mejor: extraer una interfaz `IProjectRepository`) en `lib/infrastructure/`.

Ejemplo (pseudocódigo Dart usando `http`):

```dart
final resp = await http.get(Uri.parse('$baseUrl/api/projects?q=$q'));
if (resp.statusCode == 200) {
  final map = jsonDecode(resp.body) as Map<String,dynamic>;
  final items = (map['items'] as List).map((e) => Project.fromMap(e)).toList();
  return items;
}
throw Exception('API error');
```

4) Pasos para reemplazar `ProjectRepository` simulado por `RemoteProjectRepository`

- Crear `lib/infrastructure/projects/remote_project_repository.dart` con la implementación HTTP.
- Extraer o adaptar una interfaz `IProjectRepository` (definir contratos: `Future<List<Project>> getAll()`, `search(q)`, `getById(id)`, `upsert(project)`, `delete(id)`).
- Actualizar el `DashboardProvider` y/o `main.dart` para inyectar la implementación remota en lugar de la simulada. Ejemplo usando Provider:

```dart
final repo = RemoteProjectRepository(baseUrl: env.apiUrl, client: http.Client());
runApp(MultiProvider(providers: [
  Provider<IProjectRepository>.value(value: repo),
  ChangeNotifierProvider(create: (_) => DashboardProvider(repo)),
]));
```

5) Manejo de autentificación (opcional)

- Si la API requiere token, almacenar el JWT seguro (ej. secure_storage) y adjuntarlo en cada petición.
- Añadir un `AuthInterceptor` si usas `dio` o adjuntar header `Authorization: Bearer <token>` en `http`.

6) Migración incremental

- Mantén la `ProjectRepository` simulada y añade la remota primero como opción. Añade una bandera en `main.dart` o una variable de entorno `USE_REMOTE_API=true` para alternar.
- Escribe tests de integración que apunten a un servidor mock (msw, mockoon) o usa respuestas mock en `http` para validar la UI antes de apuntar a producción.

7) Errores y estado de red en UI

- Implementa correctamente estados de carga/empty/error en las pantallas (`FutureBuilder`, `AsyncValue`, `ChangeNotifier` con estados) para evitar que la UI use datos null.
- Añade reintentos o mensajes de error claros en snackbar.

---

## 14. Ejemplo de integración rápida (resumen)

1. Crear `RemoteProjectRepository` con `getAll/getById/upsert/delete`.
2. Añadir `Provider<IProjectRepository>` en `main.dart` y actualizar `DashboardProvider` para usar la instancia inyectada.
3. Probar `flutter run` y verificar que la lista de proyectos la carga desde la API.
4. Añadir autenticación si la API la requiere y asegurar el almacenamiento del token.

---

Si quieres, puedo generar la plantilla de `RemoteProjectRepository` y los cambios de `main.dart` para que la conexión sea plug-and-play con variables de entorno (por ejemplo `--dart-define=API_URL=https://api.tuempresa.com`).
Si quieres que haga el commit del README o que siga con las advertencias/test, dime cuál prefieres que haga a continuación.
# strop_admin_panel

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# web-strop
# web-strop
