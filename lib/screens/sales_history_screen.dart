import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:panaderia_liz/config/constants.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/services/index.dart';
import 'package:panaderia_liz/utils/formatters.dart';
import 'package:panaderia_liz/widgets/index.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late SalesNotifier _salesNotifier;
  List<Sale> _filteredSales = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  DateTime? _selectedDateStart;
  DateTime? _selectedDateEnd;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSales);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _salesNotifier = context.read<SalesNotifier>();
      _salesNotifier.addListener(_onSalesChanged);
      _salesNotifier.loadSales();
    });
  }

  @override
  void dispose() {
    _salesNotifier.removeListener(_onSalesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSalesChanged() {
    if (!mounted) return;
    _isLoading = _salesNotifier.isLoading;
    _applyFilters();
  }

  Future<void> _loadSales() async {
    await _salesNotifier.loadSales();
  }

  void _filterSales() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final sales = _salesNotifier.sales;

    setState(() {
      _filteredSales = sales.where((sale) {
        // Search filter
        final matchesSearch =
            sale.id.toLowerCase().contains(query) ||
            Formatters.currency(sale.total).contains(query) ||
            Formatters.date(sale.createdAt).contains(query);

        // Date range filter
        bool matchesDateRange = true;
        if (_selectedDateStart != null) {
          matchesDateRange = sale.createdAt.isAfter(
            DateTime(
              _selectedDateStart!.year,
              _selectedDateStart!.month,
              _selectedDateStart!.day,
            ),
          );
        }

        if (_selectedDateEnd != null && matchesDateRange) {
          matchesDateRange = sale.createdAt.isBefore(
            DateTime(
              _selectedDateEnd!.year,
              _selectedDateEnd!.month,
              _selectedDateEnd!.day + 1,
            ),
          );
        }

        return matchesSearch && matchesDateRange;
      }).toList();
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _selectedDateStart : _selectedDateEnd ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedDateStart = picked;
        } else {
          _selectedDateEnd = picked;
        }
      });
      _applyFilters();
    }
  }

  void _showSaleDetail(Sale sale) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Venta: ${sale.id.substring(0, 8)}...'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha: ${Formatters.dateTime(sale.createdAt)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${Formatters.currency(sale.total)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        PaymentMethod.fromCode(sale.paymentMethod).icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Método: ${PaymentMethod.fromCode(sale.paymentMethod).displayName}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Productos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (sale.items.isEmpty)
              const Text('Sin items')
            else
              ...sale.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${item.quantity}x ${Formatters.currency(item.unitPrice)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.currency(item.total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _showReceipt(sale),
          child: const Text('👁 Ver Recibo'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  void _showReceipt(Sale sale) {
    final receiptText = _generateReceiptText(sale);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Comprobante'),
                backgroundColor: AppConstants.primaryColor,
                automaticallyImplyLeading: false,
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    receiptText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('PDF'),
                      onPressed: () => _downloadReceiptPdf(sale),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar'),
                      onPressed: () => _copyReceiptToClipboard(sale),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Cerrar'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateReceiptText(Sale sale) {
    final buffer = StringBuffer();
    buffer.writeln('=====================================');
    buffer.writeln('        PANADERÍA LIZ');
    buffer.writeln('        COMPROBANTE DE VENTA');
    buffer.writeln('=====================================');
    buffer.writeln('');
    buffer.writeln('ID: ${sale.id.substring(0, 12)}');
    buffer.writeln('Fecha: ${Formatters.dateTime(sale.createdAt)}');
    buffer.writeln('Método: ${PaymentMethod.fromCode(sale.paymentMethod).displayName}');
    buffer.writeln('');
    buffer.writeln('-------------------------------------');
    buffer.writeln('PRODUCTOS:');
    buffer.writeln('-------------------------------------');
    
    for (final item in sale.items) {
      buffer.writeln('${item.productName}');
      buffer.writeln('  ${item.quantity} x ${Formatters.currency(item.unitPrice)} = ${Formatters.currency(item.total)}');
    }
    
    buffer.writeln('-------------------------------------');
    buffer.writeln('TOTAL: ${Formatters.currency(sale.total)}');
    buffer.writeln('=====================================');
    buffer.writeln('');
    buffer.writeln('¡Gracias por su compra!');
    buffer.writeln('${Formatters.dateTime(sale.createdAt)}');
    
    return buffer.toString();
  }

  Future<void> _downloadReceiptPdf(Sale sale) async {
    try {
      final pdfBytes = await PdfService.generateReceiptPdf(sale);
      
      // Generar nombre del archivo
      final fileName = 'Recibo_${sale.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      // Guardar el PDF
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: pdfBytes,
        mimeType: MimeType.pdf,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF descargado: $fileName'),
            backgroundColor: AppConstants.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error descargando PDF: $e'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _copyReceiptToClipboard(Sale sale) async {
    try {
      final receiptText = _generateReceiptText(sale);
      
      await Clipboard.setData(ClipboardData(text: receiptText));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recibo copiado al portapapeles'),
            backgroundColor: AppConstants.successColor,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error copiando: $e'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showChartsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Gráficos de Ventas'),
                backgroundColor: AppConstants.primaryColor,
                automaticallyImplyLeading: true,
              ),
              Flexible(
                child: SalesCharts(sales: _filteredSales),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.salesHistoryTitle),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Ver Gráficos',
            onPressed: () => _showChartsDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Cargando ventas...')
          : Column(
              children: [
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total Ventas',
                          value: Formatters.currency(stats['total'] as double),
                          icon: Icons.attach_money,
                          backgroundColor: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Transacciones',
                          value: (stats['count'] as int).toString(),
                          icon: Icons.receipt_long,
                          backgroundColor: AppConstants.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Búsqueda
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar venta...',
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
                      const SizedBox(height: 12),
                      // Filtro de fechas
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _selectedDateStart == null
                                    ? 'Desde...'
                                    : Formatters.date(_selectedDateStart!),
                              ),
                              onPressed: () => _selectDate(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _selectedDateEnd == null
                                    ? 'Hasta...'
                                    : Formatters.date(_selectedDateEnd!),
                              ),
                              onPressed: () => _selectDate(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          if (_selectedDateStart != null ||
                              _selectedDateEnd != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedDateStart = null;
                                  _selectedDateEnd = null;
                                });
                                _applyFilters();
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Resultados
                      Text(
                        '${_filteredSales.length} venta${_filteredSales.length != 1 ? 's' : ''} encontrada${_filteredSales.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Lista de ventas
                Expanded(
                  child: _filteredSales.isEmpty
                      ? EmptyState(
                          title: AppConstants.emptyNoSales,
                          message: _searchController.text.isNotEmpty
                              ? 'No hay resultados para tu búsqueda'
                              : 'El historial está vacío',
                          icon: Icons.history,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredSales.length,
                          itemBuilder: (context, index) {
                            final sale = _filteredSales[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  Formatters.currency(sale.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppConstants.primaryColor,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Formatters.dateTime(sale.createdAt),
                                    ),
                                    Text(
                                      '${sale.items.length} artículos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        Chip(
                                          label: Text(
                                            PaymentMethod.fromCode(sale.paymentMethod).displayName,
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                          avatar: Text(
                                            PaymentMethod.fromCode(sale.paymentMethod).icon,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onPressed: () => _showSaleDetail(sale),
                                ),
                                onTap: () => _showSaleDetail(sale),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    double total = 0;
    for (final sale in _filteredSales) {
      total += sale.total;
    }

    return {
      'total': total,
      'count': _filteredSales.length,
    };
  }
}
