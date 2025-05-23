/*
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Générateur de QR Code',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRCodeGenerator(),
    );
  }
}

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  String _qrData = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
    // Mettre à jour le QR code toutes les 60 secondes
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _generateQRCode();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateQRCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const secretKey = 'votre_clé_secrète';
    final token = _generateToken(timestamp, secretKey);

    setState(() {
      _qrData = token;
    });
  }

  String _generateToken(int timestamp, String secretKey) {
    final salt = 'random_string_unique'; // Ajoute un sel (Salt)
    final payload = '$timestamp.$secretKey.$salt';
    final bytes = utf8.encode(payload);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Sécurisé')),
      body: Center(
        child: _qrData.isEmpty
            ? const CircularProgressIndicator() // Ajout du const pour optimiser les performances
            : QrImageView(
          data: _qrData,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}*/
