import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(XFile?) onImageSelected;
  final String? existingImageUrl;
  final String? existingImagePath;

  const ImagePickerWidget({
    Key? key,
    required this.onImageSelected,
    this.existingImageUrl,
    this.existingImagePath,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Restore existing image if available
    if (widget.existingImageUrl != null) {
      _selectedImage = null; // Will show network image
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        // En Web, leer bytes. En Mobile/Desktop, solo guardar referencia
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImage = image;
            _imageBytes = bytes;
          });
        } else {
          setState(() => _selectedImage = image);
        }
        widget.onImageSelected(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen del Producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showImageSourceDialog(),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: _buildImagePreview(),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedImage != null || widget.existingImageUrl != null)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showImageSourceDialog(),
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar imagen'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'),
              ),
            ],
          )
        else
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showImageSourceDialog(),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Seleccionar imagen'),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview() {
    // Show selected local image
    if (_selectedImage != null) {
      // En Web, usar bytes. En Mobile/Desktop, usar file
      if (kIsWeb && _imageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          ),
        );
      } else if (!kIsWeb) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            File(_selectedImage!.path),
            fit: BoxFit.cover,
          ),
        );
      }
    }

    // Show existing network image
    if (widget.existingImageUrl != null && widget.existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          widget.existingImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image in picker: ${widget.existingImageUrl} - $error');
            return _emptyImagePlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    }

    // Empty placeholder
    return _emptyImagePlaceholder();
  }

  Widget _emptyImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: const Text('¿De dónde deseas cargar la imagen?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Cámara'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Galería'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
