import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr/qr.dart';
import 'package:uuid/uuid.dart';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({Key? key}) : super(key: key);

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCoursId;
  int _dureeMinutes = 15;
  bool _isLoading = false;
  String? _generatedQRCode;
  List<Map<String, dynamic>> _coursList = [];

  @override
  void initState() {
    super.initState();
    _fetchCours(); // Récupérer la liste des cours au chargement de l'écran.
  }

  Future<void> _fetchCours() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté.');
      }

      // Récupérer les cours depuis la table 'cours' pour le professeur connecté.
      final data = await Supabase.instance.client
          .from('cours')
          .select('*, salles_de_cours(*)')
          .eq('professeur_id', userId);

      if (data != null) {
        setState(() {
          _coursList = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des cours: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors du chargement des cours.')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateQR() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _generatedQRCode = null;
      });

      try {
        final userId = Provider.of<UserProvider>(context, listen: false).userId;
        if (userId == null) {
          throw Exception('Utilisateur non connecté.');
        }

        final qrCode = Uuid().v4();

        final data = await Supabase.instance.client.from('sessions_presence').insert({
          'cours_id': _selectedCoursId,
          'professeur_id': userId,
          'date': DateTime.now().toIso8601String(),
          'qr_code': qrCode,
          'duree_minutes': _dureeMinutes,
          'est_active': true,
        }).select().single();

        if (data != null) {
          setState(() {
            _generatedQRCode = qrCode;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('QR Code généré avec succès !'))
          );
        } else {
          throw Exception('Erreur lors de l\'enregistrement de la session.');
        }
      } catch (e) {
        print('Erreur lors de la génération du QR: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du QR: ${e.toString()}'))
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer QR Code'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Cours'),
                      value: _selectedCoursId,
                      items: _coursList.map((cours) {
                        return DropdownMenuItem<String>(
                          value: cours['id'] as String,
                          child: Text('${cours['nom']} - ${cours['horaire']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCoursId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un cours.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Durée (minutes)'),
                      keyboardType: TextInputType.number,
                      initialValue: _dureeMinutes.toString(),
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _dureeMinutes = int.tryParse(value) ?? 15;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une durée.';
                        }
                        final duree = int.tryParse(value);
                        if (duree == null || duree <= 0) {
                          return 'La durée doit être un nombre positif.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _generateQR,
                      child: const Text('Générer QR Code'),
                    ),
                    if (_generatedQRCode != null) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: QrImageWidget(
                          data: _generatedQRCode!,
                          size: 200,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'QR Code généré !',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
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
    final qrCode = QrCode(4, QrErrorCorrectLevel.L)
      ..addData(data);

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
            Rect.fromLTWH(
              x * moduleSize,
              y * moduleSize,
              moduleSize,
              moduleSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 