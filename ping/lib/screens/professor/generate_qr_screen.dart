import 'package:flutter/material.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:qr/qr.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/user_provider.dart';

class GenerateQRScreen extends StatefulWidget {
  final String horaireId;
  const GenerateQRScreen({Key? key, required this.horaireId}) : super(key: key);

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  String? _generatedQRCode;
  int _countdown = 5;
  Timer? _qrTimer;
  Timer? _countdownTimer;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _startQrTimer();
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    setState(() {
      _isGenerating = true;
    });
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      print('[QR] Appel RPC generate_temp_qr avec horaire = \\${widget.horaireId}, prof = \\${userId}');
      final response = await Supabase.instance.client.rpc('generate_temp_qr', params: {
        'horaire': widget.horaireId,
        'prof': userId,
      });
      print('[QR] Réponse Supabase brute : \\${response.toString()}');
      if (response is String) {
        // Succès, on a le QR code
        if (mounted) {
          setState(() {
            _generatedQRCode = response;
          });
        }
      } else if (response is PostgrestException) {
        // Erreur Supabase
        print('[QR] Erreur Supabase: \\${response.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur Supabase: \\${response.message}')),
          );
          setState(() {
            _generatedQRCode = null;
          });
        }
      } else {
        // Cas inattendu
        print('[QR] Réponse inattendue: \\${response}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur inattendue lors de la génération du QR code.')),
          );
          setState(() {
            _generatedQRCode = null;
          });
        }
      }
    } catch (e) {
      print('[QR] Exception lors de la génération du QR code: \\${e}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du QR code: \\${e}')),
        );
        setState(() {
          _generatedQRCode = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _startQrTimer() {
    _qrTimer?.cancel();
    _countdownTimer?.cancel();
    _generateQRCode();
    _countdown = 5;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        setState(() {
          _countdown = 5;
        });
      }
    });
    _qrTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _generateQRCode();
      setState(() {
        _countdown = 5;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('QR Code Présence'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isGenerating && _generatedQRCode == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_generatedQRCode != null && _generatedQRCode!.isNotEmpty)
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: QrImageWidget(data: _generatedQRCode!, size: 300),
                    )
                  else ...[
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 10),
                    const Text('Aucun QR code généré.', style: TextStyle(color: Colors.red, fontSize: 18)),
                  ],
                  const SizedBox(height: 30),
                  Text(
                    'Nouveau code dans $_countdown s',
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}

class QrImageWidget extends StatelessWidget {
  final String data;
  final double size;

  const QrImageWidget({Key? key, required this.data, required this.size}) : super(key: key);

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

  QrPainter({required this.qrImage, required this.color});

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