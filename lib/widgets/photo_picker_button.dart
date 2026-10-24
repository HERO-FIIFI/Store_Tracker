import 'dart:io';
import 'package:flutter/material.dart';
import 'package:store_tracker/services/photo_service.dart';

class PhotoPickerButton extends StatefulWidget {
  final Function(String?) onPhotoSelected;
  final String? initialPhotoPath;
  final String label;
  final IconData icon;

  const PhotoPickerButton({
    super.key,
    required this.onPhotoSelected,
    this.initialPhotoPath,
    this.label = 'Add Receipt Photo',
    this.icon = Icons.camera_alt,
  });

  @override
  State<PhotoPickerButton> createState() => _PhotoPickerButtonState();
}

class _PhotoPickerButtonState extends State<PhotoPickerButton> {
  String? _currentPhotoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPhotoPath = widget.initialPhotoPath;
  }

  Future<void> _showPhotoOptions() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (_currentPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    if (result == 'remove') {
      _removePhoto();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? photoPath;

      if (result == 'camera') {
        photoPath = await PhotoService.capturePhoto();
      } else if (result == 'gallery') {
        photoPath = await PhotoService.pickFromGallery();
      }

      if (photoPath != null) {
        setState(() {
          _currentPhotoPath = photoPath;
        });
        widget.onPhotoSelected(photoPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _currentPhotoPath = null;
    });
    widget.onPhotoSelected(null);
  }

  Future<void> _viewPhoto() async {
    if (_currentPhotoPath == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(photoPath: _currentPhotoPath!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPhotoPath != null) {
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _viewPhoto,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.file(
                      File(_currentPhotoPath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 64),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _removePhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.receipt, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Receipt photo attached',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _viewPhoto,
                    icon: const Icon(Icons.zoom_in, size: 18),
                    label: const Text('View'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _showPhotoOptions,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.icon),
      label: Text(_isLoading ? 'Loading...' : widget.label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class PhotoViewScreen extends StatelessWidget {
  final String photoPath;

  const PhotoViewScreen({super.key, required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Receipt Photo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(photoPath),
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Could not load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
