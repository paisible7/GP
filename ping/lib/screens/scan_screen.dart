import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool hasScanned = false;
  String message = "Scanne le QR code de présence";
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (hasScanned) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      hasScanned = true;
      message = "QR détecté : $code";
    });

    final result = await _enregistrerPresence(code);

    setState(() {
      message = result;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  Future<String> _enregistrerPresence(String sessionId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return "Utilisateur non connecté ❌";

    try {
      // Vérifie si la présence existe déjà
      final existing = await supabase
          .from('presences')
          .select()
          .eq('user_id', user.id)
          .eq('session_id', sessionId)
          .maybeSingle();

      if (existing != null) {
        return "Présence déjà enregistrée ✅";
      }

      await supabase.from('presences').insert({
        'user_id': user.id,
        'session_id': sessionId,
      });

      return "Présence enregistrée avec succès ✅";
    } catch (e) {
      return "Erreur d'enregistrement ❌";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner un QR Code")),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
