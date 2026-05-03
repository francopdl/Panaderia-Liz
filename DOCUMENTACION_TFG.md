# 🍞 SISTEMA DE GESTIÓN DE PANADERÍA - DOCUMENTACIÓN TFG

**Título del Proyecto:** Sistema de Gestión de Panadería con Punto de Venta (TPV) Multiplataforma

**Autor:** [Tu nombre]

**Fecha:** 2026

**Versión:** 1.0.0

**Institución:** [Tu Institución Educativa]

---

## 📋 TABLA DE CONTENIDOS

1. [Introducción](#introducción)
2. [Cambios y Evolución del Proyecto](#cambios-y-evolución-del-proyecto)
3. [Descripción del Sistema](#descripción-del-sistema)
4. [Características Principales](#características-principales)
5. [Requisitos del Sistema](#requisitos-del-sistema)
6. [Instalación](#instalación)
7. [Estructura del Proyecto](#estructura-del-proyecto)
8. [Modelos de Datos](#modelos-de-datos)
9. [Servicios y Lógica de Negocio](#servicios-y-lógica-de-negocio)
10. [Arquitectura Técnica](#arquitectura-técnica)
11. [Módulos Implementados](#módulos-implementados)
12. [Base de Datos](#base-de-datos)
13. [Seguridad](#seguridad)
14. [Uso de la Aplicación](#uso-de-la-aplicación)
15. [Tecnologías Utilizadas](#tecnologías-utilizadas)
16. [Futuras Mejoras](#futuras-mejoras)
17. [Conclusiones](#conclusiones)

---

## 1. INTRODUCCIÓN

### Objetivo del Proyecto

El presente Trabajo Fin de Grado tiene como objetivo el diseño e implementación de un **Sistema de Gestión Integral para Panaderías** mediante una aplicación multiplataforma basada en **Flutter**. Este sistema proporciona herramientas completas para gestionar operaciones comerciales, inventario, producción y distribución de productos panaderos.

### Contexto

La panadería es un negocio que requiere control eficiente de múltiples aspectos operativos:
- **Venta directa** al cliente mediante punto de venta (TPV)
- **Control de inventario** de productos finales
- **Gestión de materia prima** (ingredientes)
- **Planificación de producción** basada en recetas
- **Seguimiento de distribuciones** a otros puntos de venta
- **Auditoría de cambios** en el sistema

### Motivación

La transición de una aplicación de escritorio en Python (versión anterior) a una solución multiplataforma en Flutter permite:
- ✅ Acceso desde cualquier dispositivo (móvil, tablet, escritorio, web)
- ✅ Mejor experiencia de usuario con Material Design 3
- ✅ Sincronización en tiempo real mediante Firebase
- ✅ Mantenimiento centralizado del código
- ✅ Mejor rendimiento y escalabilidad
- ✅ Integración con servicios en la nube

---

## 2. CAMBIOS Y EVOLUCIÓN DEL PROYECTO

### Versión Anterior (Python - Tkinter)

**Características:**
- Aplicación de escritorio usando Tkinter
- Base de datos SQLite local
- Arquitectura MVC
- Interfaz gráfica básica
- Limitada a sistemas Windows, Linux y macOS
- Almacenamiento local únicamente

**Estructura:**
```
TFG/
├── main.py
├── database/
├── models/
├── controllers/
├── views/
├── config/
└── assets/
```

### Nueva Versión (Flutter - Multiplataforma)

**Mejoras Realizadas:**

#### 🔄 Cambio de Tecnología
| Aspecto | Anterior (Python) | Nuevo (Flutter) |
|--------|-------------------|-----------------|
| **Framework** | Tkinter | Flutter |
| **Lenguaje** | Python | Dart |
| **Plataformas** | Windows, Linux, macOS | iOS, Android, Windows, macOS, Linux, Web |
| **Base de Datos** | SQLite Local | SQLite Local + Firebase Firestore |
| **Almacenamiento** | Sistema de Archivos | Firebase Storage |
| **UI/UX** | Básica | Material Design 3 |
| **Rendimiento** | Regular | Excelente |
| **Escalabilidad** | Limitada | Altamente escalable |

#### 📦 Cambios Arquitectónicos

1. **Separación de Responsabilidades**
   - Services: Lógica de negocio + Acceso a datos
   - Models: Representación de entidades
   - Screens: Interfaz de usuario
   - Widgets: Componentes reutilizables
   - Config: Configuración centralizada

2. **Gestión de Estado**
   - Implementación de Provider para manejo reactivo
   - Notifiers (CartNotifier, SalesNotifier, ThemeService)
   - MultiProvider para inyección de dependencias

3. **Persistencia de Datos**
   - SQLite para almacenamiento local offline-first
   - Firebase Firestore para sincronización en nube
   - SharedPreferences para configuración de usuario

4. **Autenticación**
   - Firebase Auth (preparado para expansión futura)
   - Sistema local de credenciales
   - Gestión de roles mejorada

#### 🎯 Nuevas Funcionalidades

- ✅ Interfaz responsive adaptable a cualquier tamaño de pantalla
- ✅ Sincronización automática con Firestore
- ✅ Temas personalizables (claro/oscuro)
- ✅ Generación de reportes PDF
- ✅ Gráficos estadísticos interactivos
- ✅ Gestión completa de materia prima
- ✅ Módulo de producción con recetas
- ✅ Sistema de distribución
- ✅ Galería de imágenes para productos
- ✅ Exportación de datos

---

## 3. DESCRIPCIÓN DEL SISTEMA

### ¿Qué es Panadería Liz?

**Panadería Liz** es una aplicación integral para la gestión operativa de una panadería. Proporciona herramientas para:

1. **Vendedores:**
   - Registrar ventas de forma rápida y eficiente
   - Generar tickets de venta
   - Gestionar carrito de compras
   - Procesar pagos

2. **Administradores:**
   - Visualizar estadísticas generales
   - Gestionar inventario de productos
   - Controlar materia prima
   - Planificar producción
   - Gestionar distribuciones
   - Administrar usuarios del sistema
   - Generar reportes

3. **Sistema Interno:**
   - Sincronización automática de datos
   - Auditoría de movimientos
   - Validación de credenciales
   - Control de roles y permisos

### Flujo de Trabajo Típico

```
┌─────────────┐
│   Usuario   │
│  Se Autentica│
└──────┬──────┘
       │
       ▼
┌──────────────────────────────────────┐
│        Según Rol Asignado            │
├──────────────────────────────────────┤
│  ADMIN          │      EMPLEADO      │
├─────────────────┼───────────────────┤
│ - Panel        │ - TPV Directo     │
│   Estadísticas │                   │
│ - Gestión      │                   │
│   Productos    │                   │
│ - Gestión      │                   │
│   Materia Prima│                   │
│ - Producción   │                   │
│ - Distribución │                   │
│ - Usuarios     │                   │
│ - Reportes     │                   │
└─────────────────┴───────────────────┘
```

---

## 4. CARACTERÍSTICAS PRINCIPALES

### 🔐 Sistema de Autenticación y Roles

#### Autenticación
- Login con usuario y contraseña
- Validación contra base de datos local
- Gestión de sesiones
- Cierre de sesión seguro

#### Roles Disponibles

**Administrador (admin)**
- Acceso completo a todos los módulos
- Panel de control con estadísticas
- Gestión de todos los inventarios
- Administración de usuarios
- Generación de reportes

**Empleado (employee)**
- Acceso únicamente al sistema TPV
- Venta rápida de productos
- Gestión de carrito de compras
- Confirmación de ventas

### 🛒 Sistema TPV (Punto de Venta)

#### Funcionalidades
- Catálogo de productos organizado por categorías
- Búsqueda y filtrado rápido
- Visualización de stock en tiempo real
- Carrito de compras con interfaz intuitiva
- Incremento/decremento de cantidades
- Cálculo automático de subtotales y totales
- Aplicación de descuentos globales
- Múltiples métodos de pago
- Generación de tickets
- Historial de ventas

#### Ventajas
- Interfaz optimizada para pantalla táctil
- Responsive en tablets, móviles y escritorio
- Búsqueda instantánea de productos
- Confirmación de venta rápida
- Generación automática de recibos

### 📊 Panel de Administración

#### Estadísticas
- Total de ventas (número de transacciones)
- Ingresos totales (suma de todos los ingresos)
- Productos más vendidos
- Categorías con mejor desempeño

#### Gráficos Interactivos
- Gráfico de ventas por día
- Gráfico de categorías más vendidas
- Visualización de tendencias

### 📦 Gestión de Productos

- Crear, editar y eliminar productos
- Asignar a categorías
- Establecer precio y stock
- Gestionar disponibilidad
- Subir imágenes de productos
- Control de stock mínimo
- Alertas de bajo stock

### 🥖 Gestión de Materia Prima

- Registro de ingredientes y insumos
- Seguimiento de cantidades
- Gestión de proveedores
- Histórico de costos
- Alertas de stock bajo
- Control de fechas de vencimiento (preparado)

### 🏭 Módulo de Producción

- Creación de recetas
- Fabricación de productos
- Descuento automático de materia prima
- Aumento de stock de productos finales
- Historial de producciones
- Cálculo automático de costos

### 🚚 Gestión de Distribución

- Registro de entregas
- Seguimiento de envíos
- Control de clientes y tiendas
- Historial de distribuciones
- Confirmación de entrega

### 👥 Administración de Usuarios

- Crear nuevos usuarios
- Asignar roles
- Cambiar permisos
- Historial de acceso
- Gestión de contraseñas

### 📈 Reportes y Analítica

- Reporte de ventas por período
- Reporte de stock
- Reporte de producción
- Reporte de distribuciones
- Exportación a PDF/Excel (preparada)
- Análisis de tendencias

---

## 5. REQUISITOS DEL SISTEMA

### Requisitos Mínimos

#### Hardware

| Componente | Mínimo | Recomendado |
|-----------|--------|-------------|
| **RAM** | 2 GB | 4 GB o superior |
| **Almacenamiento** | 500 MB | 2 GB |
| **Procesador** | Dual Core | Quad Core |
| **Pantalla** | 4" | 7" o superior |

#### Software

**Para ejecutar:**
- Android 5.0+ (dispositivo Android)
- iOS 11+ (dispositivo iOS)
- Windows 10+ (escritorio)
- macOS 10.14+ (Apple)
- Linux (Ubuntu 18.04+)
- Navegador moderno (Web)

**Para desarrollar:**
- Flutter SDK 3.0.0 o superior
- Dart 3.0.0 o superior
- Android SDK (para Android)
- Xcode (para iOS)
- Visual Studio Code o Android Studio

### Conectividad

- Conexión a Internet (recomendada para sincronización)
- Aplicación funcional en modo offline (con sincronización posterior)

---

## 6. INSTALACIÓN

### Opción A: Instalación para Usuarios Finales

#### En Android (APK)
1. Descargar el archivo APK desde el repositorio
2. Permitir instalación de fuentes desconocidas
3. Abrir archivo APK
4. Completar instalación
5. Ejecutar la aplicación

#### En Web
1. Acceder a la URL de despliegue
2. La aplicación se cargará automáticamente
3. Crear acceso directo si es necesario

#### En Windows/macOS/Linux
1. Descargar ejecutable desde el repositorio
2. Ejecutar el instalador
3. Seguir el asistente de instalación
4. Ejecutar desde el menú de inicio/aplicaciones

### Opción B: Instalación para Desarrolladores

#### 1. Requisitos Previos

```bash
# Verificar Flutter
flutter --version

# Verificar Dart
dart --version

# Verificar conectividad con Android
flutter doctor
```

#### 2. Clonar el Repositorio

```bash
git clone https://github.com/usuario/panaderia-liz.git
cd PanaderiaLiz
```

#### 3. Instalar Dependencias

```bash
# Limpiar cualquier instalación anterior
flutter clean

# Obtener dependencias
flutter pub get

# Compilar para web (opcional)
flutter build web
```

#### 4. Configurar Firebase (Opcional)

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Descargar configuración `google-services.json` (Android)
3. Colocar en `android/app/`
4. Descargar configuración para iOS si es necesario

#### 5. Ejecutar la Aplicación

```bash
# En dispositivo/emulador Android
flutter run

# En dispositivo/emulador iOS
flutter run -d ios

# En web
flutter run -d chrome

# En escritorio (Windows)
flutter run -d windows

# En escritorio (macOS)
flutter run -d macos

# En escritorio (Linux)
flutter run -d linux

# Con modo release
flutter run --release
```

#### 6. Compilar para Distribución

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 7. ESTRUCTURA DEL PROYECTO

### Árbol de Carpetas Completo

```
PanaderiaLiz/
├── lib/                                    # Código Dart principal
│   ├── main.dart                          # Punto de entrada
│   │
│   ├── config/                            # Configuración global
│   │   ├── constants.dart                 # Constantes de la app
│   │   ├── router.dart                    # Configuración de rutas
│   │   ├── theme.dart                     # Tema visual
│   │   └── index.dart                     # Exportaciones
│   │
│   ├── models/                            # Modelos de datos
│   │   ├── user.dart                      # Modelo de Usuario
│   │   ├── product.dart                   # Modelo de Producto
│   │   ├── product_category.dart          # Categoría de Producto
│   │   ├── cart.dart                      # Modelo de Carrito
│   │   ├── order.dart                     # Modelo de Orden
│   │   ├── sale.dart                      # Modelo de Venta
│   │   ├── sale_item.dart                 # Ítem de Venta
│   │   ├── recipe.dart                    # Modelo de Receta
│   │   ├── production_record.dart         # Registro de Producción
│   │   ├── raw_material.dart              # Materia Prima
│   │   ├── delivery_order.dart            # Orden de Entrega
│   │   ├── payment_method.dart            # Método de Pago
│   │   └── index.dart                     # Exportaciones
│   │
│   ├── services/                          # Servicios y lógica de negocio
│   │   ├── auth_service.dart              # Autenticación (base)
│   │   ├── auth_service_db.dart           # Autenticación con BD
│   │   ├── product_service.dart           # Gestión productos (base)
│   │   ├── product_service_db.dart        # Gestión productos con BD
│   │   ├── sales_service_db.dart          # Gestión de ventas
│   │   ├── order_service.dart             # Gestión de órdenes
│   │   ├── database_service.dart          # Servicio de BD
│   │   ├── firestore_service.dart         # Sincronización Firebase
│   │   ├── cart_notifier.dart             # Estado del carrito (Provider)
│   │   ├── sales_notifier.dart            # Estado de ventas
│   │   ├── theme_service.dart             # Gestión de temas
│   │   ├── image_storage_service.dart     # Almacenamiento de imágenes
│   │   ├── pdf_service.dart               # Generación de PDF
│   │   ├── web_storage_service.dart       # Almacenamiento web
│   │   └── index.dart                     # Exportaciones
│   │
│   ├── screens/                           # Pantallas principales
│   │   ├── login_screen.dart              # Pantalla de Login
│   │   ├── home_screen.dart               # Panel de Control (Admin)
│   │   ├── tpv_screen.dart                # Sistema de Punto de Venta
│   │   ├── sales_history_screen.dart      # Historial de Ventas
│   │   ├── products_management_screen.dart # Gestión de Productos
│   │   ├── users_management_screen.dart   # Gestión de Usuarios
│   │   ├── factory_screen.dart            # Módulo de Producción
│   │   ├── delivery_screen.dart           # Módulo de Distribución
│   │   ├── settings_screen.dart           # Configuración
│   │   └── index.dart                     # Exportaciones
│   │
│   ├── widgets/                           # Componentes reutilizables
│   │   ├── primary_button.dart            # Botón principal
│   │   ├── custom_text_field.dart         # Campo de texto personalizado
│   │   ├── product_card.dart              # Tarjeta de producto
│   │   ├── cart_item_widget.dart          # Widget de item en carrito
│   │   ├── empty_state.dart               # Widget estado vacío
│   │   ├── loading_state.dart             # Widget de carga
│   │   ├── image_picker_widget.dart       # Selector de imagen
│   │   ├── stats_card.dart                # Tarjeta de estadísticas
│   │   ├── sales_charts.dart              # Gráficos de ventas
│   │   └── index.dart                     # Exportaciones
│   │
│   └── utils/                             # Utilidades
│       ├── formatters.dart                # Formateadores (moneda, fecha)
│       ├── validators.dart                # Validadores de entrada
│       ├── password_utils.dart            # Utilidades de contraseñas
│       └── index.dart                     # Exportaciones
│
├── assets/                                # Recursos estáticos
│   ├── images/                            # Imágenes de la app
│   └── data/                              # Datos iniciales (JSON)
│
├── android/                               # Configuración Android
│   ├── app/
│   │   ├── build.gradle                   # Configuración de build
│   │   ├── google-services.json           # Configuración Firebase
│   │   └── src/
│   ├── build.gradle
│   ├── gradle.properties
│   ├── settings.gradle
│   └── local.properties
│
├── ios/                                   # Configuración iOS
│   ├── Runner/
│   │   ├── Info.plist                     # Configuración iOS
│   │   └── GeneratedPluginRegistrant
│   ├── Podfile
│   └── Pods/
│
├── web/                                   # Configuración Web
│   ├── index.html                         # HTML principal
│   ├── manifest.json
│   └── sqflite_sw.js
│
├── windows/                               # Configuración Windows
│   └── runner/
│
├── macos/                                 # Configuración macOS
│   └── Runner/
│
├── linux/                                 # Configuración Linux
│   └── CMakeLists.txt
│
├── test/                                  # Tests unitarios (preparado)
│
├── pubspec.yaml                           # Dependencias y configuración
├── pubspec.lock                           # Lock de versiones
├── analysis_options.yaml                  # Análisis de código
├── firebase.json                          # Configuración Firebase
├── .gitignore                             # Git ignore
├── .metadata                              # Metadatos Flutter
├── README.md                              # Readme básico
└── DOCUMENTACION_TFG.md                   # Esta documentación
```

### Descripción de Carpetas Clave

#### `/lib/config/`
Contiene la configuración global de la aplicación:
- **constants.dart**: Constantes como colores, tamaños, mensajes
- **router.dart**: Definición de rutas y navegación
- **theme.dart**: Temas visuales (claro/oscuro)

#### `/lib/models/`
Modelos de datos que representan entidades del sistema:
- Cada modelo tiene métodos `fromMap()`, `toMap()` para serialización
- Soportan conversión JSON para Firebase

#### `/lib/services/`
Lógica de negocio y acceso a datos:
- Services DB: Interactúan con base de datos
- Notifiers: Manejan estado reactivo
- Special services: PDF, imágenes, etc.

#### `/lib/screens/`
Pantallas principales de la aplicación:
- Cada screen es un StatefulWidget o StatelessWidget
- Usan Provider para acceder a servicios
- Contienen la lógica de presentación

#### `/lib/widgets/`
Componentes reutilizables:
- Botones, campos de texto, tarjetas
- Pueden usarse en múltiples pantallas
- Reducen duplicación de código

#### `/lib/utils/`
Funciones utilitarias:
- Formateo de datos (moneda, fechas)
- Validación de entradas
- Funciones de encriptación

#### `/assets/`
Recursos estáticos:
- Imágenes, iconos
- Datos iniciales en JSON

---

## 8. MODELOS DE DATOS

### Diagrama de Entidades

```
┌─────────────────┐
│     Usuario     │
├─────────────────┤
│ • id (PK)       │
│ • username      │
│ • password      │
│ • email         │
│ • rol           │
│ • activo        │
│ • fecha_creacion│
└────────┬────────┘
         │ 1:N
         │
         ▼
┌─────────────────┐
│     Venta       │◄─────────┐
├─────────────────┤          │
│ • id (PK)       │          │
│ • usuario_id(FK)│    1:N   │
│ • fecha         │          │
│ • total         │    ┌─────┴──────────────┐
│ • metodo_pago   │    │                    │
│ • descuento     │    │                    │
└─────────────────┘    │                    │
                       ▼                    │
              ┌──────────────────┐          │
              │   Detalle_Venta  │          │
              ├──────────────────┤          │
              │ • id (PK)        │          │
              │ • venta_id (FK)  ├──────────┘
              │ • producto_id(FK)├──────────┐
              │ • cantidad       │          │
              │ • precio_unitario│          │
              │ • subtotal       │          │
              └──────────────────┘          │
                                           │
                                    ┌──────┴────────────┐
                                    ▼                   ▼
                         ┌─────────────────┐  ┌──────────────────┐
                         │    Producto     │  │  ProductCategory │
                         ├─────────────────┤  ├──────────────────┤
                         │ • id (PK)       │  │ • id (PK)        │
                         │ • nombre        │  │ • nombre         │
                         │ • precio        │  │ • descripcion    │
                         │ • stock         │  │ • activo         │
                         │ • categoria_id  │──│                  │
                         │ • activo        │  └──────────────────┘
                         │ • imagen_url    │
                         │ • fecha_creacion│
                         └─────────────────┘
                                │ 1:N
                                │
                                ▼
                    ┌─────────────────────────┐
                    │    MovimientoStock      │
                    ├─────────────────────────┤
                    │ • id (PK)               │
                    │ • producto_id (FK)      │
                    │ • tipo (entrada/salida) │
                    │ • cantidad              │
                    │ • motivo                │
                    │ • fecha                 │
                    │ • usuario_id            │
                    └─────────────────────────┘
```

### Descripción de Modelos Principales

#### **User**
```dart
class User {
  final String id;           // UUID único
  final String username;     // Nombre de usuario
  final String password;     // Contraseña hasheada
  final String email;        // Email
  final String role;         // 'admin' o 'employee'
  final bool isActive;       // Usuario activo
  final DateTime createdAt;  // Fecha de creación
  final DateTime? updatedAt; // Última actualización
}
```

#### **Product**
```dart
class Product {
  final String id;           // UUID único
  final String name;         // Nombre del producto
  final double price;        // Precio en euros
  final String category;     // Categoría
  final int stock;           // Cantidad disponible
  final bool isAvailable;    // Disponible para venta
  final DateTime createdAt;  // Fecha de creación
  final String? imageUrl;    // URL de imagen
}
```

#### **Sale**
```dart
class Sale {
  final String id;                // UUID único
  final String userId;            // ID del vendedor
  final double subtotal;          // Subtotal
  final double discountAmount;    // Descuento aplicado
  final double total;             // Total final
  final String paymentMethod;     // Método de pago
  final DateTime createdAt;       // Fecha de venta
  final List<SaleItem> items;     // Ítems vendidos
}
```

#### **SaleItem**
```dart
class SaleItem {
  final String id;                // UUID único
  final String saleId;            // ID de venta
  final String productId;         // ID del producto
  final String productName;       // Nombre del producto
  final int quantity;             // Cantidad vendida
  final double unitPrice;         // Precio unitario
  final double subtotal;          // Subtotal (qty * price)
}
```

#### **Recipe**
```dart
class Recipe {
  final String id;                // UUID único
  final String name;              // Nombre de receta
  final String productId;         // Producto que produce
  final int productQuantity;      // Cantidad de producto
  final Map<String, int> materials; // materials: {materia_id: cantidad}
  final String instructions;      // Instrucciones
  final DateTime createdAt;       // Fecha de creación
}
```

#### **RawMaterial**
```dart
class RawMaterial {
  final String id;                // UUID único
  final String name;              // Nombre del material
  final String unit;              // Unidad (kg, L, etc)
  final double stock;             // Stock actual
  final double price;             // Precio por unidad
  final String provider;          // Proveedor
  final DateTime createdAt;       // Fecha de creación
}
```

---

## 9. SERVICIOS Y LÓGICA DE NEGOCIO

### Arquitectura de Servicios

```
┌──────────────────────────────────────────────────────┐
│              Capa de Presentación                    │
│          (Screens y Widgets)                         │
└────────────────────┬─────────────────────────────────┘
                     │ Usa
                     ▼
┌──────────────────────────────────────────────────────┐
│           Capa de Servicios (Services)              │
│  • AuthServiceDB                                     │
│  • ProductServiceDB                                  │
│  • SalesServiceDB                                    │
│  • OrderService                                      │
│  • CartNotifier                                      │
│  • SalesNotifier                                     │
│  • ThemeService                                      │
│  • FirestoreService                                  │
└────────────────────┬─────────────────────────────────┘
                     │ Accede
                     ▼
┌──────────────────────────────────────────────────────┐
│       Capa de Acceso a Datos                        │
│  • DatabaseService (SQLite)                         │
│  • ImageStorageService                              │
│  • WebStorageService                                │
│  • PDFService                                        │
└────────────────────┬─────────────────────────────────┘
                     │ Interactúa
                     ▼
┌──────────────────────────────────────────────────────┐
│         Capa de Datos                               │
│  • SQLite (Local)                                   │
│  • Firebase Firestore (Cloud)                       │
│  • Firebase Storage (Archivos)                      │
│  • SharedPreferences (Configuración)                │
└──────────────────────────────────────────────────────┘
```

### Servicios Principales

#### **AuthServiceDB**
**Responsabilidad:** Gestión de autenticación de usuarios

**Métodos Principales:**
```dart
Future<User?> login(String username, String password)
Future<void> logout()
Future<User?> getCurrentUser()
Future<bool> register(User user)
Future<List<User>> getAllUsers()
Future<void> updateUser(User user)
Future<void> deleteUser(String userId)
```

#### **ProductServiceDB**
**Responsabilidad:** Gestión de productos

**Métodos Principales:**
```dart
Future<List<Product>> getAllProducts()
Future<Product?> getProductById(String id)
Future<List<Product>> getProductsByCategory(String category)
Future<void> addProduct(Product product)
Future<void> updateProduct(Product product)
Future<void> deleteProduct(String productId)
Future<void> updateStock(String productId, int newStock)
Future<List<String>> getCategories()
```

#### **SalesServiceDB**
**Responsabilidad:** Gestión de ventas y órdenes

**Métodos Principales:**
```dart
Future<void> saveSale(Sale sale)
Future<List<Sale>> getAllSales()
Future<Sale?> getSaleById(String id)
Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end)
Future<double> getTotalSalesByDate(DateTime date)
Future<int> getSalesCountByDate(DateTime date)
Future<Map<String, int>> getProductsSoldStats()
```

#### **CartNotifier (Provider)**
**Responsabilidad:** Gestión del estado del carrito

**Métodos Principales:**
```dart
void addProduct(Product product)
void removeProduct(String productId)
void updateQuantity(String productId, int quantity)
void clearCart()
void applyDiscount(double percentage)
double getTotal()
double getSubtotal()
double getDiscount()
List<CartItem> getItems()
```

#### **SalesNotifier (Provider)**
**Responsabilidad:** Gestión del estado de ventas

**Métodos Principales:**
```dart
Future<void> loadSales()
void refresh()
List<Sale> getSales()
double getTotalRevenue()
List<Sale> getSalesByDate(DateTime date)
```

#### **FirestoreService**
**Responsabilidad:** Sincronización con Firebase Firestore

**Métodos Principales:**
```dart
Future<void> seedIfEmpty()
Future<void> syncUsers()
Future<void> syncProducts()
Future<void> syncSales()
Future<void> backupData()
Future<void> restoreData()
```

#### **ThemeService**
**Responsabilidad:** Gestión de temas (claro/oscuro)

**Métodos Principales:**
```dart
Future<void> initialize()
void toggleTheme()
bool isDarkMode()
ThemeData getThemeData()
```

---

## 10. ARQUITECTURA TÉCNICA

### Patrón de Arquitectura: MVC Mejorado

La aplicación utiliza una arquitectura de capas basada en **MVC (Model-View-Controller)** con mejoras:

```
┌─────────────────────────────────────────────────────────┐
│              CAPA DE PRESENTACIÓN                      │
│    (Screens + Widgets + BuildContext)                  │
│  • Responsabilidad: Renderizar UI                      │
│  • No contiene lógica de negocio                       │
│  • Consume servicios via Provider                      │
└──────────────┬──────────────────────────────────────────┘
               │
               │ Accede a través de Provider
               │
┌──────────────▼──────────────────────────────────────────┐
│         CAPA DE SERVICIOS / LÓGICA DE NEGOCIO          │
│    (Services + Notifiers)                              │
│  • Responsabilidad: Lógica de aplicación               │
│  • Manejo de estado (Provider/ChangeNotifier)          │
│  • Orquestación de datos                               │
│  • Validaciones de negocio                             │
└──────────────┬──────────────────────────────────────────┘
               │
               │ Accede a
               │
┌──────────────▼──────────────────────────────────────────┐
│           CAPA DE ACCESO A DATOS                       │
│    (Repository Pattern)                                │
│  • Responsabilidad: CRUD de datos                      │
│  • Abstracción de fuentes de datos                     │
│  • DatabaseService, ImageStorageService               │
└──────────────┬──────────────────────────────────────────┘
               │
               │ Accede a
               │
┌──────────────▼──────────────────────────────────────────┐
│              CAPA DE DATOS                             │
│    (SQLite, Firebase, Shared Preferences)              │
│  • Base de datos local y en la nube                    │
│  • Almacenamiento de archivos                          │
│  • Configuración de usuario                            │
└──────────────────────────────────────────────────────────┘
```

### Flujo de Datos

```
1. Usuario interactúa con UI (Screen/Widget)
                    │
                    ▼
2. Widget dispara acción (click, input)
                    │
                    ▼
3. Screen consulta Service via Provider
                    │
                    ▼
4. Service ejecuta lógica de negocio
                    │
                    ▼
5. Service accede a DatabaseService/otras fuentes
                    │
                    ▼
6. Se recuperan/modifican datos
                    │
                    ▼
7. Service notifica cambios (setState, notifyListeners)
                    │
                    ▼
8. Widget se reconstruye con nuevos datos
                    │
                    ▼
9. UI se actualiza
```

### Patrón Provider para Gestión de Estado

```dart
// 1. Crear Notifier
class CartNotifier extends ChangeNotifier {
  List<CartItem> _items = [];
  
  void addProduct(Product product) {
    _items.add(...);
    notifyListeners();  // Notifica cambios
  }
}

// 2. Proporcionar en main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CartNotifier()),
  ],
)

// 3. Consumir en Widget
Consumer<CartNotifier>(
  builder: (context, cart, child) {
    return Text('Total: ${cart.getTotal()}');
  },
)

// 4. Acceder a través de context
final cart = context.read<CartNotifier>();
cart.addProduct(product);
```

---

## 11. MÓDULOS IMPLEMENTADOS

### ✅ Módulos Completamente Implementados

#### 1. **Autenticación y Login**
- ✅ Pantalla de login
- ✅ Validación de credenciales
- ✅ Gestión de sesiones
- ✅ Dos roles: Admin y Empleado
- ✅ Cierre de sesión

#### 2. **Sistema TPV (Punto de Venta)**
- ✅ Catálogo de productos
- ✅ Búsqueda y filtrado
- ✅ Carrito de compras
- ✅ Cálculo de totales
- ✅ Descuentos
- ✅ Generación de tickets
- ✅ Múltiples métodos de pago
- ✅ Historial de ventas

#### 3. **Panel de Control (Admin)**
- ✅ Estadísticas generales
- ✅ Gráficos de ventas
- ✅ Acceso a módulos

#### 4. **Gestión de Productos**
- ✅ CRUD completo
- ✅ Categorías
- ✅ Imágenes
- ✅ Stock
- ✅ Disponibilidad

#### 5. **Base de Datos**
- ✅ SQLite local
- ✅ Firebase Firestore
- ✅ Sincronización automática

### 🔄 Módulos en Desarrollo / Mejora

#### 1. **Gestión de Materia Prima**
- 🔄 CRUD de materiales
- 🔄 Gestión de proveedores
- 🔄 Alertas de stock bajo
- ⏳ Seguimiento de vencimientos

#### 2. **Módulo de Producción**
- 🔄 Creación de recetas
- 🔄 Registro de fabricación
- 🔄 Cálculo automático de costos
- ⏳ Historial de producciones

#### 3. **Módulo de Distribución**
- 🔄 Gestión de entregas
- 🔄 Seguimiento de envíos
- 🔄 Confirmación de entrega
- ⏳ Reporte de distribuciones

#### 4. **Gestión de Usuarios**
- 🔄 CRUD de usuarios
- 🔄 Asignación de roles
- 🔄 Gestión de permisos
- ⏳ Auditoría de acceso

#### 5. **Reportes y Analítica**
- 🔄 Reporte de ventas
- 🔄 Reporte de stock
- 🔄 Gráficos interactivos
- ⏳ Exportación a PDF/Excel
- ⏳ Análisis de tendencias

---

## 12. BASE DE DATOS

### Esquema SQLite

#### Tabla: `usuarios`
```sql
CREATE TABLE usuarios (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email TEXT,
    rol TEXT NOT NULL,
    activo INTEGER DEFAULT 1,
    fecha_creacion TEXT NOT NULL,
    fecha_actualizacion TEXT
);
```

#### Tabla: `productos`
```sql
CREATE TABLE productos (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio REAL NOT NULL,
    categoria TEXT NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    disponible INTEGER DEFAULT 1,
    url_imagen TEXT,
    fecha_creacion TEXT NOT NULL
);
```

#### Tabla: `categorias_producto`
```sql
CREATE TABLE categorias_producto (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    activo INTEGER DEFAULT 1
);
```

#### Tabla: `ventas`
```sql
CREATE TABLE ventas (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    subtotal REAL NOT NULL,
    descuento REAL NOT NULL DEFAULT 0,
    total REAL NOT NULL,
    metodo_pago TEXT NOT NULL,
    fecha_creacion TEXT NOT NULL,
    FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
);
```

#### Tabla: `detalles_venta`
```sql
CREATE TABLE detalles_venta (
    id TEXT PRIMARY KEY,
    venta_id TEXT NOT NULL,
    producto_id TEXT NOT NULL,
    nombre_producto TEXT NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario REAL NOT NULL,
    subtotal REAL NOT NULL,
    FOREIGN KEY(venta_id) REFERENCES ventas(id),
    FOREIGN KEY(producto_id) REFERENCES productos(id)
);
```

#### Tabla: `materia_prima`
```sql
CREATE TABLE materia_prima (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    unidad TEXT NOT NULL,
    stock REAL NOT NULL,
    precio REAL NOT NULL,
    proveedor TEXT,
    fecha_creacion TEXT NOT NULL
);
```

#### Tabla: `recetas`
```sql
CREATE TABLE recetas (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    producto_id TEXT NOT NULL,
    cantidad_producto INTEGER NOT NULL,
    instrucciones TEXT,
    fecha_creacion TEXT NOT NULL,
    FOREIGN KEY(producto_id) REFERENCES productos(id)
);
```

#### Tabla: `ingredientes_receta`
```sql
CREATE TABLE ingredientes_receta (
    id TEXT PRIMARY KEY,
    receta_id TEXT NOT NULL,
    materia_prima_id TEXT NOT NULL,
    cantidad REAL NOT NULL,
    FOREIGN KEY(receta_id) REFERENCES recetas(id),
    FOREIGN KEY(materia_prima_id) REFERENCES materia_prima(id)
);
```

#### Tabla: `producciones`
```sql
CREATE TABLE producciones (
    id TEXT PRIMARY KEY,
    receta_id TEXT NOT NULL,
    cantidad INTEGER NOT NULL,
    fecha_creacion TEXT NOT NULL,
    notas TEXT,
    FOREIGN KEY(receta_id) REFERENCES recetas(id)
);
```

#### Tabla: `distribuciones`
```sql
CREATE TABLE distribuciones (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    fecha_entrega TEXT NOT NULL,
    cliente TEXT NOT NULL,
    notas TEXT,
    confirmada INTEGER DEFAULT 0,
    FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
);
```

#### Tabla: `detalles_distribucion`
```sql
CREATE TABLE detalles_distribucion (
    id TEXT PRIMARY KEY,
    distribucion_id TEXT NOT NULL,
    producto_id TEXT NOT NULL,
    cantidad INTEGER NOT NULL,
    FOREIGN KEY(distribucion_id) REFERENCES distribuciones(id),
    FOREIGN KEY(producto_id) REFERENCES productos(id)
);
```

#### Tabla: `movimientos_stock`
```sql
CREATE TABLE movimientos_stock (
    id TEXT PRIMARY KEY,
    producto_id TEXT NOT NULL,
    tipo TEXT NOT NULL,
    cantidad INTEGER NOT NULL,
    motivo TEXT,
    usuario_id TEXT NOT NULL,
    fecha_creacion TEXT NOT NULL,
    FOREIGN KEY(producto_id) REFERENCES productos(id),
    FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
);
```

### Sincronización Firestore

Las colecciones en Firestore espejo el esquema SQLite:
- `users`
- `products`
- `sales`
- `rawMaterials`
- `recipes`
- `productions`
- `deliveries`

**Ventajas:**
- ✅ Backup automático en la nube
- ✅ Sincronización en tiempo real
- ✅ Acceso desde múltiples dispositivos
- ✅ Recuperación ante fallos

---

## 13. SEGURIDAD

### Medidas de Seguridad Implementadas

#### 1. **Autenticación**
- ✅ Contraseñas hasheadas (usando crypto package)
- ✅ Validación contra base de datos
- ✅ Sesiones limitadas en tiempo
- ✅ Cierre de sesión automático

#### 2. **Autorización**
- ✅ Control de roles (Admin/Empleado)
- ✅ Restricción de acceso a módulos
- ✅ Validación de permisos

#### 3. **Validación de Datos**
- ✅ Validación de entrada en formularios
- ✅ Validación de límites de valores
- ✅ Sanitización de datos

#### 4. **Protección de Base de Datos**
- ✅ Uso de prepared statements
- ✅ Prevención de SQL injection
- ✅ Transacciones ACID

#### 5. **Auditoría**
- ✅ Registro de movimientos de stock
- ✅ Registro de acceso de usuarios
- ✅ Rastrabilidad de cambios

#### 6. **Seguridad en la Nube (Firebase)**
- ✅ Reglas de Firestore
- ✅ Encriptación en tránsito
- ✅ Autenticación Firebase

### Mejoras de Seguridad Futuras

```
⏳ Autenticación de dos factores (2FA)
⏳ Encriptación de datos en reposo
⏳ Respaldo cifrado de base de datos
⏳ Certificados SSL/TLS
⏳ Políticas de contraseña más estrictas
⏳ Auditoría detallada de cambios
⏳ Límites de intentos de login
```

---

## 14. USO DE LA APLICACIÓN

### Flujo de Uso Típico

#### Para Empleados (Vendedores)

```
1. Abrir aplicación
        ↓
2. Pantalla de Login
        ↓
3. Ingresar credenciales
        ↓
4. Se verifica contra BD
        ↓
5. Si es Empleado → Ir directo a TPV
        ↓
6. Seleccionar productos
        ↓
7. Agregar al carrito
        ↓
8. Revisar total
        ↓
9. Aplicar descuento (si aplica)
        ↓
10. Confirmar venta
        ↓
11. Generar ticket
        ↓
12. Venta guardada en BD
```

#### Para Administradores

```
1. Abrir aplicación
        ↓
2. Pantalla de Login
        ↓
3. Ingresar credenciales
        ↓
4. Si es Admin → Panel de Control
        ↓
5. Menú con opciones:
   - Ver Estadísticas
   - Gestionar Productos
   - Gestionar Usuarios
   - Ver Historial de Ventas
   - Módulo de Producción
   - Módulo de Distribución
   - Configuración
        ↓
6. Seleccionar módulo
        ↓
7. Ejecutar operaciones
        ↓
8. Cambios sincronizados a BD
```

### Pantalla de Login

**Usuarios de Prueba:**

| Usuario | Contraseña | Rol |
|---------|-----------|-----|
| `admin` | `admin123` | Administrador |
| `empleado` | `1234` | Empleado |

**Proceso:**
1. Ingresa nombre de usuario
2. Ingresa contraseña
3. Presiona "Iniciar Sesión"
4. Sistema valida contra BD
5. Si es correcto → Acceso permitido
6. Si es incorrecto → Mostrar error

### Uso del TPV

**Pasos:**
1. Seleccionar producto del catálogo (buscar o filtrar)
2. Producto se agrega al carrito
3. Ajustar cantidad (+/-)
4. Ver total actualizado automáticamente
5. (Opcional) Aplicar descuento porcentual
6. Presionar "Confirmar Venta"
7. Se guarda en BD
8. Se genera y muestra ticket

### Gestión de Productos (Admin)

**Pasos:**
1. Ir a "Gestión de Productos"
2. Ver lista de productos
3. Opciones:
   - **Crear:** Llenar formulario y guardar
   - **Editar:** Modificar datos existentes
   - **Eliminar:** Confirmar eliminación
   - **Ver:** Detalles del producto

---

## 15. TECNOLOGÍAS UTILIZADAS

### Framework y Lenguaje

| Tecnología | Versión | Propósito |
|-----------|---------|----------|
| **Flutter** | 3.0.0+ | Framework UI multiplataforma |
| **Dart** | 3.0.0+ | Lenguaje de programación |

### Gestión de Estado

| Paquete | Versión | Uso |
|---------|---------|-----|
| **Provider** | 6.0.0 | Inyección de dependencias y estado |

### Base de Datos y Persistencia

| Paquete | Versión | Uso |
|---------|---------|-----|
| **sqflite** | 2.3.0 | Base de datos SQLite local |
| **shared_preferences** | 2.2.2 | Almacenamiento de preferencias |
| **firebase_core** | 4.6.0 | Inicialización Firebase |
| **cloud_firestore** | 6.2.0 | Base de datos en la nube |
| **firebase_storage** | 13.2.0 | Almacenamiento de archivos |
| **firebase_auth** | 6.3.0 | Autenticación Firebase |

### UI y Diseño

| Paquete | Versión | Uso |
|---------|---------|-----|
| **cupertino_icons** | 1.0.8 | Iconos Material |
| **google_fonts** | 6.0.0 | Tipografías de Google |
| **fl_chart** | 0.65.0 | Gráficos y charts |

### Utilidades

| Paquete | Versión | Uso |
|---------|---------|-----|
| **intl** | 0.18.0 | Internacionalización y formato |
| **uuid** | 4.0.0 | Generación de IDs únicos |
| **image_picker** | 1.0.0 | Selector de imágenes |
| **path_provider** | 2.1.0 | Acceso a directorios del sistema |
| **file_saver** | 0.3.1 | Guardar archivos |

### Seguridad

| Paquete | Versión | Uso |
|---------|---------|-----|
| **crypto** | 3.0.0 | Hashing de contraseñas |
| **pointycastle** | 3.7.0 | Criptografía avanzada |

### Reportes

| Paquete | Versión | Uso |
|---------|---------|-----|
| **pdf** | 3.10.0 | Generación de PDFs |
| **url_launcher** | 6.3.2 | Abrir URLs |

### Navegación

| Paquete | Versión | Uso |
|---------|---------|-----|
| **go_router** | 12.0.0 | Sistema de rutas avanzado |

### Conectividad

| Paquete | Versión | Uso |
|---------|---------|-----|
| **connectivity_plus** | 5.0.0 | Detección de conexión |
| **device_info_plus** | 9.0.0 | Información del dispositivo |

---

## 16. FUTURAS MEJORAS

### Corto Plazo (1-3 meses)

- [ ] Completar módulo de Gestión de Materia Prima
  - CRUD completo
  - Alertas de stock bajo
  - Gestión de proveedores

- [ ] Completar módulo de Producción
  - Creación de recetas
  - Registro de fabricación
  - Cálculo de costos

- [ ] Completar módulo de Distribución
  - Registro de entregas
  - Seguimiento de envíos

- [ ] Gestión de Usuarios completa
  - CRUD de usuarios
  - Asignación de roles
  - Cambio de contraseñas

### Mediano Plazo (3-6 meses)

- [ ] Sistema de Reportes avanzado
  - Reporte de ventas por período
  - Análisis de productos más vendidos
  - Análisis de tendencias
  - Exportación a PDF/Excel

- [ ] Mejoras de UI/UX
  - Temas personalizables adicionales
  - Modo oscuro completo
  - Animaciones mejoradas
  - Accesibilidad (a11y)

- [ ] Funcionalidades avanzadas
  - Descuentos por cliente
  - Promociones automáticas
  - Programación de horarios
  - Gestión de caja

- [ ] Sincronización mejorada
  - Sincronización en tiempo real
  - Resolución de conflictos
  - Compresión de datos

### Largo Plazo (6-12 meses)

- [ ] API REST
  - Endpoints CRUD
  - Autenticación con JWT
  - Rate limiting
  - Documentación OpenAPI

- [ ] Aplicación Móvil Nativa (si es necesario)
  - App Android en Play Store
  - App iOS en App Store
  - Sincronización con web

- [ ] Dashboard Web
  - Versión web completa
  - Análisis avanzado
  - Integración con BI

- [ ] Características Empresariales
  - Multi-sucursal
  - Multi-moneda
  - Control de impuestos
  - Cumplimiento normativo

- [ ] Integraciones Externas
  - Pasarelas de pago
  - ERP empresarial
  - Sistemas de facturación
  - Proveedores

- [ ] Optimizaciones
  - Caché agresivo
  - Precarga de datos
  - Compresión de imágenes
  - Optimización de BD

---

## 17. CONCLUSIONES

### Logros Alcanzados

✅ **Migración exitosa** de arquitectura monolítica a aplicación multiplataforma
✅ **Mejora significativa** de la experiencia de usuario
✅ **Escalabilidad** hacia infraestructura en la nube
✅ **Multiplicación de plataformas** soportadas (de 3 a 6)
✅ **Sincronización en tiempo real** mediante Firebase
✅ **Arquitectura moderna** basada en capas y patrones de diseño

### Impacto del Proyecto

**Para el usuario final:**
- Acceso desde cualquier dispositivo
- Interfaz intuitiva y responsiva
- Sincronización automática de datos
- Mejor rendimiento
- Confiabilidad mejorada

**Para el desarrollador:**
- Código más mantenible
- Mejor separación de responsabilidades
- Testing más sencillo
- Escalabilidad facilitada
- Código reutilizable

### Lecciones Aprendidas

1. **Importancia de la arquitectura** - Una buena arquitectura facilita mantenimiento y escalabilidad
2. **Gestión de estado** - Provider es excelente para aplicaciones medianas
3. **Multiplataforma** - Flutter permite desarrollo eficiente para múltiples plataformas
4. **Sincronización de datos** - Firebase Firestore simplifica la sincronización en la nube
5. **Testing** - Separar lógica de presentación facilita testing

### Recomendaciones

**Para mantenimiento:**
1. Mantener código limpio y documentado
2. Realizar testing regularmente
3. Mantener dependencias actualizadas
4. Realizar backups regulares
5. Monitorear rendimiento

**Para expansión futura:**
1. Considerar microservicios para API
2. Implementar CI/CD
3. Realizar pruebas de carga
4. Establecer SLA de disponibilidad
5. Implementar monitoreo y alertas

### Reflexión Final

Este proyecto demuestra la viabilidad de migrar aplicaciones de escritorio tradicionales a soluciones multiplataforma modernas, mejorando significativamente la experiencia del usuario y la mantenibilidad del código, mientras se prepara la infraestructura para escalabilidad futura.

---

## 📞 INFORMACIÓN TÉCNICA ADICIONAL

### Compilación y Distribución

#### Génerar APK para Android
```bash
flutter build apk --release
# Archivo: build/app/outputs/flutter-app.apk
```

#### Generar App Bundle para Play Store
```bash
flutter build appbundle --release
# Archivo: build/app/outputs/app.aab
```

#### Construir para Web
```bash
flutter build web --release
# Directorio: build/web/
```

#### Construir para Windows
```bash
flutter build windows --release
# Directorio: build/windows/runner/Release/
```

### Debugging

#### Modo Debug
```bash
flutter run -d <device_id>
flutter run --debug
```

#### Modo Release
```bash
flutter run --release
```

#### Logs
```bash
flutter logs
```

### Performance

#### Análisis de Performance
```bash
flutter run --profile
# Usar DevTools para análisis
```

#### DevTools
```bash
flutter pub global activate devtools
devtools
```

---

## 📄 REFERENCIAS Y RECURSOS

### Documentación Oficial
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Firebase Docs](https://firebase.google.com/docs)
- [Material Design](https://material.io/design)

### Paquetes Utilizados
- [Provider](https://pub.dev/packages/provider)
- [sqflite](https://pub.dev/packages/sqflite)
- [Firebase Core](https://pub.dev/packages/firebase_core)
- [GoRouter](https://pub.dev/packages/go_router)

### Libros y Tutoriales
- Flutter in Action - Eric Windmill
- The Complete Flutter Development Course
- Dart Fundamentals

---

## 📝 HISTORIAL DE VERSIONES

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0.0 | Febrero 2026 | Release inicial |
| 0.9.0 | Enero 2026 | Beta con funcionalidades principales |
| 0.5.0 | Diciembre 2025 | Alpha inicial |

---

## 📧 CONTACTO Y SOPORTE

**Para reportar bugs:** [GitHub Issues](https://github.com/usuario/panaderia-liz/issues)

**Para sugerencias:** [Discussions](https://github.com/usuario/panaderia-liz/discussions)

**Email:** [tu-email@ejemplo.com]

---

## ⚖️ LICENCIA

Este proyecto está bajo licencia [especificar licencia].

**Derechos de autor © 2026 [Tu Nombre/Institución]**

---

**Documento generado:** 2026
**Última actualización:** Febrero 2026
**Versión del documento:** 1.0

