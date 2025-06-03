/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PresenceHistoryScreen(),
    );
  }
}

class PresenceHistoryScreen extends StatefulWidget {
  @override
  _PresenceHistoryScreenState createState() => _PresenceHistoryScreenState();
}

class _PresenceHistoryScreenState extends State<PresenceHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPresence(String studentId, bool isPresent) async {
    final docRef = _firestore.collection('presences').doc();
    await docRef.set({
      'id': docRef.id,
      'studentId': studentId,
      'timestamp': DateTime.now().toIso8601String(),
      'isPresent': isPresent,
    });
  }

  Stream<List<Map<String, dynamic>>> getPresenceHistory() {
    return _firestore.collection('presences')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historique des Présences')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getPresenceHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucune présence enregistrée."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final presence = snapshot.data![index];
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(presence['timestamp']));
              return ListTile(
                title: Text('ID Étudiant: ${presence['studentId']}'),
                subtitle: Text('Présent: ${presence['isPresent'] ? "Oui" : "Non"}'),
                trailing: Text(formattedDate),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPresence("12345", true),  // Simule une entrée
        child: Icon(Icons.add),
      ),
    );
  }
}
 */