# 🦖 Plan de Implementación: Spideysaurus (Tienda de Juguetes de Dinosaurios)
> **Stack:** Flutter + Dart | Firebase (Auth + Firestore) | Provider | VS Code / Android Studio  
> **Objetivo:** Documento de planificación paso a paso para el desarrollo completo. **Sin código**, solo arquitectura, flujo, herramientas y procedimientos.

---

## 📦 Fase 1: Configuración del Entorno de Desarrollo
1. **Instalar SDKs y Herramientas Base**
   - Flutter SDK (última versión estable)
   - Dart SDK (incluido con Flutter)
   - Git (control de versiones)
   - *Nota:* "Antigravity" no es un IDE reconocido. Se asume **Android Studio** o **VS Code** como entornos válidos.
2. **Configurar IDE**
   - VS Code: Instalar extensiones `Flutter`, `Dart`, `Firebase`, `Error Lens`, `Pubspec Assist`
   - Android Studio: Instalar plugins `Flutter` y `Dart` desde Marketplace
   - Configurar formateador automático (`dart format`) y linter (`flutter_lints`)
3. **Verificar Instalación**
   - Ejecutar `flutter doctor` hasta obtener `✓` en todas las plataformas objetivo
   - Configurar emuladores (Android/iOS) o conectar dispositivos físicos con depuración USB/Wi-Fi habilitada
4. **Inicializar Proyecto**
   - `flutter create spideysaurus --org com.tuempresa.spideysaurus`
   - Abrir proyecto en el IDE seleccionado y verificar estructura base

---

## 🏗️ Fase 2: Arquitectura y Estructura del Proyecto
1. **Patrón de Arquitectura**
   - `Feature-first` + `MVVM` ligero con `Provider`
   - Separación estricta entre UI, lógica de presentación, datos y servicios
2. **Estructura de Carpetas (`lib/`)**
   ```
   lib/
   ├── core/             # Constantes, temas, rutas, utilidades, errores
   ├── features/
   │   ├── auth/         # Registro, login, recuperación, validación
   │   ├── catalog/      # Listado, búsqueda, filtros, detalle de productos
   │   ├── cart/         # Carrito, cantidades, totales
   │   ├── orders/       # Historial, seguimiento, checkout
   │   └── profile/      # Datos usuario, direcciones, preferencias
   ├── services/         # Firebase wrappers, API helpers, storage local
   ├── models/           # Clases Dart inmutables/serializables
   ├── providers/        # ChangeNotifiers por funcionalidad
   ├── widgets/          # Componentes reutilizables globales
   └── main.dart         # Punto de entrada, configuración multi-provider
   ```

---

## 🎨 Fase 3: Diseño UI/UX
1. **Herramientas de Diseño**
   - Figma, Penpot o Adobe XD para wireframes y prototipos interactivos
   - Exportar assets en `SVG` y `PNG` (2x, 3x) optimizados
2. **Sistema de Diseño**
   - **Paleta:** Verde bosque, naranja terracota, azul cielo, blanco hueso, gris oscuro para texto
   - **Tipografía:** `Poppins` o `Nunito` (amigable, legible en móvil y tablet)
   - **Espaciado:** Sistema de 8pt para márgenes y paddings consistentes
   - **Componentes Base:** Cards de producto, botones primarios/secundarios, badges de stock, bottom navigation, app bar temático, dialogs de confirmación
3. **Principios UX**
   - Flujo mínimo de clics hasta el carrito
   - Estados de carga (`shimmer`), vacíos y error claramente diferenciados
   - Accesibilidad: contraste ≥ 4.5:1, tamaños de texto escalables, etiquetas semánticas
   - Diseño responsive: breakpoints para móvil (≤600px), tablet (601–900px), web (>900px)

---

## 🔥 Fase 4: Configuración de Firebase
1. **Crear Proyecto en Firebase Console**
   - Nombre: `spideysaurus`
   - Habilitar Google Analytics (opcional pero recomendado para métricas)
