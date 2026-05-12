# 🦖 Plan de Implementación: Spideysaurus (Tienda de Mercancía Jurassic Park)
**Framework:** Flutter | **Backend:** Firebase (Auth, Firestore, Storage) | **Estado:** Provider  
**Plataformas:** Android, iOS, Web, Windows

---

## 1. 🛠 Herramientas y Entorno de Desarrollo
| Herramienta | Propósito |
|-------------|-----------|
| Flutter SDK & Dart | Motor de desarrollo multiplataforma |
| Android Studio / VS Code | IDE con extensiones oficiales de Flutter/Dart |
| Firebase CLI & Console | Gestión de Auth, Firestore, Storage y reglas de seguridad |
| Firebase Emulator Suite | Pruebas locales seguras antes de desplegar |
| Figma / Adobe XD | Diseño de wireframes y prototipos de UI/UX |
| Git & GitHub | Control de versiones y colaboración |
| DevTools (Flutter) | Depuración de rendimiento, red y estado |

---

## 2. 🏗 Arquitectura y Gestión de Estado
- **Patrón recomendado:** Arquitectura por capas separadas (`Data` ↔ `Domain/Logic` ↔ `Presentation`)
- **State Management:** `provider` como contenedor global de estado reactivo
- **Flujo de datos:** 
  1. La capa de presentación escucha cambios en los `Providers`
  2. Los `Providers` interactúan con repositorios abstractos
  3. Los repositorios comunican con Firebase (Firestore/Auth/Storage)
- **Manejo de rutas:** Navegación declarativa con protección de rutas según estado de autenticación y rol de usuario

---

## 3. 🎨 UI/UX y Guía de Estilo Temático
| Elemento | Especificación |
|----------|----------------|
| Fondo principal | Negro sólido (`#000000` o `#121212` para modo oscuro suave) |
| Botones / CTA | Amarillo dorado (`#FFD700` o `#F5C518`) con texto negro para contraste |
| Headers / Bordes de formularios / Alertas | Rojo temático (`#B71C1C` o `#D32F2F`) |
| Tipografía | Sans-serif moderna, alta legibilidad, pesos bold para títulos |
| Componentes reutilizables | Tarjetas de producto (`ProductCard`), `CustomAppBar`, `FormContainer`, `LoadingSkeleton` |
| Experiencia de usuario | Navegación inferior o lateral, transiciones suaves, estados de carga y error visuales, accesibilidad WCAG básica |

---

## 4. 🔥 Firebase y Estructura de Datos
- **Authentication:** Registro e inicio de sesión con email/password. Almacenamiento de metadatos básicos en Firestore.
- **Firestore Collections:**
  - `users`: `{ uid, email, displayName, role: 'user' | 'admin', createdAt }`
  - `products`: `{ documentId (auto), nombre, marca, precio, categoria, descripcion, imageUrl, stock, createdAt }`
  - *Nota:* En lugar de crear "tablas" separadas por categoría, se recomienda una única colección `products` con un campo `categoria` para filtrar dinámicamente. Esto optimiza consultas, seguridad y mantenimiento.
- **Firebase Storage:** Almacenamiento de imágenes de productos y logos. URLs públicas o firmadas según reglas de seguridad.
- **Reglas de seguridad:** 
  - Lectura de productos: pública
  - Escritura/Edición/Eliminación: solo `role == 'admin'`
  - Lectura de usuarios: solo `role == 'admin'`
  - Escritura de perfil propio: solo el propietario del `uid`

---

