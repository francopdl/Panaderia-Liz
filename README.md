# 🍞 Panadería Liz - Sistema de TPV

Una aplicación multiplataforma Flutter para gestionar un sistema de punto de venta (TPV) con autenticación de usuarios y roles.

## ✨ Características

### 🔐 Autenticación
- Login con usuario y contraseña
- Validación contra datos locales
- Gestión de sesiones
- Dos roles: Admin y Empleado

### 👥 Gestión de Roles

#### Admin
- Acceso a panel de control
- Visualización de estadísticas
- Acceso a todos los módulos
- Navegación entre secciones

#### Empleado
- Acceso directo al TPV
- Sistema de venta rápida
- Gestión de carrito
- Sin acceso a configuración

### 🛒 Sistema TPV (Punto de Venta)

- Grid de productos con diseño responsivo
- Carrito de compra en tiempo real
- Incremento/decremento de cantidades
- Cálculo automático de totales
- Confirmación y guardado de ventas
- Interfaz optimizada para tablet, móvil y escritorio

### 📊 Estadísticas
- Total de ventas registradas
- Ingresos totales
- Historial de órdenes

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la app
├── config/                   # Configuración
│   ├── router.dart          # Rutas y navegación
│   └── theme.dart           # Tema y estilos globales
├── models/                   # Modelos de datos
│   ├── user.dart            # Modelo de usuario
│   ├── product.dart         # Modelo de producto
│   ├── cart.dart            # Modelo de carrito
│   ├── order.dart           # Modelo de orden
│   └── index.dart
├── services/                 # Servicios de negocio
│   ├── auth_service.dart    # Servicio de autenticación
│   ├── product_service.dart # Gestión de productos
│   ├── cart_notifier.dart   # Estado del carrito (Provider)
│   ├── order_service.dart   # Gestión de órdenes
│   └── index.dart
├── screens/                  # Pantallas principales
│   ├── login_screen.dart    # Pantalla de login
│   ├── home_screen.dart     # Panel de control (Admin)
│   ├── tpv_screen.dart      # Sistema TPV
│   └── index.dart
└── widgets/                  # Widgets reutilizables
    ├── primary_button.dart  # Botón principal
    ├── custom_text_field.dart # Campo de texto personalizado
    ├── product_card.dart    # Tarjeta de producto
    ├── cart_item_widget.dart # Widget de item en carrito
    └── index.dart
```

## 🚀 Inicio Rápido

### Requisitos Previos
- Flutter SDK 3.0.0 o superior
- Dart 3.0.0 o superior

### Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd panaderia_liz
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**

**En dispositivo móvil/emulador:**
```bash
flutter run
```

**En web:**
```bash
flutter run -d chrome
```

**En escritorio (Windows):**
```bash
flutter run -d windows
```

**En escritorio (macOS):**
```bash
flutter run -d macos
```

## 🔐 Credenciales de Prueba

### Admin
- **Usuario:** admin
- **Contraseña:** admin123
- **Acceso:** Panel de control completo

### Empleado
- **Usuario:** empleado
- **Contraseña:** 1234
- **Acceso:** TPV directo

## 📦 Productos Iniciales (Mock)

| Producto | Precio |
|----------|--------|
| Pan | 1.00€ |
| Barra | 0.80€ |
| Croissant | 1.20€ |
| Donut | 0.90€ |
| Magdalena | 0.70€ |
| Baguette | 1.50€ |

## 🛠️ Dependencias Principales

```yaml
- provider: Estado y notificaciones
- sqflite: Base de datos local
- intl: Internacionalización
- uuid: Generación de IDs únicos
- google_fonts: Tipografía
- go_router: Navegación avanzada (preparado para futura implementación)
```

## 🎨 Diseño y UI/UX

- **Tema:** Material Design 3
- **Colores:** Naranja (#FF7A00) como color principal
- **Tipografía:** Google Fonts (Roboto)
- **Responsividad:** Adaptado para móvil, tablet y escritorio
- **Accesibilidad:** Contraste adecuado, tamaños legibles

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔄 Flujo de la Aplicación

```
1. Login → Validación de credenciales
2. Si Admin → Home (Panel de control)
3. Si Empleado → TPV (Venta directa)
4. En TPV:
   - Seleccionar productos
   - Añadir al carrito
   - Ajustar cantidades
   - Confirmar venta
5. Guardar orden y limpiar carrito
```

## 🎯 Funcionalidades Implementadas

### Login ✅
- Validación de usuario/contraseña
- Gestión de sesión
- Mensajes de error
- Redirección según rol

### TPV ✅
- Grid de productos responsivo
- Carrito en tiempo real
- Incremento/decremento de cantidad
- Cálculo de totales
- Confirmación de venta
- Limpieza de carrito

### Admin Panel ✅
- Bienvenida personalizada
- Estadísticas (ventas, ingresos)
- Menú de módulos
- Navegación a TPV

### Navegación ✅
- Rutas dinámicas según rol
- Sesión persistente durante la app
- Logout funcional

## 🚧 Mejoras Futuras

- [ ] Persistencia de datos en SQLite
- [ ] Implementar módulo de productos (CRUD)
- [ ] Módulo de usuarios completamente funcional
- [ ] Historial detallado de ventas
- [ ] Reportes y estadísticas avanzadas
- [ ] Sincronización en la nube
- [ ] Impresión de tickets
- [ ] Foto de productos
- [ ] Categorías avanzadas
- [ ] Sistema de promociones

## 📝 Notas de Desarrollo

### Estado (Provider Pattern)
Se utiliza Provider para manejar el estado del carrito y mantener la reactividad en la UI.

### Modelos
Los modelos incluyen métodos `fromMap()` y `toMap()` para serialización futura en SQLite.

### Servicios
Los servicios implementan pequeños delays para simular operaciones asincrónicas, preparados para futuras integraciones con APIs.

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la Licencia MIT.

## 👨‍💻 Autor

Desarrollado como solución completa de TPV para Panadería Liz

---

**Versión:** 1.0.0  
**Última actualización:** 2026
