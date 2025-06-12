import 'package:flutter/material.dart';


class ModalBox extends StatefulWidget {
  const ModalBox({super.key});

  @override
  State<ModalBox> createState() => _ModalBoxState();
}

class _ModalBoxState extends State<ModalBox> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(); /*
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Se déconnecter ?"),
          content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Se déconnecter"),
              onPressed: () async {
                Navigator.pop(context); // Fermer la boîte de dialogue

// Déconnecter l'utilisateur
                await userProvider.signOut();

// Vérifier si le contexte est toujours valide
                if (!context.mounted) return;

// Rediriger vers la page de connexion en supprimant toutes les routes précédentes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                      (route) => false, // Supprime toutes les routes précédentes
                );
              },
            ),
          ],
        ),
      ); ;
  */
  }
}