## 5. 📦 Dependencias Requeridas (Concepto para `pubspec.yaml`)
| Categoría | Paquete | Función |
|-----------|---------|---------|
| Core | `flutter`, `provider` | Framework y gestión de estado |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` | Backend completo |
| Navegación | `go_router` o `auto_route` | Enrutamiento declarativo y protegido |
| Imágenes | `cached_network_image`, `image_picker` | Carga optimizada y selección para admin |
| Utilidades | `intl`, `uuid`, `shared_preferences` | Formatos de moneda/fechas, IDs únicos, persistencia ligera |
| Formularios/Validación | `formz` o validadores nativos + `flutter_form_builder` (opcional) | Validación robusta |
| Dev | `flutter_lints`, `mockito` | Linting avanzado y pruebas unitarias |

---
# 📦 Estructura de Colecciones para Firebase Firestore
*(Nota técnica: Firestore utiliza **colecciones y documentos** en lugar de tablas SQL. A continuación se mapea tu requerimiento al modelo nativo de Firestore, manteniendo los campos solicitados y añadiendo notas de implementación para seguridad y escalabilidad.)*

---

## 🧸 Colección: `juguetes`
| Campo | Tipo de Dato | Descripción / Notas |
|-------|--------------|---------------------|
| `documentId` | String (Auto-generado por Firestore) | Identificador interno del documento. No requiere asignación manual. |
| `nombre` | String | Nombre comercial del juguete. |
| `marca` | String | Fabricante o franquicia asociada. |
| `precio` | Number (Double) | Precio en moneda local (ej. `149.90`). Se formateará en la UI con `intl`. |
| `imagen` | String | URL pública o firmada desde Firebase Storage. |

---

## 🗿 Colección: `estatuas`
| Campo | Tipo de Dato | Descripción / Notas |
|-------|--------------|---------------------|
| `documentId` | String (Auto-generado) | ID interno del documento. |
| `nombre` | String | Nombre descriptivo de la estatua. |
| `marca` | String | Estudio o fabricante. |
| `precio` | Number (Double) | Valor monetario. |
| `imagen` | String | URL de la imagen principal en Storage. |

---

## 👕 Colección: `ropa`
| Campo | Tipo de Dato | Descripción / Notas |
|-------|--------------|---------------------|
| `documentId` | String (Auto-generado) | ID interno del documento. |
| `nombre` | String | Nombre de la prenda (ej. "Camiseta T-Rex Vintage"). |
| `marca` | String | Marca o diseñador. |
| `precio` | Number (Double) | Precio de venta. |
| `imagen` | String | URL de la imagen en Storage. |
| `talla_disponible` | List<String> | Ej. `["S", "M", "L", "XL"]`. |

---

## 🎁 Colección: `promocionales`
| Campo | Tipo de Dato | Descripción / Notas |
|-------|--------------|---------------------|
| `documentId` | String (Auto-generado) | ID interno del documento. |
| `nombre` | String | Nombre del artículo promocional. |
| `marca` | String | Marca o colección asociada. |
| `precio` | Number (Double) | Precio con descuento aplicado. |
| `imagen` | String | URL en Firebase Storage. |

---

## 👤 Colección: `usuarios`
| Campo | Tipo de Dato | Descripción / Notas |
|-------|--------------|---------------------|
| `uid` | String (Clave del documento) | **Se obtiene directamente de Firebase Authentication**. No se recomienda usar un ID manual. |
| `nombre_usuario` | String | Nombre visible en la app. |
| `email` | String | Correo electrónico usado para el login. |
| `contraseña_encriptada` | ❌ *No almacenar en Firestore* | ⚠️ **Nota de seguridad crítica** (ver abajo). |
| `rol` | String | `"user"` o `"admin"`. Determina acceso a rutas administrativas. |

---

## 6. 📁 Estructura de Carpetas del Proyecto
```
lib/
├── main.dart
├── config/
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/ (colores, strings, rutas de assets)
│   ├── utils/ (validadores, helpers de formato, manejo de errores)
│   └── services/ (inicialización Firebase, abstracción de repositorios)
├── data/
│   ├── models/ (user_model, product_model)
│   └── repositories/ (auth_repository, product_repository, user_repository)
├── presentation/
│   ├── providers/ (auth_provider, product_provider, ui_state_provider)
│   ├── screens/
│   │   ├── auth/ (login_screen, register_screen)
│   │   ├── home/ (splash_screen, welcome_screen, about_screen)
│   │   ├── products/ (toys_screen, statues_screen, clothing_screen, promos_screen, product_detail_screen)
│   │   └── admin/ (admin_dashboard, add_edit_product_screen, users_list_screen)
│   └── widgets/ (product_card, custom_button, custom_text_field, loading_indicator, error_state)
└── assets/
    ├── images/ (logos, iconos, fondos temáticos)
    └── fonts/ (tipografías personalizadas si aplica)
