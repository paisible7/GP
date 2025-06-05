import 'package:flutter/material.dart';
import 'package:ping/responsive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obsecureText = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      obsecureText = !obsecureText;
    });
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!value.endsWith('@esisalama.org')) {
      return 'Veuillez utiliser votre email ESIS';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).login(_emailC.text.trim(), _passC.text);

      if (!mounted) return;

      final userRole =
          Provider.of<UserProvider>(context, listen: false).userRole;
      if (userRole == 'professeur' || userRole == 'admin') {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (userRole == 'etudiant') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rôle utilisateur non reconnu: $userRole'),
            backgroundColor: Colors.red,
          ),
        );
        await Provider.of<UserProvider>(context, listen: false).signOut();
      }
    } on AuthException catch (error) {
      String message;
      switch (error.message) {
        case 'Invalid login credentials':
          message = 'Email ou mot de passe incorrect';
          break;
        case 'Email not confirmed':
          message = 'Veuillez confirmer votre email avant de vous connecter';
          break;
        default:
          message = 'Erreur de connexion: ${error.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
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
      backgroundColor: AppColor.primary,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Responsive(
            mobile: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 32),
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                    image: DecorationImage(
                      image: AssetImage('assets/images/pattern-1-1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenue sur Ping",
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                          fontFamily: 'poppins',
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "L'application académique...",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'poppins',
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "by m.paisible7",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w600,
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
                            controller: _emailC,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'poppins',
                            ),
                            decoration: InputDecoration(
                              labelText: "Email",
                              hintText: "matricule@esisalama.org",
                              border: InputBorder.none,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: AppColor.primarySoft,
                                fontWeight: FontWeight.w500,
                              ),
                              labelStyle: TextStyle(
                                color: AppColor.primarySoft,
                                fontSize: 14,
                              ),
                            ),
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          margin: EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColor.primarySoft),
                          ),
                          child: TextFormField(
                            controller: _passC,
                            obscureText: obsecureText,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'poppins',
                            ),
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "*************",
                              border: InputBorder.none,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: AppColor.primarySoft,
                                fontSize: 14,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                color: AppColor.primarySoft,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obsecureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColor.primarySoft,
                                ),
                                onPressed: togglePasswordVisibility,
                              ),
                            ),
                            validator: validatePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => handleLogin(),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:
                                isLoading
                                    ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'poppins',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 4),
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/reset-password');
                            },
                            child: Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 1.0,
                    width: MediaQuery.of(context).size.width * 1.0,
                    padding: EdgeInsets.only(left: 100),
                    decoration: BoxDecoration(
                      gradient: AppColor.primaryGradient,
                      image: DecorationImage(
                        alignment: Alignment.bottomCenter,
                        image: AssetImage('assets/images/pattern-1-1.png',),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bienvenue sur Ping",
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                            fontFamily: 'poppins',
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "L'application académique...",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'poppins',
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "by m.paisible7",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 1.0,
                    width: MediaQuery.of(context).size.width * 1.0,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 170, vertical: 250),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            margin: EdgeInsets.only(bottom: 26),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColor.primarySoft),
                            ),
                            child: TextFormField(
                              controller: _emailC,
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'poppins',
                              ),
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "matricule@esisalama.org",
                                border: InputBorder.none,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                hintStyle: TextStyle(
                                  fontSize: 24,
                                  color: AppColor.primarySoft,
                                  fontWeight: FontWeight.w500,
                                ),
                                labelStyle: TextStyle(
                                  color: AppColor.primarySoft,
                                  fontSize: 24,
                                ),
                              ),
                              validator: validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            margin: EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColor.primarySoft),
                            ),
                            child: TextFormField(
                              controller: _passC,
                              obscureText: obsecureText,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'poppins',
                              ),
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "*************",
                                border: InputBorder.none,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                  color: AppColor.primarySoft,
                                  fontSize: 14,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'poppins',
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.primarySoft,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obsecureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColor.primarySoft,
                                  ),
                                  onPressed: togglePasswordVisibility,
                                ),
                              ),
                              validator: validatePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => handleLogin(),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: AppColor.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  isLoading
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Se connecter',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'poppins',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 4),
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/reset-password');
                              },
                              child: Text(
                                "Mot de passe oublié ?",
                                style: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
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
