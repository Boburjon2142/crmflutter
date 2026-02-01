import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../theme/app_theme.dart';
import 'prices_screen.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  String? _lastCode;
  bool _navigating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Barcode skaner', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: (capture) {
                      final codes = capture.barcodes;
                      if (codes.isEmpty) {
                        return;
                      }
                      final value = codes.first.rawValue ?? '';
                      if (value.isEmpty) {
                        return;
                      }
                      setState(() => _lastCode = value);
                      if (!_navigating) {
                        _navigating = true;
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => PricesScreen(barcode: value),
                              ),
                            )
                            .then((_) {
                          if (mounted) {
                            setState(() {
                              _navigating = false;
                            });
                          } else {
                            _navigating = false;
                          }
                        });
                      }
                    },
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Row(
                      children: [
                        _IconChip(
                          icon: Icons.flash_on,
                          onTap: () => _controller.toggleTorch(),
                        ),
                        const SizedBox(width: 12),
                        _IconChip(
                          icon: Icons.cameraswitch,
                          onTap: () => _controller.switchCamera(),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _lastCode == null || _lastCode!.isEmpty
                            ? 'Barcode kutilyapti...'
                            : 'Kod: $_lastCode',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_lastCode != null && _lastCode!.isNotEmpty)
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _lastCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barcode nusxa olindi')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Nusxa olish'),
            ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
