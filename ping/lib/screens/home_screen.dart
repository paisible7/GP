import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header : Avatar + nom
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  "https://ui-avatars.com/api/?name=Jean+Dupont",
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Bienvenue, Jean Dupont',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Présence du jour
          Card(
            child: ListTile(
              title: const Text("Présence du jour"),
              subtitle: const Text("Heure d'arrivée : 08:12"),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ),

          const SizedBox(height: 24),

          // Titre historique
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Historique",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Action à définir
                },
                child: const Text("Voir tout"),
              ),
            ],
          ),

          // Liste des présences précédentes
          ...List.generate(3, (index) {
            return Card(
              child: ListTile(
                title: Text("2025-05-1${index + 7}"),
                subtitle: Text("Heure d'arrivée : 08:${10 + index}"),
              ),
            );
          }),
        ],
      ),
    );
  }
}
