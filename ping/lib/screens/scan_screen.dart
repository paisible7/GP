import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isLoading = false;
  String? _scanResult;
  String? _scanError;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _scanError = 'Le service de localisation est désactivé. Veuillez l\'activer pour scanner les QR codes.';
      });
      return;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _scanError = 'Les permissions de localisation sont refusées.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _scanError = 'Les permissions de localisation sont définitivement refusées. Veuillez les activer dans les paramètres.';
      });
      return;
    }

    setState(() {
      _hasLocationPermission = true;
      _scanError = null;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isLoading || !_hasLocationPermission) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _scanResult = null;
      _scanError = null;
    });

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté.');
      }

      // Vérifier si l'utilisateur est un étudiant
      final etudiantData = await Supabase.instance.client
          .from('etudiants')
          .select()
          .eq('id', userId)
          .single();

      if (etudiantData == null) {
        throw Exception('Accès non autorisé. Seuls les étudiants peuvent scanner les QR codes.');
      }

      final sessionData = await Supabase.instance.client
          .from('sessions_presence')
          .select('*, cours:cours(salle_id, salles_de_cours(*))')
          .eq('qr_code', code)
          .eq('est_active', true)
          .single();

      if (sessionData == null) {
        throw Exception('QR Code invalide ou session inactive.');
      }

      final sessionDate = DateTime.parse(sessionData['date'] as String);
      final dureeMinutes = sessionData['duree_minutes'] as int;
      final sessionEndTime = sessionDate.add(Duration(minutes: dureeMinutes));

      if (DateTime.now().isAfter(sessionEndTime)) {
        throw Exception('La session a expiré.');
      }

      final sessionId = sessionData['id'] as String;
      final coursId = sessionData['cours_id'] as String?;
      final salleData = sessionData['cours']?['salles_de_cours'] as Map<String, dynamic>?;

      if (coursId == null || salleData == null) {
         throw Exception('Informations de cours ou de salle manquantes pour cette session.');
      }

      final latitudeMin = salleData['latitude_min'] as double;
      final latitudeMax = salleData['latitude_max'] as double;
      final longitudeMin = salleData['longitude_min'] as double;
      final longitudeMax = salleData['longitude_max'] as double;

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        print('Erreur lors de la récupération de la position: $e');
        throw Exception('Impossible de récupérer votre position. Veuillez vérifier que la géolocalisation est activée.');
      }

      final latitude = position.latitude;
      final longitude = position.longitude;

      bool isInSalle = latitude >= latitudeMin &&
          latitude <= latitudeMax &&
          longitude >= longitudeMin &&
          longitude <= longitudeMax;

      String statut = isInSalle ? 'present' : 'absent';

      // Vérifier si l'étudiant a déjà une présence pour cette session
      final existingPresence = await Supabase.instance.client
          .from('presences')
          .select()
          .eq('session_id', sessionId)
          .eq('etudiant_id', userId)
          .maybeSingle();

      if (existingPresence != null) {
        throw Exception('Vous avez déjà enregistré votre présence pour cette session.');
      }

      final presenceData = await Supabase.instance.client.from('presences').insert({
        'session_id': sessionId,
        'etudiant_id': userId,
        'date_presence': DateTime.now().toIso8601String(),
        'statut': statut,
      }).select().single();

      if (presenceData == null) {
         throw Exception('Erreur lors de l\'enregistrement de la présence.');
      }

      await Supabase.instance.client.from('geolocalisations').insert({
        'etudiant_id': userId,
        'session_id': sessionId,
        'latitude': latitude,
        'longitude': longitude,
        'date_capture': DateTime.now().toIso8601String(),
      });

      setState(() {
        _scanResult = isInSalle 
            ? 'Présence enregistrée avec succès !' 
            : 'Vous êtes hors de la salle. Présence marquée comme absente.';
      });

      await cameraController.stop();

    } catch (e) {
      print('Erreur lors du scan du QR: $e');
      setState(() {
        _scanError = e.toString();
      });
      await cameraController.stop();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
      ),
      body: Stack(
        children: [
          if (_hasLocationPermission)
            MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _scanError ?? 'Erreur de localisation',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _checkLocationPermission,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_scanResult != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _scanResult!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_scanError != null && _hasLocationPermission)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _scanError!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_hasLocationPermission)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.flip_camera_android, color: Colors.white),
                    onPressed: () async {
                      await cameraController.switchCamera();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    onPressed: () async {
                      await cameraController.toggleTorch();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () async {
                      setState(() {
                        _scanResult = null;
                        _scanError = null;
                      });
                      await cameraController.start();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
