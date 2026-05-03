import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:panaderia_liz/config/constants.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/services/index.dart';
import 'package:panaderia_liz/utils/formatters.dart';
import 'package:panaderia_liz/utils/validators.dart';
import 'package:panaderia_liz/widgets/index.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class ProductsManagementScreen extends StatefulWidget {
  const ProductsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductsManagementScreen> createState() =>
      _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  late ProductServiceDB _productService;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productService = ProductServiceDB();
    _searchController.addListener(_filterProducts);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final products = await _productService.getAllProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error cargando productos')),
        );
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((product) =>
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query) ||
              product.id.toLowerCase().contains(query))
          .toList();
    });
  }

  void _showProductDialog({Product? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final stockController =
        TextEditingController(text: product?.stock.toString() ?? '');
    final categoryController =
        TextEditingController(text: product?.category ?? '');
    final formKey = GlobalKey<FormState>();
    XFile? selectedImage;
    String? imageUrl = product?.imageUrl;
    bool isUploadingImage = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImagePickerWidget(
                    existingImageUrl: imageUrl,
                    onImageSelected: (image) {
                      selectedImage = image;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    validator: Validators.validateProductName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                    labelText: 'Precio (\$)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.validatePrice,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: stockController,
                    decoration: InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateQuantity,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    validator: (value) => Validators.validateNotEmpty(
                      value,
                      label: 'Categoría',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isUploadingImage
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      setDialogState(() => isUploadingImage = true);

                      try {
                        final price = double.parse(priceController.text);
                        final stock = int.parse(stockController.text);
                        String? finalImageUrl = imageUrl;

                        // Upload new image if selected
                        if (selectedImage != null) {
                          final imageStorage = ImageStorageService();
                          final productId = isEditing ? product.id : const Uuid().v4();
                          finalImageUrl = await imageStorage.uploadProductImage(
                            productId,
                            selectedImage!,
                          );

                          if (finalImageUrl == null && mounted) {
                            String message = kIsWeb
                                ? '⚠ En Web: Las imágenes se muestran localmente. Para producción, configura CORS en Firebase Storage'
                                : 'Error al subir imagen, pero el producto se creará sin ella';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: kIsWeb
                                    ? AppConstants.warningColor
                                    : AppConstants.errorColor,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }

                        if (isEditing) {
                          final updatedProduct = Product(
                            id: product.id,
                            name: nameController.text,
                            price: price,
                            category: categoryController.text,
                            stock: stock,
                            createdAt: product.createdAt,
                            imageUrl: finalImageUrl,
                          );
                          final success = await _productService
                              .updateProduct(updatedProduct);
                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✓ Producto actualizado'),
                                backgroundColor: AppConstants.successColor,
                              ),
                            );
                            _loadProducts();
                          }
                        } else {
                          final productId = const Uuid().v4();
                          final newProduct = await _productService.addProduct(
                            productId,
                            nameController.text,
                            price,
                            categoryController.text,
                            stock,
                          );
                          if (newProduct != null && mounted) {
                            // Update product with image URL if image was uploaded
                            if (finalImageUrl != null) {
                              final productWithImage =
                                  newProduct.copyWith(imageUrl: finalImageUrl);
                              await _productService
                                  .updateProduct(productWithImage);
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✓ Producto creado'),
                                backgroundColor: AppConstants.successColor,
                              ),
                            );
                            _loadProducts();
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setDialogState(() => isUploadingImage = false);
                        }
                      }
                    },
              child: isUploadingImage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _productService.deleteProduct(product.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Producto eliminado'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          _loadProducts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar producto'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.productsTitle),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingState(message: 'Cargando productos...')
          : Column(
              children: [
                // Búsqueda
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                // Info y contador
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Productos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_filteredProducts.length}/${_products.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Lista
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? EmptyState(
                          title: AppConstants.emptyNoProducts,
                          message: _searchController.text.isNotEmpty
                              ? 'No hay resultados para tu búsqueda'
                              : 'No hay productos registrados',
                          icon: Icons.inventory_2_outlined,
                          actionLabel: 'Crear Producto',
                          onAction: () => _showProductDialog(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product.imageUrl != null &&
                                          product.imageUrl!.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppConstants.primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.shopping_bag,
                                                color:
                                                    AppConstants.primaryColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: AppConstants.primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.shopping_bag,
                                              color:
                                                  AppConstants.primaryColor,
                                            ),
                                          ),
                                        ),
                                ),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Formatters.currency(product.price),
                                      style: const TextStyle(
                                        color: AppConstants.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Stock: ${product.stock} | ${product.category}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      onTap: () => _showProductDialog(
                                        product: product,
                                      ),
                                      child: const Text('Editar'),
                                    ),
                                    PopupMenuItem(
                                      onTap: () =>
                                          _deleteProduct(product),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () => _showProductDialog(),
        tooltip: 'Crear Producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
