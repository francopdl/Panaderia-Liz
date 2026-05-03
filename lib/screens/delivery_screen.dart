import 'package:flutter/material.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/services/firestore_service.dart';
import 'package:panaderia_liz/services/auth_service_db.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _fs = FirestoreService();

  List<DeliveryOrder> _activeOrders = [];
  List<DeliveryOrder> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _fs.getActiveDeliveryOrders(),
        _fs.getAllDeliveryOrders(),
      ]);
      if (!mounted) return;
      setState(() {
        _activeOrders = results[0] as List<DeliveryOrder>;
        _allOrders = results[1] as List<DeliveryOrder>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reparto'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Activos'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(),
                _buildHistoryTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOrderDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo pedido'),
      ),
    );
  }

  // ── Active Orders Tab ──

  Widget _buildActiveTab() {
    if (_activeOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delivery_dining, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay pedidos activos',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _activeOrders.length,
        itemBuilder: (ctx, i) => _orderCard(_activeOrders[i]),
      ),
    );
  }

  // ── History Tab ──

  Widget _buildHistoryTab() {
    final completed = _allOrders
        .where((o) =>
            o.status == DeliveryStatus.delivered ||
            o.status == DeliveryStatus.cancelled)
        .toList();

    if (completed.isEmpty) {
      return const Center(child: Text('No hay entregas anteriores'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: completed.length,
        itemBuilder: (ctx, i) => _orderCard(completed[i], showActions: false),
      ),
    );
  }

  // ── Order Card ──

  Widget _orderCard(DeliveryOrder order, {bool showActions = true}) {
    final statusColor = _statusColor(order.status);
    final time =
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';
    final date =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor,
              child: Icon(_statusIcon(order.status), color: Colors.white, size: 20),
            ),
            title: Text(
              order.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📍 ${order.address}'),
                if (order.customerPhone.isNotEmpty)
                  Text('📞 ${order.customerPhone}'),
                Text('$date $time • \$${order.total.toStringAsFixed(2)}'),
                if (order.assignedUserName != null)
                  Text('🚗 ${order.assignedUserName}'),
              ],
            ),
            trailing: Chip(
              label: Text(
                order.status.label,
                style: TextStyle(color: statusColor, fontSize: 11),
              ),
              backgroundColor: statusColor.withOpacity(0.1),
              side: BorderSide(color: statusColor),
            ),
            isThreeLine: true,
          ),
          // Items summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: order.items
                  .map((item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity}× ${item.productName}',
                              style: const TextStyle(fontSize: 13)),
                          Text('\$${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ))
                  .toList(),
            ),
          ),
          if (order.notes != null && order.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.note, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(order.notes!,
                        style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey)),
                  ),
                ],
              ),
            ),
          if (showActions) _orderActions(order),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _orderActions(DeliveryOrder order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: [
          // Open in Google Maps
          if (order.address.isNotEmpty)
            ActionChip(
              avatar: const Icon(Icons.map, size: 18),
              label: const Text('Ver mapa'),
              onPressed: () => _openInMaps(order),
            ),
          // Status transitions
          ..._getStatusActions(order),
        ],
      ),
    );
  }

  List<Widget> _getStatusActions(DeliveryOrder order) {
    final user = context.read<AuthServiceDB>().currentUser;
    switch (order.status) {
      case DeliveryStatus.pending:
        return [
          ActionChip(
            avatar: const Icon(Icons.person_add, size: 18),
            label: const Text('Asignar'),
            onPressed: () => _assignOrder(order),
          ),
          ActionChip(
            avatar: const Icon(Icons.cancel, size: 18, color: Colors.red),
            label: const Text('Cancelar'),
            onPressed: () => _updateStatus(order, DeliveryStatus.cancelled),
          ),
        ];
      case DeliveryStatus.preparing:
        return [
          ActionChip(
            avatar: const Icon(Icons.delivery_dining, size: 18),
            label: const Text('En camino'),
            onPressed: () =>
                _updateStatus(order, DeliveryStatus.onTheWay),
          ),
          ActionChip(
            avatar: const Icon(Icons.cancel, size: 18, color: Colors.red),
            label: const Text('Cancelar'),
            onPressed: () => _updateStatus(order, DeliveryStatus.cancelled),
          ),
        ];
      case DeliveryStatus.onTheWay:
        return [
          ActionChip(
            avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
            label: const Text('Entregado'),
            onPressed: () =>
                _updateStatus(order, DeliveryStatus.delivered),
          ),
        ];
      default:
        return [];
    }
  }

  // ── Actions ──

  Future<void> _openInMaps(DeliveryOrder order) async {
    final query = Uri.encodeComponent(order.address);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _updateStatus(DeliveryOrder order, DeliveryStatus status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar estado'),
        content: Text(
            '¿Cambiar "${order.customerName}" a "${status.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _fs.updateDeliveryStatus(order.id, status);
      _load();
    }
  }

  Future<void> _assignOrder(DeliveryOrder order) async {
    final users = await _fs.getAllUsers();
    if (!mounted) return;

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Asignar repartidor'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: users
                .map((u) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(u['username'] as String),
                      subtitle: Text(u['role'] as String),
                      onTap: () => Navigator.pop(ctx, u),
                    ))
                .toList(),
          ),
        ),
      ),
    );

    if (selected != null) {
      await _fs.assignDelivery(
        order.id,
        selected['id'] as String,
        selected['username'] as String,
      );
      _load();
    }
  }

  // ── Create Order Dialog ──

  Future<void> _showCreateOrderDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    List<_OrderItemEntry> items = [];
    List<Product> products = [];

    try {
      products = await _fs.getAllProducts();
    } catch (_) {}

    if (!mounted) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final total = items.fold<double>(
              0, (sum, item) => sum + item.total);

          return AlertDialog(
            title: const Text('Nuevo pedido de reparto'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del cliente',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dirección de entrega',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Productos',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () {
                            setDialogState(() {
                              items.add(_OrderItemEntry());
                            });
                          },
                        ),
                      ],
                    ),
                    ...items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<Product>(
                                value: products.where((p) => p.id == item.productId).firstOrNull,
                                items: products
                                    .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text('${p.name} (\$${p.price.toStringAsFixed(2)})',
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (p) {
                                  if (p != null) {
                                    setDialogState(() {
                                      item.productId = p.id;
                                      item.productName = p.name;
                                      item.unitPrice = p.price;
                                      item.updateTotal();
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Producto',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: item.qtyController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Cant.',
                                  isDense: true,
                                ),
                                onChanged: (_) {
                                  setDialogState(() {
                                    item.quantity =
                                        int.tryParse(item.qtyController.text) ?? 0;
                                    item.updateTotal();
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red, size: 20),
                              onPressed: () {
                                setDialogState(() => items.removeAt(idx));
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    if (items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Total: \$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Crear pedido'),
                onPressed: nameCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty
                    ? () => Navigator.pop(ctx, true)
                    : null,
              ),
            ],
          );
        },
      ),
    );

    if (saved == true && nameCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty) {
      final deliveryItems = items
          .where((i) => i.productId.isNotEmpty && i.quantity > 0)
          .map((i) => DeliveryItem(
                productId: i.productId,
                productName: i.productName,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                total: i.total,
              ))
          .toList();

      final total =
          deliveryItems.fold<double>(0, (sum, item) => sum + item.total);

      final order = DeliveryOrder(
        id: const Uuid().v4(),
        customerName: nameCtrl.text.trim(),
        customerPhone: phoneCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        items: deliveryItems,
        total: total,
        notes: notesCtrl.text.isNotEmpty ? notesCtrl.text.trim() : null,
      );

      await _fs.createDeliveryOrder(order);
      _load();
    }
  }

  // ── Helpers ──

  Color _statusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Colors.orange;
      case DeliveryStatus.preparing:
        return Colors.blue;
      case DeliveryStatus.onTheWay:
        return Colors.purple;
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _statusIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Icons.pending;
      case DeliveryStatus.preparing:
        return Icons.kitchen;
      case DeliveryStatus.onTheWay:
        return Icons.delivery_dining;
      case DeliveryStatus.delivered:
        return Icons.check_circle;
      case DeliveryStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class _OrderItemEntry {
  String productId = '';
  String productName = '';
  int quantity = 1;
  double unitPrice = 0;
  double total = 0;
  final TextEditingController qtyController;

  _OrderItemEntry() : qtyController = TextEditingController(text: '1');

  void updateTotal() {
    total = unitPrice * quantity;
  }
}