2. **Registrar Plataformas**
   - Android: registrar `applicationId`, descargar `google-services.json`
   - iOS: registrar `Bundle ID`, descargar `GoogleService-Info.plist`
   - Web: registrar dominio/local, obtener config JS
3. **Activar Servicios**
   - **Authentication:** Habilitar método `Email/Password`, habilitar verificación por correo
   - **Firestore Database:** Crear base en modo prueba → migrar a reglas personalizadas en producción
   - **Storage** (opcional futuro): para imágenes de productos administradas
4. **CLI y Emuladores**
   - Instalar Firebase CLI: `npm install -g firebase-tools`
   - Ejecutar `firebase login` y `firebase init` (seleccionar Auth, Firestore, Emulators)
   - Configurar emuladores locales para desarrollo seguro y rápido

---

## 📦 Fase 5: Gestión de Dependencias (`pubspec.yaml`)
> *Listar solo paquetes esenciales. Mantener versiones estables y compatibles.*
- **Core Firebase:** `firebase_core`, `firebase_auth`, `cloud_firestore`
- **Estado:** `provider`
- **UI/Assets:** `google_fonts`, `flutter_svg`, `cached_network_image`
- **Utilidades:** `intl` (formato moneda/fecha), `uuid` (IDs locales), `shared_preferences` (config local), `flutter_form_builder` + `formz` (validación)
- **Dev/Testing:** `flutter_lints`, `mocktail`, `flutter_test`
- **Notas de gestión:**
  - Ejecutar `flutter pub get` tras cada edición
  - Usar `pubspec.lock` en control de versiones
  - Revisar compatibilidad con `flutter doctor` y Dart SDK actual

---

## 🔐 Fase 6: Autenticación (Email/Password)
1. **Flujo de Usuario**
   - Pantalla de bienvenida → Login / Registro → Verificación de correo → Acceso a catálogo
2. **Manejo de Sesión**
   - Persistencia automática vía Firebase
   - Listener global de estado de auth para redirección dinámica
3. **Validación y Seguridad**
   - Validación en UI: formato email, longitud/contraseña segura, coincidencia de campos
   - Manejo de errores: credenciales inválidas, email ya registrado, usuario deshabilitado, timeouts de red
   - Límites de reintento y bloqueo temporal tras intentos fallidos
4. **Protección de Rutas**
   - Wrapper global que verifique `currentUser != null` antes de renderizar pantallas protegidas
   - Redirección a login con retorno de ruta original

---

## 🗄️ Fase 7: Base de Datos Firestore
1. **Modelo de Datos**
   - `users/{uid}`: nombre, email, direcciones[], historialCompras[], preferencias
   - `products/{id}`: nombre, descripción, precio, categoría, stock, imagenURL, destacado(bool), createdAt
   - `orders/{id}`: userId, items[], total, estado(pendiente/enviado/entregado), createdAt, direcciónEnvío
2. **Consultas y Rendimiento**
   - Listado paginado (`limit` + `startAfterDocument`)
   - Índices compuestos para filtros combinados (categoría + precio + disponibilidad)
   - Cache local implícito de Firestore + refresco en foreground
3. **Reglas de Seguridad (Firestore)**
   - `products`: lectura pública, escritura solo desde Cloud Functions o panel admin
   - `users`: lectura/escritura solo por el propietario (`request.auth.uid == resource.id`)
   - `orders`: solo el creador puede leer/escribir sus pedidos
   - Validar tipos, rangos y límites de campos en reglas

---

## 🔄 Fase 8: Gestión de Estado (Provider)
1. **Arquitectura de Providers**
   - `AuthProvider`: estado de sesión, métodos login/register/logout, usuario actual
   - `ProductProvider`: catálogo, búsqueda, filtros, estado de carga, paginación
   - `CartProvider`: items, cantidades, totales, persistencia local temporal
   - `OrderProvider`: creación, historial, estados de pedido
