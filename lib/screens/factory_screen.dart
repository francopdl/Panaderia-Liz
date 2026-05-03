import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/services/firestore_service.dart';
import 'package:panaderia_liz/services/image_storage_service.dart';
import 'package:panaderia_liz/widgets/image_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:panaderia_liz/services/auth_service_db.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class FactoryScreen extends StatefulWidget {
  const FactoryScreen({Key? key}) : super(key: key);

  @override
  State<FactoryScreen> createState() => _FactoryScreenState();
}

class _FactoryScreenState extends State<FactoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fábrica'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'Materias Primas'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Recetas'),
            Tab(icon: Icon(Icons.factory), text: 'Producción'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RawMaterialsTab(fs: _fs),
          _RecipesTab(fs: _fs),
          _ProductionTab(fs: _fs),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// RAW MATERIALS TAB
// ══════════════════════════════════════════════

class _RawMaterialsTab extends StatefulWidget {
  final FirestoreService fs;
  const _RawMaterialsTab({required this.fs});

  @override
  State<_RawMaterialsTab> createState() => _RawMaterialsTabState();
}

class _RawMaterialsTabState extends State<_RawMaterialsTab> {
  List<RawMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final materials = await widget.fs.getAllRawMaterials();
      if (!mounted) return;
      setState(() {
        _materials = materials;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Alerts for low stock
        ..._materials.where((m) => m.isLowStock).map((m) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠ ${m.name}: ${m.stock.toStringAsFixed(1)} ${m.unit} (mín: ${m.minStock.toStringAsFixed(1)})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
        Expanded(
          child: _materials.isEmpty
              ? const Center(child: Text('No hay materias primas registradas'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _materials.length,
                    itemBuilder: (ctx, i) => _materialCard(_materials[i]),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showMaterialDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar materia prima'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _materialCard(RawMaterial m) {
    final isLow = m.isLowStock;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: m.imageUrl != null && m.imageUrl!.isNotEmpty
              ? Image.network(
                  m.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                    backgroundColor: isLow ? Colors.orange : Colors.green,
                    child: Icon(
                      isLow ? Icons.warning : Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : CircleAvatar(
                  backgroundColor: isLow ? Colors.orange : Colors.green,
                  child: Icon(
                    isLow ? Icons.warning : Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
        ),
        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${m.stock.toStringAsFixed(1)} ${m.unit} • \$${m.pricePerUnit.toStringAsFixed(2)}/${m.unit}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              tooltip: 'Agregar stock',
              onPressed: () => _showAddStockDialog(m),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showMaterialDialog(material: m),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMaterial(m),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddStockDialog(RawMaterial m) async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agregar stock: ${m.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Cantidad (${m.unit})',
            hintText: 'Ej: 25.0',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) Navigator.pop(ctx, val);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (result != null) {
      await widget.fs.updateRawMaterial(
        m.copyWith(stock: m.stock + result),
      );
      _load();
    }
  }

  Future<void> _showMaterialDialog({RawMaterial? material}) async {
    final nameCtrl = TextEditingController(text: material?.name ?? '');
    final unitCtrl = TextEditingController(text: material?.unit ?? 'kg');
    final stockCtrl = TextEditingController(
        text: material?.stock.toStringAsFixed(1) ?? '0.0');
    final minCtrl = TextEditingController(
        text: material?.minStock.toStringAsFixed(1) ?? '5.0');
    final priceCtrl = TextEditingController(
        text: material?.pricePerUnit.toStringAsFixed(2) ?? '0.00');
    XFile? selectedImage;
    String? imageUrl = material?.imageUrl;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(material == null ? 'Nueva materia prima' : 'Editar ${material.name}'),
          content: SingleChildScrollView(
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
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: unitCtrl.text,
                  items: ['kg', 'litros', 'unidades', 'gramos']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => unitCtrl.text = v ?? 'kg',
                  decoration: const InputDecoration(labelText: 'Unidad'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stockCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Stock actual'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: minCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Stock mínimo'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Precio por unidad (\$)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && nameCtrl.text.isNotEmpty) {
      String? finalImageUrl = imageUrl;

      // Upload new image if selected
      if (selectedImage != null) {
        final imageStorage = ImageStorageService();
        final materialId = material?.id ?? const Uuid().v4();
        finalImageUrl = await imageStorage.uploadRawMaterialImage(
          materialId,
          selectedImage!,
        );

        if (finalImageUrl == null && mounted) {
          String message = kIsWeb
              ? '⚠ En Web: Las imágenes se muestran localmente. Para producción, configura CORS en Firebase Storage'
              : 'Error al subir imagen, pero se guardará sin ella';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: kIsWeb ? Colors.orange : Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      final m = RawMaterial(
        id: material?.id ?? const Uuid().v4(),
        name: nameCtrl.text.trim(),
        unit: unitCtrl.text,
        stock: double.tryParse(stockCtrl.text) ?? 0.0,
        minStock: double.tryParse(minCtrl.text) ?? 5.0,
        pricePerUnit: double.tryParse(priceCtrl.text) ?? 0.0,
        createdAt: material?.createdAt ?? DateTime.now(),
        imageUrl: finalImageUrl,
      );
      if (material == null) {
        await widget.fs.addRawMaterial(m);
      } else {
        await widget.fs.updateRawMaterial(m);
      }
      _load();
    }
  }

  Future<void> _deleteMaterial(RawMaterial m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar materia prima'),
        content: Text('¿Eliminar "${m.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.fs.deleteRawMaterial(m.id);
      _load();
    }
  }
}

// ══════════════════════════════════════════════
// RECIPES TAB
// ══════════════════════════════════════════════

class _RecipesTab extends StatefulWidget {
  final FirestoreService fs;
  const _RecipesTab({required this.fs});

  @override
  State<_RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<_RecipesTab> {
  List<Recipe> _recipes = [];
  List<Product> _products = [];
  List<RawMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        widget.fs.getAllRecipes(),
        widget.fs.getAllProducts(),
        widget.fs.getAllRawMaterials(),
      ]);
      if (!mounted) return;
      setState(() {
        _recipes = results[0] as List<Recipe>;
        _products = results[1] as List<Product>;
        _materials = results[2] as List<RawMaterial>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: _recipes.isEmpty
              ? const Center(child: Text('No hay recetas registradas'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _recipes.length,
                    itemBuilder: (ctx, i) => _recipeCard(_recipes[i]),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showRecipeDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Crear receta'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
        title: Text(recipe.productName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Rinde: ${recipe.outputQty} unidades'),
        children: [
          ...recipe.ingredients.map((ing) => ListTile(
                dense: true,
                leading: const Icon(Icons.circle, size: 8),
                title: Text(ing.rawMaterialName),
                trailing: Text('${ing.quantity.toStringAsFixed(2)}'),
              )),
          ButtonBar(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar'),
                onPressed: () => _showRecipeDialog(recipe: recipe),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onPressed: () => _deleteRecipe(recipe),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showRecipeDialog({Recipe? recipe}) async {
    Product? selectedProduct;
    int recipeYield = recipe?.outputQty ?? 1;
    List<_IngredientEntry> ingredients = [];

    if (recipe != null) {
      selectedProduct = _products.where((p) => p.id == recipe.productId).firstOrNull;
      ingredients = recipe.ingredients
          .map((i) => _IngredientEntry(
                materialId: i.rawMaterialId,
                materialName: i.rawMaterialName,
                quantity: i.quantity,
              ))
          .toList();
    }

    final yieldCtrl = TextEditingController(text: recipeYield.toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(recipe == null ? 'Nueva receta' : 'Editar receta'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    items: _products
                        .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                        .toList(),
                    onChanged: (p) => setDialogState(() => selectedProduct = p),
                    decoration: const InputDecoration(labelText: 'Producto'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: yieldCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Unidades que produce',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ingredientes',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () {
                          setDialogState(() {
                            ingredients.add(_IngredientEntry());
                          });
                        },
                      ),
                    ],
                  ),
                  ...ingredients.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ing = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: _materials.any((m) => m.id == ing.materialId)
                                  ? ing.materialId
                                  : null,
                              items: _materials
                                  .map((m) => DropdownMenuItem(
                                        value: m.id,
                                        child: Text(m.name, overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (id) {
                                final mat = _materials.firstWhere((m) => m.id == id);
                                setDialogState(() {
                                  ing.materialId = id ?? '';
                                  ing.materialName = mat.name;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Material',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: ing.controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Cantidad',
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                            onPressed: () {
                              setDialogState(() => ingredients.removeAt(idx));
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && selectedProduct != null) {
      final recipeIngredients = ingredients
          .where((i) => i.materialId.isNotEmpty)
          .map((i) => RecipeIngredient(
                rawMaterialId: i.materialId,
                rawMaterialName: i.materialName,
                quantity: double.tryParse(i.controller.text) ?? 0.0,
              ))
          .toList();

      final r = Recipe(
        id: recipe?.id ?? const Uuid().v4(),
        productId: selectedProduct!.id,
        productName: selectedProduct!.name,
        ingredients: recipeIngredients,
        outputQty: int.tryParse(yieldCtrl.text) ?? 1,
        createdAt: recipe?.createdAt ?? DateTime.now(),
      );

      if (recipe == null) {
        await widget.fs.addRecipe(r);
      } else {
        await widget.fs.updateRecipe(r);
      }
      _load();
    }
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar receta'),
        content: Text('¿Eliminar receta de "${recipe.productName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.fs.deleteRecipe(recipe.id);
      _load();
    }
  }
}

class _IngredientEntry {
  String materialId;
  String materialName;
  double quantity;
  late TextEditingController controller;

  _IngredientEntry({
    this.materialId = '',
    this.materialName = '',
    this.quantity = 0.0,
  }) {
    controller = TextEditingController(
      text: quantity > 0 ? quantity.toStringAsFixed(2) : '',
    );
  }
}

// ══════════════════════════════════════════════
// PRODUCTION TAB
// ══════════════════════════════════════════════

class _ProductionTab extends StatefulWidget {
  final FirestoreService fs;
  const _ProductionTab({required this.fs});

  @override
  State<_ProductionTab> createState() => _ProductionTabState();
}

class _ProductionTabState extends State<_ProductionTab> {
  List<ProductionRecord> _records = [];
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _showAll
            ? widget.fs.getAllProduction()
            : widget.fs.getTodayProduction(),
        widget.fs.getAllRecipes(),
      ]);
      if (!mounted) return;
      setState(() {
        _records = results[0] as List<ProductionRecord>;
        _recipes = results[1] as List<Recipe>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle today/all
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _showAll ? 'Historial completo' : 'Producción de hoy',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              TextButton.icon(
                icon: Icon(_showAll ? Icons.today : Icons.history),
                label: Text(_showAll ? 'Ver hoy' : 'Ver todo'),
                onPressed: () {
                  setState(() => _showAll = !_showAll);
                  _load();
                },
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: _records.isEmpty
                ? Center(
                    child: Text(
                      _showAll
                          ? 'No hay registros de producción'
                          : 'No se ha producido nada hoy',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _records.length,
                      itemBuilder: (ctx, i) => _recordCard(_records[i]),
                    ),
                  ),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _recipes.isEmpty ? null : () => _showProductionDialog(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Registrar producción'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recordCard(ProductionRecord record) {
    final time =
        '${record.createdAt.hour.toString().padLeft(2, '0')}:${record.createdAt.minute.toString().padLeft(2, '0')}';
    final date =
        '${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.factory, color: Colors.white, size: 20),
        ),
        title: Text(
          '${record.productName} × ${record.quantity}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_showAll ? date : ''} $time • ${record.userName}'
          '${record.notes != null && record.notes!.isNotEmpty ? '\n${record.notes}' : ''}',
        ),
        isThreeLine: record.notes != null && record.notes!.isNotEmpty,
      ),
    );
  }

  Future<void> _showProductionDialog() async {
    Recipe? selectedRecipe;
    final batchesCtrl = TextEditingController(text: '1');
    final notesCtrl = TextEditingController();

    final authService = context.read<AuthServiceDB>();
    final user = authService.currentUser;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final totalUnits =
              (selectedRecipe?.outputQty ?? 0) * (int.tryParse(batchesCtrl.text) ?? 0);

          return AlertDialog(
            title: const Text('Registrar producción'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Recipe>(
                    value: selectedRecipe,
                    items: _recipes
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text('${r.productName} (rinde ${r.outputQty})'),
                            ))
                        .toList(),
                    onChanged: (r) =>
                        setDialogState(() => selectedRecipe = r),
                    decoration: const InputDecoration(labelText: 'Receta'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: batchesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de tandas',
                      helperText: 'Cada tanda produce las unidades de la receta',
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  if (selectedRecipe != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Producirá: $totalUnits unidades',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Materias primas necesarias:',
                              style: TextStyle(fontSize: 12)),
                          ...selectedRecipe!.ingredients.map((ing) {
                            final needed = ing.quantity *
                                (int.tryParse(batchesCtrl.text) ?? 0);
                            return Text(
                              '  • ${ing.rawMaterialName}: ${needed.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Producir'),
                onPressed: selectedRecipe != null &&
                        (int.tryParse(batchesCtrl.text) ?? 0) > 0
                    ? () => Navigator.pop(ctx, true)
                    : null,
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true && selectedRecipe != null && user != null) {
      try {
        await widget.fs.registerProduction(
          productId: selectedRecipe!.productId,
          productName: selectedRecipe!.productName,
          recipeId: selectedRecipe!.id,
          batches: int.tryParse(batchesCtrl.text) ?? 1,
          userId: user.id,
          userName: user.username,
          notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Producción registrada con éxito')),
          );
        }
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}
