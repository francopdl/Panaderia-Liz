# ESPECIFICACIONES TÉCNICAS DETALLADAS - Panadería Liz TPV

## 📋 ÍNDICE

1. [Especificaciones de Hardware](#especificaciones-de-hardware)
2. [Especificaciones de Rendimiento](#especificaciones-de-rendimiento)
3. [API de Servicios](#api-de-servicios)
4. [Esquemas de Datos](#esquemas-de-datos)
5. [Configuración y Deployment](#configuración-y-deployment)
6. [Troubleshooting Técnico](#troubleshooting-técnico)

---

## ESPECIFICACIONES DE HARDWARE

### Dispositivos Soportados

#### Móviles Android
- **Versión Mínima:** Android 5.0 (API Level 21)
- **Versión Recomendada:** Android 10+ (API Level 29+)
- **RAM Mínima:** 2 GB
- **Almacenamiento:** 200 MB libre
- **Pantalla:** 4.5" - 6.7"

#### Dispositivos iOS
- **Versión Mínima:** iOS 11.0
- **Versión Recomendada:** iOS 14+
- **RAM Mínima:** 2 GB
- **Almacenamiento:** 200 MB libre
- **Pantalla:** 4.7" - 6.7"

#### Tablets
- **Android:** 7" - 12" - Android 5.0+
- **iPad:** 7.9" - 12.9" - iOS 11+
- **RAM:** 2 GB mínimo
- **Almacenamiento:** 500 MB

#### Escritorio
- **Windows:** Windows 10 Build 19041+
- **macOS:** 10.14+
- **Linux:** Ubuntu 18.04+, Fedora 30+
- **RAM:** 2 GB mínimo
- **Almacenamiento:** 500 MB

#### Web
- **Navegadores Soportados:**
  - Chrome/Chromium 90+
  - Firefox 88+
  - Safari 14+
  - Edge 90+
- **RAM:** 500 MB mínimo

---

## ESPECIFICACIONES DE RENDIMIENTO

### Benchmarks Esperados

#### Carga de Aplicación
- **Splash Screen:** < 2 segundos
- **Login:** < 3 segundos
- **TPV Principal:** < 4 segundos
- **Carga de Productos:** < 2 segundos (con 1000 productos)

#### Operaciones de Base de Datos
- **Búsqueda de Producto:** < 500 ms
- **Guardar Venta:** < 1 segundo
- **Cargar Historial:** < 2 segundos (100 ventas)
- **Sincronización Firestore:** < 5 segundos

#### Uso de Memoria
- **Memoria Mínima:** 50 MB
- **Memoria Promedio:** 150-200 MB
- **Memoria Pico:** 300-400 MB
- **Leak Prevention:** Monitorear con DevTools

#### Uso de Almacenamiento
- **BD SQLite:** ~5-10 MB (sin imágenes)
- **Imágenes Caché:** ~50-100 MB
- **Preferencias:** ~100 KB
- **Total:** 200-300 MB

### Optimizaciones Implementadas

```dart
// 1. Lazy Loading de Imágenes
Image.network(
  imageUrl,
  cacheWidth: 300,
  cacheHeight: 300,
)

// 2. ListView.builder en lugar de Column
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductCard(products[index]),
)

// 3. Consumer selectivo (no rebuilds innecesarios)
Consumer<CartNotifier>(
  builder: (context, cart, child) {
    return Text('${cart.getTotal()}');
  },
)

// 4. Async/Await en lugar de FutureBuilder innecesarios
Future<void> loadData() async {
  final data = await service.fetchData();
  setState(() => _data = data);
}
```

---

## API DE SERVICIOS

### AuthServiceDB

#### Método: login
```dart
Future<User?> login(String username, String password)
```
**Descripción:** Valida credenciales del usuario
**Parámetros:**
- `username` (String): Nombre de usuario
- `password` (String): Contraseña en texto plano

**Retorna:** `User` si es válido, `null` si falla

**Excepciones:** `DatabaseException`

**Ejemplo:**
```dart
final authService = context.read<AuthServiceDB>();
final user = await authService.login('admin', 'admin123');
if (user != null) {
  // Autenticación exitosa
  print('Bienvenido ${user.username}');
}
```

#### Método: logout
```dart
Future<void> logout()
```
**Descripción:** Cierra la sesión del usuario actual
**Retorna:** void

**Ejemplo:**
```dart
await authService.logout();
```

#### Método: getCurrentUser
```dart
Future<User?> getCurrentUser()
```
**Descripción:** Obtiene el usuario actualmente autenticado
**Retorna:** `User` o `null` si no hay usuario

#### Método: getAllUsers
```dart
Future<List<User>> getAllUsers()
```
**Descripción:** Obtiene lista de todos los usuarios
**Retorna:** `List<User>`

#### Método: register
```dart
Future<bool> register(User user)
```
**Descripción:** Crea un nuevo usuario
**Parámetros:** `user` (User): Nuevo usuario
**Retorna:** `true` si es exitoso

#### Método: updateUser
```dart
Future<void> updateUser(User user)
```
**Descripción:** Actualiza datos de usuario
**Parámetros:** `user` (User): Usuario con datos actualizados

#### Método: deleteUser
```dart
Future<void> deleteUser(String userId)
```
**Descripción:** Elimina un usuario del sistema
**Parámetros:** `userId` (String): ID del usuario

---

### ProductServiceDB

#### Método: getAllProducts
```dart
Future<List<Product>> getAllProducts()
```
**Descripción:** Obtiene todos los productos
**Retorna:** `List<Product>`
**Uso:** Cargar catálogo completo

#### Método: getProductById
```dart
Future<Product?> getProductById(String id)
```
**Descripción:** Obtiene producto específico
**Parámetros:** `id` (String): ID del producto
**Retorna:** `Product` o `null`

#### Método: getProductsByCategory
```dart
Future<List<Product>> getProductsByCategory(String category)
```
**Descripción:** Obtiene productos por categoría
**Parámetros:** `category` (String): Nombre de categoría
**Retorna:** `List<Product>`

#### Método: addProduct
```dart
Future<void> addProduct(Product product)
```
**Descripción:** Crea nuevo producto
**Parámetros:** `product` (Product): Nuevo producto
**Excepciones:** `ProductException` si ya existe

#### Método: updateProduct
```dart
Future<void> updateProduct(Product product)
```
**Descripción:** Actualiza producto existente
**Parámetros:** `product` (Product): Producto con cambios

#### Método: deleteProduct
```dart
Future<void> deleteProduct(String productId)
```
**Descripción:** Elimina producto
**Parámetros:** `productId` (String): ID del producto

#### Método: updateStock
```dart
Future<void> updateStock(String productId, int newStock)
```
**Descripción:** Actualiza stock de producto
**Parámetros:**
- `productId` (String): ID del producto
- `newStock` (int): Nuevo valor de stock

#### Método: getCategories
```dart
Future<List<String>> getCategories()
```
**Descripción:** Obtiene lista de categorías disponibles
**Retorna:** `List<String>` con nombres de categorías

---

### SalesServiceDB

#### Método: saveSale
```dart
Future<void> saveSale(Sale sale)
```
**Descripción:** Guarda una venta completa
**Parámetros:** `sale` (Sale): Venta a guardar
**Detalles:** 
- Crea registro en tabla `ventas`
- Crea registros en `detalles_venta`
- Actualiza stock de productos
- Sincroniza con Firestore

#### Método: getAllSales
```dart
Future<List<Sale>> getAllSales()
```
**Descripción:** Obtiene todas las ventas
**Retorna:** `List<Sale>`

#### Método: getSaleById
```dart
Future<Sale?> getSaleById(String id)
```
**Descripción:** Obtiene venta específica con detalles
**Parámetros:** `id` (String): ID de la venta
**Retorna:** `Sale` completa con ítems

#### Método: getSalesByDateRange
```dart
Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end)
```
**Descripción:** Obtiene ventas en rango de fechas
**Parámetros:**
- `start` (DateTime): Fecha inicio
- `end` (DateTime): Fecha fin
**Retorna:** `List<Sale>`

#### Método: getTotalSalesByDate
```dart
Future<double> getTotalSalesByDate(DateTime date)
```
**Descripción:** Total de ventas en una fecha específica
**Parámetros:** `date` (DateTime): Fecha
**Retorna:** `double` (Total en euros)

#### Método: getSalesCountByDate
```dart
Future<int> getSalesCountByDate(DateTime date)
```
**Descripción:** Cantidad de ventas en una fecha
**Parámetros:** `date` (DateTime): Fecha
**Retorna:** `int` (Número de transacciones)

#### Método: getProductsSoldStats
```dart
Future<Map<String, int>> getProductsSoldStats()
```
**Descripción:** Estadísticas de productos más vendidos
**Retorna:** `Map<String, int>` {productId: cantidad}

---

### CartNotifier

#### Propiedad: items
```dart
List<CartItem> get items => _items;
```
**Descripción:** Obtiene ítems actuales del carrito

#### Método: addProduct
```dart
void addProduct(Product product)
```
**Descripción:** Añade producto al carrito
**Comportamiento:** Si existe, incrementa cantidad

#### Método: removeProduct
```dart
void removeProduct(String productId)
```
**Descripción:** Elimina producto del carrito
**Parámetros:** `productId` (String): ID del producto

#### Método: updateQuantity
```dart
void updateQuantity(String productId, int quantity)
```
**Descripción:** Actualiza cantidad de producto
**Parámetros:**
- `productId` (String): ID del producto
- `quantity` (int): Nueva cantidad (mín 1)

#### Método: clearCart
```dart
void clearCart()
```
**Descripción:** Vacía el carrito completamente

#### Método: getTotal
```dart
double getTotal()
```
**Descripción:** Total final con descuento aplicado
**Retorna:** `double`

#### Método: getSubtotal
```dart
double getSubtotal()
```
**Descripción:** Subtotal antes de descuento
**Retorna:** `double`

#### Método: getDiscount
```dart
double getDiscount()
```
**Descripción:** Monto del descuento aplicado
**Retorna:** `double`

#### Método: applyDiscount
```dart
void applyDiscount(double percentage)
```
**Descripción:** Aplica descuento porcentual
**Parámetros:** `percentage` (double): 0-100
**Validación:** Si > 100, se ajusta a 100

---

## ESQUEMAS DE DATOS

### User Schema

```dart
class User {
  final String id;                  // UUID único
  final String username;            // Único en BD
  final String password;            // Hasheada (SHA-256)
  final String? email;              // Opcional
  final String role;                // 'admin' | 'employee'
  final bool isActive;              // true | false
  final DateTime createdAt;         // ISO 8601
  final DateTime? updatedAt;        // ISO 8601 | null
}
```

**Constraints:**
- `username`: 3-20 caracteres, alfanuméricos
- `password`: Mínimo 4 caracteres, hasheada
- `role`: Solo valores definidos
- `isActive`: Default true

### Product Schema

```dart
class Product {
  final String id;                  // UUID único
  final String name;                // 1-100 caracteres
  final double price;               // 0.00 - 9999.99
  final String category;            // Ref a categoría
  final int stock;                  // >= 0
  final bool isAvailable;           // true | false
  final DateTime createdAt;         // ISO 8601
  final String? imageUrl;           // URL o null
}
```

**Constraints:**
- `price`: 2 decimales
- `stock`: No negativo
- `category`: Debe existir en tabla

### Sale Schema

```dart
class Sale {
  final String id;                  // UUID único
  final String userId;              // Ref a usuario
  final double subtotal;            // Suma de ítems
  final double discountAmount;      // 0.00 o más
  final double total;               // subtotal - descuento
  final String paymentMethod;       // 'cash', 'card', etc
  final DateTime createdAt;         // ISO 8601
  final List<SaleItem> items;       // Detalles
}
```

**Constraints:**
- `total` >= 0
- `items`: Mínimo 1

### SaleItem Schema

```dart
class SaleItem {
  final String id;                  // UUID único
  final String saleId;              // Ref a venta
  final String productId;           // Ref a producto
  final String productName;         // Snapshot del nombre
  final int quantity;               // > 0
  final double unitPrice;           // Precio en momento venta
  final double subtotal;            // qty * unitPrice
}
```

---

## CONFIGURACIÓN Y DEPLOYMENT

### Variables de Entorno

#### Archivo: `.env.local` (No incluir en git)
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=panaderia-liz-production
FIREBASE_API_KEY=AIzaSyD...
FIREBASE_APP_ID=1:123...

# Database
DB_NAME=panaderia_liz.db
DB_VERSION=1

# App Configuration
APP_VERSION=1.0.0
APP_BUILD_NUMBER=1
```

#### En `pubspec.yaml`
```yaml
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.0.0'

dependencies:
  # Production dependencies
  provider: ^6.0.0
  firebase_core: ^4.6.0
  sqflite: ^2.3.0
  # ... más
```

### Configuración por Plataforma

#### Android (`android/app/build.gradle`)
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21           // Android 5.0
        targetSdkVersion 34        // Latest Android
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            signingConfig signingConfigs.release
        }
    }
}
```

#### iOS (`ios/Podfile`)
```ruby
platform :ios, '11.0'

target 'Runner' do
  flutter_root = File.expand_path(File.join(packages_path, 'flutter'))
  load File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper')
  
  flutter_ios_podfile_setup
end
```

#### Web (`web/index.html`)
```html
<!DOCTYPE html>
<html>
  <head>
    <title>Panadería Liz TPV</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body>
    <script src="main.dart.js" type="application/javascript"></script>
  </body>
</html>
```

### Build y Release

#### Crear Build Android Release
```bash
flutter build apk --release
flutter build appbundle --release
```

#### Crear Build iOS Release
```bash
flutter build ios --release
# Luego compilar en Xcode
```

#### Crear Build Web
```bash
flutter build web --release --web-renderer canvaskit
```

#### Crear Build Windows
```bash
flutter build windows --release
```

---

## TROUBLESHOOTING TÉCNICO

### Problemas Comunes

#### 1. **"No se sincroniza con Firebase"**

**Síntomas:** Los datos no aparecen en Firestore
**Causas Posibles:**
- Firebase no está inicializado
- Reglas de Firestore incorrectas
- Sin conexión a internet

**Solución:**
```dart
// Verificar inicialización
if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// Verificar conectividad
final connectivity = await Connectivity().checkConnectivity();
if (connectivity == ConnectivityResult.none) {
  print("Sin conexión");
}
```

#### 2. **"BD corrupta o con errores"**

**Síntomas:** Errores al acceder a BD
**Causas Posibles:**
- BD corrupta
- Versión incompatible
- Acceso simultáneo

**Solución:**
```dart
// Eliminar y recrear BD
await deleteDatabase('panaderia_liz.db');
await DatabaseService().initializeDatabase();
```

#### 3. **"Aplicación lenta"**

**Síntomas:** UI lenta, lag
**Causas Posibles:**
- Muchos rebuilds
- Carga de imágenes sin optimizar
- Queries complejas

**Solución:**
```dart
// Usar DevTools para profiling
// Optimizar queries con índices
// Implementar caché
// Usar repaint boundaries
```

#### 4. **"Error de memoria insuficiente"**

**Síntomas:** Crash de la app
**Causas Posibles:**
- Memory leak
- Imágenes muy grandes
- Lista grande sin virtualización

**Solución:**
```dart
// Usar ListView.builder
// Comprimir imágenes
// Monitorear con DevTools Memory
```

#### 5. **"Login no funciona"**

**Síntomas:** No se puede autenticar
**Causas Posibles:**
- Usuario no existe
- Contraseña incorrecta
- BD vacía
- Error en hash

**Verificación:**
```bash
# Conectar DB con Android Studio
adb shell
sqlite3 /data/data/com.example.panaderia_liz/databases/panaderia_liz.db
SELECT * FROM usuarios;
```

---

### Herramientas de Debugging

#### Flutter DevTools
```bash
# Iniciar DevTools
flutter pub global activate devtools
devtools

# Conectar app
flutter run
# En la salida, click en enlace DevTools
```

#### Android Studio
```bash
# Debugger integrado
# Breakpoints
# Inspeccionar variables
# Profiler
```

#### Chrome DevTools (Web)
```bash
flutter run -d chrome
# F12 abre DevTools
```

### Logs y Debugging

#### Ver logs en tiempo real
```bash
flutter logs
```

#### Logs personalizados
```dart
print('DEBUG: $variable');
debugPrint('DEBUG: $variable');
log('DEBUG: $variable', name: 'MyApp');
```

#### Nivel de logs
```dart
import 'dart:developer' as developer;

developer.log(
  'Mensaje',
  level: 800,
  name: 'MyApp.LoginScreen'
);
```

---

**Documento de Especificaciones Técnicas - Versión 1.0**
**Última actualización: Febrero 2026**

