import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ping/theme/app_theme.dart';



class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool obsecureText = true;
  bool isLoading = false;

  void togglePasswordVisibility() {
    setState(() {
      obsecureText = !obsecureText;
    });
  }
  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailC.text.trim(),
        password: _passC.text,
      );
      if (response.user != null) {
        // 👇 Ici tu peux rediriger vers le dashboard par exemple
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } on AuthException catch (error) {
      print("Erreur d'authentification ");
    }
  }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColor.primary,
        body: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.35,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
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
                    "Bienvenue sur Ping\nUne application de académique ",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: 'poppins',
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "by github.com/paisible7",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.65,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 36),
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
                    child: TextField(
                      controller: _emailC,
                      style: TextStyle(fontSize: 14, fontFamily: 'poppins'),
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "matricule@esisalama.org",
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
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    margin: EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.primarySoft),
                    ),
                    child: TextField(
                      controller: _passC,
                      obscureText: obsecureText,
                      style: TextStyle(fontSize: 14, fontFamily: 'poppins'),
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "*************",
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
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
                              Icons.remove_red_eye
                          ),

                          /*icon: SvgPicture.asset(
                          obsecureText
                              ? 'assets/icons/show.svg'
                              : 'assets/icons/hide.svg',
                        ),*/
                          onPressed: togglePasswordVisibility,
                        ),
                      ),
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
                      child: Text(
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
                        // Rediriger vers mot de passe oublié
                      },
                      child: Text("Mot de passe oublié ?"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

