import 'package:flutter/material.dart';

// À personnaliser selon tes besoins
class AppColor {
  static const Color primary = Color(0xFF001492);
  static const Color secondarySoft = Color(0xFF9FA8DA);
  static const Color secondaryExtraSoft = Color(0xFFE8EAF6);
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF001492), Color(0xFF001492)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
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
    // Simule une requête
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: ListView(
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
                  "by github.com/mrezkys",
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
                    border: Border.all(color: AppColor.secondaryExtraSoft),
                  ),
                  child: TextField(
                    controller: emailC,
                    style: TextStyle(fontSize: 14, fontFamily: 'poppins'),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "matricule@esisalama.org",
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColor.secondarySoft,
                        fontWeight: FontWeight.w500,
                      ),
                      labelStyle: TextStyle(
                        color: AppColor.secondarySoft,
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
                    border: Border.all(color: AppColor.secondaryExtraSoft),
                  ),
                  child: TextField(
                    controller: passC,
                    obscureText: obsecureText,
                    style: TextStyle(fontSize: 14, fontFamily: 'poppins'),
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "*************",
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        color: AppColor.secondarySoft,
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w500,
                        color: AppColor.secondarySoft,
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
                      isLoading ? 'Loading...' : 'Se connecter',
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