```

---

## 7. 📋 Plan de Desarrollo Paso a Paso

### 🔹 Fase 1: Configuración Inicial y Cimientos
1. Inicializar proyecto Flutter multiplataforma y configurar versión de SDK.
2. Crear proyecto en Firebase Console y vincular Android, iOS, Web y Windows.
3. Configurar `firebase_core` y inicialización global.
4. Definir `theme.dart` con la paleta Jurassic Park (negro, amarillo, rojo) y aplicar al `MaterialApp`.
5. Configurar sistema de rutas base y navegación global.

### 🔹 Fase 2: Autenticación y Gestión de Usuarios
1. Diseñar pantallas de Login y Registro con validación visual.
2. Implementar `firebase_auth` para crear sesión, cerrar sesión y recuperar contraseña.
3. Crear `AuthProvider` para exponer estado de autenticación, datos de usuario y rol.
4. Guardar datos básicos en Firestore tras registro (`role: 'user'` por defecto).
5. Implementar protección de rutas: redirigir a Login si no hay sesión, o a Dashboard si es admin.

### 🔹 Fase 3: Modelo de Datos y State Management
1. Definir modelos `UserModel` y `ProductModel` con serialización/deserialización desde JSON.
2. Crear repositorios que abstraigan llamadas a Firestore y Storage.
3. Implementar `ProductProvider` con estados: `idle`, `loading`, `loaded`, `error`.
4. Configurar listeners en tiempo real o consultas bajo demanda para listados de productos.
5. Validar flujo de datos con Firebase Emulator Suite.

### 🔹 Fase 4: UI de Productos y Navegación por Categorías
1. Maquetar pantalla de bienvenida/intro tras login exitoso.
2. Crear `ProductCard` reutilizable con imagen, nombre, marca, precio y borde rojo sutil.
3. Implementar pantallas dedicadas: Juguetes, Estatuas, Ropa, Promocionales.
4. Configurar filtros por `categoria` en cada pantalla.
5. Desarrollar pantalla de detalle de producto: galería, descripción completa, especificaciones, botón de compra y disponibilidad.
6. Implementar caché de imágenes y paginación/lazy loading para rendimiento.

### 🔹 Fase 5: Panel de Administración
1. Verificar `role == 'admin'` antes de renderizar rutas administrativas.
2. Crear `AdminDashboard` con accesos directos: CRUD productos, lista de usuarios.
3. Implementar formulario de agregar/editar producto con campos requeridos, validación y selector de imagen.
4. Integrar subida a Firebase Storage y almacenamiento de URL en Firestore.
5. Desarrollar `UsersListScreen` con tabla/cards mostrando email, fecha de registro y rol (solo lectura).
6. Añadir confirmaciones de eliminación y manejo de errores de red/permisos.

### 🔹 Fase 6: Pantallas Informativas y Flujo Completo
1. Diseñar pantalla "Conócenos" con historia de la tienda, misión, contacto y enlaces sociales.
2. Unificar navegación principal: BottomNavigationBar o Drawer con acceso a categorías, inicio, conócenos y admin (si aplica).
3. Implementar estado de carrito de compras básico con Provider (preparación para pasarela de pago futura).
4. Añadir pantallas de estado vacío, carga y error para mejor UX.

### 🔹 Fase 7: Pruebas, Optimización y Despliegue
1. Ejecutar pruebas unitarias (repositorios, validadores) y de widget (pantallas críticas).
2. Optimizar renders: evitar rebuilds innecesarios, usar `const` widgets, optimizar consultas Firestore.
3. Configurar firmas digitales para Android e iOS.
4. Compilar y probar en Web y Desktop (Windows).
5. Preparar documentación técnica y manual de administrador.
6. Desplegar Web en Firebase Hosting, generar builds para tiendas móviles y distribuidoras de escritorio.

---

## 8. 🔐 Consideraciones Finales y Escalabilidad
- **Seguridad:** Nunca exponer claves de API en cliente. Usar reglas de Firestore estrictas. Validar datos en cliente y considerar Cloud Functions para validación adicional si la tienda escala.
- **Pagos:** El botón de compra se diseñará como hook listo para integrar Stripe, MercadoPago o PayPal mediante paquetes oficiales en una fase posterior.
- **Analítica:** Integrar `firebase_analytics` para trackear navegación, productos más vistos y conversiones.
- **Mantenimiento:** Usar versiones semánticas en `pubspec.yaml`, mantener dependencias actualizadas y documentar cambios en `CHANGELOG.md`.

---
## Prompt

Antigravity 
Flutter para Android/web/windows/IOS 
Prompt spideysaurus firebase / flutter / privider

actúa como un creador de software. quiero crear una aplicación flutter dart para una tienda especializada en juguetes y mercancía de la saga de películas jurassic park
Las funciones que tendremos en la página serán:
ver y comprar la mercancía que serán juguetes, estatuas, ropa, promocionales en una base de datos firebase console 
en las colecciones para los productos tendremos los campos de ID, nombre, marca y precio,
en la aplicación tendremos varias páginas inicio, juguetes, estatuas, ropa, promocionales, cada tipo de producto tendrá su propia tabla.
dirección y tendrá páginas de administrador para agregar productos a cada página y ver los usuarios que se registraron en la aplicación.
en el estilo de la aplicacion tendremos colores relacionados con el logo de jurassic park, utilizando negro en fondos, amarillo en botones y color rojo ciertas zonas como en el header y fondo de formularios.
cada página de los productos mostrará tarjetas con la imagen e información de cada producto, al entrar en los productos tendremos una pestaña completa para cada producto con toda su información y botones de compras
qué herramientas se requieren, ui, ux dependencias, login autentificación usuario password, base de datos firestore, privider, dependencias en pubspec.yaml, antes de que proporciones código quiero crear un plan de implementación en formato markdown, para desarrollar la aplicación "spideysaurus (tienda de juguetes de dinosaurios)", dame el proceso paso a paso para el desarrollo.
mostrarás la estructura de carpetas del proyecto para comprender cómo los archivos estarán asignados en el proyecto final.
para las páginas tendremos un inicio de sesión y registro al comienzo, al iniciar sesión tendremos un inicio explicativo, tendremos las páginas para juguetes, estatuas, ropa y promocionales, una página de conocernos con una explicación detallada de la tienda, tendremos un usuario admin que tendrá acceso a una página de administrador donde podrá agregar, editar y borrar los productos de la página.
No crearás código solo será el paso a paso para el desarrollo de la aplicación
agregando las tablas con los campos de juguetes, estatuas, ropa y promocionales teniendo en cuenta que los campos serán ID, nombre, marca, precio, imagen, y la tabla de los usuarios que será ID, nombre de usuario, contraseña encriptada 
