import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:store_tracker/services/services.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    _isProcessing = true;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null && mounted) {
      // Search for product by barcode (in description field for now)
      final products = productService.list();
      final product = products.where((p) => p.description?.contains(code) ?? false).firstOrNull;

      if (product != null) {
        // Found product, navigate to sale screen with pre-filled product
        Navigator.pop(context, product);
      } else {
        // Product not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product not found for barcode: $code'),
            action: SnackBarAction(
              label: 'Add Product',
              onPressed: () {
                Navigator.pop(context, code);
              },
            ),
          ),
        );
      }
    }

    await Future.delayed(const Duration(seconds: 2));
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Scanner overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Expanded(child: Container(color: Colors.black.withOpacity(0.5))),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'Align barcode within frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container(color: Colors.black.withOpacity(0.5))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
