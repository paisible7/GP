import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/theme/app_theme.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obsecureText = true;
  bool obsecureConfirmText = true;
  bool isLoading = false;

  @override
  void dispose() {
    _passwordC.dispose();
    _confirmPasswordC.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      obsecureText = !obsecureText;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      obsecureConfirmText = !obsecureConfirmText;
    });
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordC.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  Future<void> handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: _passwordC.text,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Votre mot de passe a été mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } on AuthException catch (error) {
      String message;
      switch (error.message) {
        case 'Password should be at least 6 characters':
          message = 'Le mot de passe doit contenir au moins 6 caractères';
          break;
        default:
          message = 'Erreur: ${error.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nouveau mot de passe',
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 18,
            fontFamily: 'poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Définissez votre nouveau mot de passe',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'poppins',
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.primarySoft),
                  ),
                  child: TextFormField(
                    controller: _passwordC,
                    obscureText: obsecureText,
                    style: TextStyle(fontSize: 14, fontFamily: 'poppins'),
                    decoration: InputDecoration(
                      labelText: "Nouveau mot de passe",
                      hintText: "*************",
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColor.primarySoft,
                        fontWeight: FontWeight.w500,
                      ),
                      labelStyle: TextStyle(
                        color: AppColor.primarySoft,
                        fontSize: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obsecureText ? Icons.visibility_off : Icons.visibility,
                          color: AppColor.primarySoft,
                        ),
                        onPressed: togglePasswordVisibility,
                      ),
                    ),
                    validator: validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  margin: EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.primarySoft),
                  ),
                  child: TextFormField(
                    controller: _confirmPasswordC,
                    obscureText: obsecureConfirmText,
                    style: TextStyle(fontSize: 14, fontFamily: 'poppins'),
                    decoration: InputDecoration(
                      labelText: "Confirmer le mot de passe",
                      hintText: "*************",
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColor.primarySoft,
                        fontWeight: FontWeight.w500,
                      ),
                      labelStyle: TextStyle(
                        color: AppColor.primarySoft,
                        fontSize: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obsecureConfirmText ? Icons.visibility_off : Icons.visibility,
                          color: AppColor.primarySoft,
                        ),
                        onPressed: toggleConfirmPasswordVisibility,
                      ),
                    ),
                    validator: validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => handleUpdatePassword(),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleUpdatePassword,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Mettre à jour le mot de passe',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
