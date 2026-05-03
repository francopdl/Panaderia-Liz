import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panaderia_liz/config/constants.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/models/product_category.dart';
import 'package:panaderia_liz/services/index.dart';
import 'package:panaderia_liz/utils/formatters.dart';
import 'package:panaderia_liz/widgets/index.dart';

class TPVScreen extends StatefulWidget {
  const TPVScreen({Key? key}) : super(key: key);

  @override
  State<TPVScreen> createState() => _TPVScreenState();
}

class _TPVScreenState extends State<TPVScreen> {
  late ProductServiceDB _productService;
  late SalesServiceDB _salesService;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<ProductCategory> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  bool _isProcessing = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productService = ProductServiceDB();
    _salesService = SalesServiceDB();
    _searchController.addListener(_filterProducts);
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = ProductCategory.getAll();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.getAllProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar productos')),
        );
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((product) {
            final matchesSearch = product.name.toLowerCase().contains(query) ||
                product.id.toLowerCase().contains(query);
            final matchesCategory = _selectedCategory == null ||
                product.category == _selectedCategory;
            return matchesSearch && matchesCategory;
          })
          .toList();
    });
  }

  void _selectCategory(String? categoryId) {
    setState(() {
      _selectedCategory = categoryId == _selectedCategory ? null : categoryId;
    });
    _filterProducts();
  }

  Future<void> _confirmSale() async {
    final cartNotifier = context.read<CartNotifier>();
    final authService = context.read<AuthServiceDB>();

    if (cartNotifier.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    // Mostrar diálogo de método de pago
    final paymentMethod = await _showPaymentMethodDialog();
    if (paymentMethod == null) {
      return; // Usuario canceló
    }

    setState(() => _isProcessing = true);

    try {
      final sale = await _salesService.saveSaleWithTransaction(
        authService.currentUser?.id ?? 'unknown',
        cartNotifier.items,
        cartNotifier.total,
        paymentMethod: paymentMethod.code,
      );

      if (mounted) {
        if (sale != null) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('✓ Venta Realizada'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.currency(cartNotifier.total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Artículos: ${cartNotifier.totalQuantity}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${sale.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          cartNotifier.clear();
          _loadProducts();

          // Notify SalesNotifier so history updates in real-time
          if (mounted) {
            context.read<SalesNotifier>().addSale(sale);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('❌ Error en la transacción. Verifica stock y conexión.'),
              backgroundColor: AppConstants.errorColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        print('Error en venta: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
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

  Future<PaymentMethod?> _showPaymentMethodDialog() async {
    return showDialog<PaymentMethod>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Método de Pago'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final method in PaymentMethod.values)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Text(method.icon, style: const TextStyle(fontSize: 24)),
                    title: Text(method.displayName),
                    onTap: () => Navigator.pop(context, method),
                    selected: false,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TPV - Panadería Liz'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Consumer<CartNotifier>(
                builder: (context, cart, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Carrito: ${cart.totalQuantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Cargando productos...')
          : Row(
              children: [
                // Productos
                Expanded(
                  flex: isMobile ? 1 : 2,
                  child: Container(
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        // Search
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar producto...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        // Categorías
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _categories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: const Text('Todos'),
                                    selected: _selectedCategory == null,
                                    onSelected: (selected) {
                                      _selectCategory(null);
                                    },
                                    backgroundColor: Colors.grey[200],
                                    selectedColor: AppConstants.primaryColor,
                                    labelStyle: TextStyle(
                                      color: _selectedCategory == null
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }
                              final category = _categories[index - 1];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text('${category.icon} ${category.name}'),
                                  selected: _selectedCategory == category.id,
                                  onSelected: (selected) {
                                    _selectCategory(category.id);
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: Color(category.color),
                                  labelStyle: TextStyle(
                                    color: _selectedCategory == category.id
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Producto list
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Productos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_filteredProducts.length} disponibles',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Productos grid
                        Expanded(
                          child: _filteredProducts.isEmpty
                              ? EmptyState(
                                  title: AppConstants.emptyNoProducts,
                                  message: _searchController.text.isNotEmpty
                                      ? 'No hay resultados para "${_searchController.text}"'
                                      : 'Carga en progreso...',
                                  icon: Icons.inventory_2_outlined,
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isMobile ? 2 : 3,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: _filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = _filteredProducts[index];
                                    return ProductCard(
                                      productId: product.id,
                                      name: product.name,
                                      price: product.price,
                                      imageUrl: product.imageUrl,
                                      onPressed: product.stock > 0
                                          ? () {
                                              context.read<CartNotifier>()
                                                  .addProduct(
                                                product.id,
                                                product.name,
                                                product.price,
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          '${product.name} añadido',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 500,
                                                  ),
                                                  behavior: SnackBarBehavior.floating,
                                                  margin: const EdgeInsets.only(
                                                    left: 16,
                                                    right: 380,
                                                    bottom: 20,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  backgroundColor: Colors.green[600],
                                                  elevation: 6.0,
                                                ),
                                              );
                                            }
                                          : () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Sin stock disponible'),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Carrito
                Container(
                  width: isMobile ? MediaQuery.of(context).size.width : 350,
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: AppConstants.primaryColor,
                        child: const Text(
                          'Carrito de Compra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Items
                      Expanded(
                        child: Consumer<CartNotifier>(
                          builder: (context, cart, _) {
                            if (cart.items.isEmpty) {
                              return EmptyState(
                                title: 'Carrito vacío',
                                message: 'Agrega productos para comenzar',
                                icon: Icons.shopping_cart_outlined,
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) {
                                final item = cart.items[index];
                                return CartItemWidget(
                                  item: item,
                                  onIncrease: () {
                                    cart.updateQuantity(
                                      item.productId,
                                      item.quantity + 1,
                                    );
                                  },
                                  onDecrease: () {
                                    if (item.quantity > 1) {
                                      cart.updateQuantity(
                                        item.productId,
                                        item.quantity - 1,
                                      );
                                    } else {
                                      cart.removeProduct(item.productId);
                                    }
                                  },
                                  onRemove: () {
                                    cart.removeProduct(item.productId);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Total & Button
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Consumer<CartNotifier>(
                          builder: (context, cart, _) => Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    Formatters.currency(cart.total),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: AppConstants.buttonHeight,
                                child: ElevatedButton(
                                  onPressed: cart.items.isEmpty ||
                                          _isProcessing
                                      ? null
                                      : _confirmSale,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppConstants.primaryColor,
                                    disabledBackgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius,
                                      ),
                                    ),
                                  ),
                                  child: _isProcessing
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Confirmar Venta',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
