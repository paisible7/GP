import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/core/data_service.dart';
import 'package:qr/qr.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({Key? key}) : super(key: key);

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  List<Map<String, dynamic>> _coursList = [];
  bool _isLoading = false;
  String? _selectedCoursId;
  String? _generatedQRCode;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadCours();
  }

  Future<void> _loadCours() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final data = await DataService.getProfessorCourses(userId);
      
      if (mounted) {
        setState(() {
          _coursList = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des cours: $e')),
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

  Future<void> _generateQRCode() async {
    if (_selectedCoursId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un cours')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final qrCode = const Uuid().v4();
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      
      if (userId == null) {
        throw Exception('Utilisateur non connecté.');
      }
      
      // Créer une nouvelle session avec le QR code
      await DataService.createSessionWithQR(
        coursId: _selectedCoursId!,
        qrCode: qrCode,
        professorId: userId,
      );

      if (mounted) {
        setState(() {
          _generatedQRCode = qrCode;
        });
        
        _showQRCodeDialog(qrCode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du QR code: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showQRCodeDialog(String qrCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code généré avec succès'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vos étudiants peuvent maintenant scanner ce QR code pour enregistrer leur présence.'),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 250,
              child: Center(
                child: QrImageWidget(data: qrCode, size: 200),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Code: $qrCode',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer QR Code'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sélectionner un cours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_coursList.isEmpty)
                      const Center(
                        child: Text(
                          'Aucun cours assigné',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedCoursId,
                        decoration: const InputDecoration(
                          labelText: 'Cours',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: _coursList.map((cours) {
                          return DropdownMenuItem<String>(
                            value: cours['id'],
                            child: Text(cours['nom']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCoursId = value;
                            _generatedQRCode = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectedCoursId != null && !_isGenerating ? _generateQRCode : null,
              icon: _isGenerating 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.qr_code),
              label: Text(_isGenerating ? 'Génération...' : 'Générer QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_generatedQRCode != null) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'QR Code généré avec succès !',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Code: $_generatedQRCode',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QrImageWidget extends StatelessWidget {
  final String data;
  final double size;

  const QrImageWidget({
    Key? key,
    required this.data,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrCode = QrCode(4, QrErrorCorrectLevel.L)..addData(data);

    return CustomPaint(
      size: Size(size, size),
      painter: QrPainter(
        qrImage: QrImage(qrCode),
        color: Colors.black,
      ),
    );
  }
}

class QrPainter extends CustomPainter {
  final QrImage qrImage;
  final Color color;

  QrPainter({
    required this.qrImage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    final moduleSize = size.width / qrImage.moduleCount;

    for (var x = 0; x < qrImage.moduleCount; x++) {
      for (var y = 0; y < qrImage.moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(x * moduleSize, y * moduleSize, moduleSize, moduleSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrPainter oldDelegate) {
    return oldDelegate.qrImage != qrImage || oldDelegate.color != color;
  }
} 