2. **Buenas Prácticas**
   - Un `ChangeNotifier` por dominio funcional
   - `select` o `Consumer` específicos para evitar rebuilds innecesarios
   - `MultiProvider` en `main.dart` como raíz
   - Separar lógica de negocio de la UI: los providers exponen métodos, no widgets
3. **Sincronización con Firebase**
   - Streams (`StreamProvider` o `FutureBuilder` envuelto) para datos en tiempo real
   - Actualización optimista en carrito/órdenes con rollback en error

---

## 🧭 Fase 9: Integración y Flujos de Usuario
1. **Navegación**
   - Rutas nombradas con mapa centralizado (`/`, `/login`, `/catalog`, `/product/:id`, `/cart`, `/profile`)
   - Transiciones suaves y navegación profunda (deep links) preparada
2. **Flujos Críticos**
   - **Catálogo:** carga inicial → shimmer → grid/list → pull-to-refresh → paginación infinita
   - **Detalle Producto:** imágenes carousel, selector cantidad, botón agregar, recomendaciones
   - **Carrito:** edición en línea, cálculo automático, botón checkout, validación stock
   - **Checkout:** resumen, dirección, método de pago (mock inicial), confirmación, redirección a historial
3. **Manejo de Estados Globales**
   - Loading overlays, snackbars para feedback, dialogs para acciones destructivas
   - Estrategia offline básica: mostrar datos cacheados, marcar acciones pendientes

---

## 🧪 Fase 10: Pruebas, Optimización y Despliegue
1. **Estrategia de Testing**
   - Unit tests: providers, validadores, modelos
   - Widget tests: componentes UI, flujos de auth, navegación básica
   - Integration tests: flujo completo registro → catálogo → carrito → orden (con emuladores Firebase)
2. **Optimización**
   - Compresión de imágenes (WebP), lazy loading, `const` donde sea posible
   - Minimizar rebuilds con `Provider.of(context, listen: false)` y `select`
   - Habilitar `dart compile` y tree-shaking en builds de release
3. **Generación y Despliegue**
   - `flutter build appbundle` (Android), `flutter build ipa` (iOS), `flutter build web` (Web)
   - Firmar releases con keystores certificados
   - Subir a Play Console, App Store Connect, Firebase Hosting
   - Configurar canales de rollout: alpha → beta → producción

---

## ✅ Checklist de Validación Pre-Lanzamiento
- [ ] `flutter doctor` sin advertencias críticas
- [ ] Firebase Auth con email/password funcional y verificación activa
- [ ] Firestore con reglas de seguridad aplicadas y validadas
- [ ] Providers separados, sin rebuilds en cascada
- [ ] UI responsive en móvil/tablet/web
- [ ] Manejo de errores de red y estados vacíos cubierto
- [ ] Pruebas unitarias y de widget ejecutadas con cobertura ≥70%
- [ ] Builds de release generados sin warnings de dependencias
- [ ] Documentación interna de arquitectura y flujo de datos actualizada

---

## 📌 Notas y Recomendaciones Finales
- Utilizar variables de entorno (`.env`) para configuraciones sensibles o URLs de API externas.
- Mantener commits atómicos con mensajes claros (`feat:`, `fix:`, `refactor:`, `chore:`).
- Considerar migrar a `riverpod` o `bloc` si la aplicación escala a equipos grandes, pero `provider` es óptimo para este alcance.
- Documentar las reglas de Firestore y los índices compuestos en un archivo `FIRESTORE_RULES.md`.
- Planificar una fase 2: pasarela de pago real (Stripe/MercadoPago), panel admin web, notificaciones push (FCM).

---
🦖 *Este plan está listo para ser ejecutado paso a paso. Cuando confirmes que deseas avanzar a la siguiente fase (ej: estructura de archivos detallada, wireframes, o configuración inicial de `main.dart`), te guiaré con instrucciones específicas sin saltar a implementación de código prematura.*
