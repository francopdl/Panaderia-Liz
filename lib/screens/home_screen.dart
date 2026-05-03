import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panaderia_liz/config/constants.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/services/index.dart';
import 'package:panaderia_liz/utils/formatters.dart';
import 'package:panaderia_liz/widgets/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SalesServiceDB _salesService;
  late ProductServiceDB _productService;
  late SalesNotifier _salesNotifier;
  int _totalSales = 0;
  double _totalRevenue = 0.0;
  double _daySales = 0.0;
  int _productCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _salesService = SalesServiceDB();
    _productService = ProductServiceDB();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _salesNotifier = context.read<SalesNotifier>();
      _salesNotifier.addListener(_onSalesChanged);
      _loadStats();
    });
  }

  @override
  void dispose() {
    _salesNotifier.removeListener(_onSalesChanged);
    super.dispose();
  }

  void _onSalesChanged() {
    if (!mounted) return;
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final salesCount = await _salesService.getSalesCount();
      final revenue = await _salesService.getTotalSalesAmount();
      final daySales = await _salesService.getDailyTotal();
      final products = await _productService.getAllProducts();
      if (mounted) {
        setState(() {
          _totalSales = salesCount;
          _totalRevenue = revenue;
          _daySales = daySales;
          _productCount = products.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final authService = context.read<AuthServiceDB>();
    await authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthServiceDB>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.homeTitle),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Bienvenido, ${authService.currentUser?.username ?? 'Admin'}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.of(context).pushNamed('/settings');
                },
                child: const Text('Mi Configuración'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Cargando estadísticas...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryLight,
                          AppConstants.primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConstants.appTitle,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rol: ${authService.currentUser?.role.name.toUpperCase() ?? 'DESCONOCIDO'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats Section
                  const Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: isMobile ? 2 : 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatsCard(
                        title: 'Total Ventas',
                        value: _totalSales.toString(),
                        icon: Icons.shopping_cart_outlined,
                        backgroundColor: Colors.blue,
                      ),
                      StatsCard(
                        title: 'Ingresos',
                        value: Formatters.currency(_totalRevenue),
                        icon: Icons.attach_money,
                        backgroundColor: AppConstants.accentColor,
                      ),
                      StatsCard(
                        title: 'Hoy',
                        value: Formatters.currency(_daySales),
                        icon: Icons.calendar_today,
                        backgroundColor: Colors.purple,
                      ),
                      StatsCard(
                        title: 'Productos',
                        value: _productCount.toString(),
                        icon: Icons.inventory_2_outlined,
                        backgroundColor: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Menu Section
                  const Text(
                    'Módulos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: isMobile ? 2 : 3,
                    crossAxisSpacing: AppConstants.defaultMargin,
                    mainAxisSpacing: AppConstants.defaultMargin,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _MenuCard(
                        icon: Icons.shopping_cart_rounded,
                        title: 'TPV',
                        description: 'Sistema de punto de venta',
                        onTap: () async {
                          await Navigator.of(context).pushNamed('/tpv');
                          _loadStats();
                        },
                      ),
                      _MenuCard(
                        icon: Icons.history_rounded,
                        title: 'Historial',
                        description: 'Ventas realizadas',
                        onTap: () async {
                          await Navigator.of(context).pushNamed('/sales-history');
                          _loadStats();
                        },
                      ),
                      _MenuCard(
                        icon: Icons.store_rounded,
                        title: 'Productos',
                        description: 'Gestión de productos',
                        onTap: () async {
                          await Navigator.of(context).pushNamed('/products');
                          _loadStats();
                        },
                      ),
                      _MenuCard(
                        icon: Icons.people_rounded,
                        title: 'Usuarios',
                        description: 'Gestión de usuarios',
                        onTap: () {
                          Navigator.of(context).pushNamed('/users');
                        },
                      ),
                      _MenuCard(
                        icon: Icons.settings_rounded,
                        title: 'Configuración',
                        description: 'Mi configuración',
                        onTap: () {
                          Navigator.of(context).pushNamed('/settings');
                        },
                      ),
                      _MenuCard(
                        icon: Icons.factory_rounded,
                        title: 'Fábrica',
                        description: 'Producción y materias primas',
                        onTap: () async {
                          await Navigator.of(context).pushNamed('/factory');
                          _loadStats();
                        },
                      ),
                      _MenuCard(
                        icon: Icons.delivery_dining_rounded,
                        title: 'Reparto',
                        description: 'Gestión de pedidos y entregas',
                        onTap: () async {
                          await Navigator.of(context).pushNamed('/delivery');
                          _loadStats();
                        },
                      ),
                      _MenuCard(
                        icon: Icons.info_rounded,
                        title: 'Acerca de',
                        description: 'Información de la app',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: AppConstants.appName,
                            applicationVersion: AppConstants.appVersion,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            gradient: LinearGradient(
              colors: [
                Colors.grey[50]!,
                Colors.grey[100]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
