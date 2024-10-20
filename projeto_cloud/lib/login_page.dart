import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:projeto_cloud/main_page.dart';
import 'package:projeto_cloud/register_page.dart';

class LoginPageCreateState extends StatefulWidget {
  const LoginPageCreateState({super.key});

  @override
  State<LoginPageCreateState> createState() => LoginPage();
}

class LoginPage extends State<LoginPageCreateState> {
  late double screenHeight;
  late double screenWidth;
  late double fontSizeAsPercentage;
  late TextStyle titleStyle;

  String emailLogin = "";
  String passwordLogin = "";

  String errorTextValEmail = "";
  String errorTextValPassword = "";

  TextEditingController emailTextField = TextEditingController();

  TextEditingController passwordTextField = TextEditingController();

  Future<void> showLoginErrorDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Falhou'),
          content: const Text('As credenciais de login estão incorretas.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showLoginSuccessDialog(
      BuildContext context, String typeUser) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Bem-Sucedido'),
          content: const Text('Você efetuou login com sucesso.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showConnectionErrorDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro de Conexão'),
          content: const Text('Houve um erro ao se conectar ao servidor.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    TextStyle titleStyle = TextStyle(
        fontFamily: 'DancingScript',
        fontSize: screenHeight * 0.1,
        fontWeight: FontWeight.bold,
        color: Colors.black);

    void clearFields() {
      setState(() {
        emailTextField.clear();
        passwordTextField.clear();
      });
    }

    SizedBox emailReturn() {
      return SizedBox(
        width: screenHeight * 0.5,
        child: TextField(
          onChanged: (text) {
            emailLogin = text;
            setState(() {
              if (text.contains("@")) {
                errorTextValEmail = "";
              } else {
                errorTextValEmail = "O email não é válido.";
              }
            });
          },
          controller: emailTextField,
          decoration: InputDecoration(
            errorText: errorTextValEmail.isEmpty ? null : errorTextValEmail,
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(20.0),
            ),
            labelText: 'Insira o Email',
          ),
        ),
      );
    }

    SizedBox passwordReturn() {
      return SizedBox(
        width: screenHeight * 0.5,
        child: TextField(
          onChanged: (text) {
            passwordLogin = text;
          },
          obscureText: true,
          controller: passwordTextField,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(20.0),
            ),
            labelText: 'Insira a Senha',
          ),
        ),
      );
    }

    ButtonTheme buttonLoginUser() {
      return ButtonTheme(
        minWidth: screenHeight * 0.2,
        height: screenHeight * 0.1,
        child: ElevatedButton(
          onPressed: () async {
            final url = Uri.parse('http://192.168.132.138:5000/login');

            final response = await http.post(url, body: {
              'email': emailLogin,
              'password': passwordLogin,
            });

            if (response.statusCode == 200) {
              final jsonResponse = json.decode(response.body);

              String access = jsonResponse['acesso'];
              //String email = jsonResponse['email'];

              if (access == 'OK') {
                if (!mounted) return;
                Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const MainPageForUserState())));
              } else {
                if (!mounted) return;
                await showLoginErrorDialog(context);
              }
            } else {
              if (!mounted) return;
              await showConnectionErrorDialog(context);
            }

            clearFields();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff9a72d),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    ButtonTheme buttonRegisterUser() {
      return ButtonTheme(
        minWidth: screenHeight * 0.2,
        height: screenHeight * 0.1,
        child: ElevatedButton(
          onPressed: () {
            
                Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const RegisterPageCreateState())));
              
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff9a72d),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Cadastro',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffedecf2),
      body: SingleChildScrollView(
          child: Center(
            child:Padding(padding: EdgeInsets.symmetric(vertical: screenHeight * 0.1),
            child: Container(
              width: screenWidth * 0.4,
              padding: EdgeInsets.all(screenHeight * 0.1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // Bordas arredondadas
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Align(
                      alignment: Alignment.center,
                      child: Text("Login",
                          style: titleStyle, textAlign: TextAlign.center)),
                  SizedBox(height: screenHeight * 0.08),
                  emailReturn(),
                  SizedBox(height: screenHeight * 0.05),
                  passwordReturn(),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Alinhamento principal (eixo horizontal)
                children: <Widget>[
                  buttonLoginUser(),
                  SizedBox(width: screenWidth * 0.05),
                  buttonRegisterUser()
                ]
                  )
                ],
              ),
            ),
          ),
          ),
      ),
    );
  }
}
