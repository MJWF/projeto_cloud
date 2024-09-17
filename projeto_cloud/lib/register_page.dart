import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:projeto_cloud/login_page.dart';

class RegisterPageCreateState extends StatefulWidget {
  const RegisterPageCreateState({super.key});

  @override
  State<RegisterPageCreateState> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPageCreateState> {
  late double screenHeight;
  late double screenWidth;
  late double fontSizeAsPercentage;
  late TextStyle titleStyle;

  String emailCadastro = "";
  String emailRewriteCadastro = "";
  String passwordCadastro = "";
  String passwordRewriteCadastro = "";

  String errorTextValEmail = "";
  String errorTextValPassword = "";

  TextEditingController emailTextField = TextEditingController();
  TextEditingController emailRewriteTextField = TextEditingController();
  TextEditingController passwordTextField = TextEditingController();
  TextEditingController passwordRewriteTextField = TextEditingController();

  Future<void> confirmPopUpDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cadastro feito com sucesso!'),
          content: const Text('O usuário já está disponível.'),
          actions: <Widget>[
              popOutShowDialog(context)
            ],
          );
        },
      );
    }

    Future<void> createErrorPopUpDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro ao criar usuário'),
          content: const Text('Campos não foram preenchidos corretamente'),
          actions: <Widget>[
              popOutShowDialog(context)
            ],
          );
        },
      );
    }

    TextButton popOutShowDialog(BuildContext context){
      return TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
        emailRewriteTextField.clear();
        passwordTextField.clear();
        passwordRewriteTextField.clear();
      });
    }

    SizedBox emailReturn() {
      return SizedBox(
        width: screenHeight * 0.5,
        child: TextField(
          onChanged: (text) {
            emailCadastro = text;
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
            labelText: 'Email do novo usuário',
          ),
        ),
      );
    }

    SizedBox emailRewriteReturn() {
      return SizedBox(
        width: screenHeight * 0.5,
        child: TextField(
          onChanged: (text) {
            emailRewriteCadastro = text;
            setState(() {
              if (text != emailCadastro) {
                errorTextValEmail = "Os emails não coincidem.";
              } else if (!text.contains("@")){
                errorTextValEmail = "O email não é válido.";
              } else {
                errorTextValEmail = "";
              }
            });
          },
          controller: emailRewriteTextField,
          decoration: InputDecoration(
            errorText: errorTextValEmail.isEmpty ? null : errorTextValEmail,
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(20.0),
            ),
            labelText: 'Confirme o email do novo usuário',
          ),
        ),
      );
    }

    SizedBox passwordReturn() {
      return SizedBox(
        width: screenHeight * 0.5,
        child: TextField(
          onChanged: (text) {
            passwordCadastro = text;
          },
          obscureText: true,
          controller: passwordTextField,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(20.0),
            ),
            labelText: 'Senha do novo usuário',
          ),
        ),
      );
    }

    SizedBox passwordRewriteReturn() {
      return SizedBox(
        width: screenHeight * 0.5,
        child: TextField(
          onChanged: (text) {
            passwordRewriteCadastro = text;
            setState(() {
              if (text != passwordCadastro) {
                errorTextValPassword = "As senhas não coincidem.";
              } else {
                errorTextValPassword = "";
              }
            });
          },
          controller: passwordRewriteTextField,
          obscureText: true,
          decoration: InputDecoration(
            errorText:
                errorTextValPassword.isEmpty ? null : errorTextValPassword,
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(20.0),
            ),
            labelText: 'Confirme a senha do novo usuário',
          ),
        ),
      );
    }

    ButtonTheme buttonCreateNewUser() {
      return ButtonTheme(
        minWidth: screenHeight * 0.2,
        height: screenHeight * 0.1,
        child: ElevatedButton(
          onPressed: () async {

            if(emailTextField.text.isEmpty || emailRewriteTextField.text.isEmpty || passwordRewriteTextField.text.isEmpty || passwordTextField.text.isEmpty){
                
              await createErrorPopUpDialog(context);
            } else if(emailCadastro != emailRewriteCadastro || passwordCadastro != passwordRewriteCadastro){
              
              await createErrorPopUpDialog(context);

            } else {
            final url = Uri.parse('http://192.168.132.137:5000/cadastro');

              final response = await http.post(url, body: {
                'email': emailCadastro,
                'password': passwordCadastro,
              });

              final jsonResponse = json.decode(response.body);
              String access = jsonResponse['acesso'];

              if (access == 'OK') {
                if (!mounted) return;
                confirmPopUpDialog(context);
              } else {
                if (!mounted) return;
                createErrorPopUpDialog(context);
              }
            }
            

            clearFields();
            Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const LoginPageCreateState())));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff9a72d),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Criar Usuário',
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
                  child: Text("Cadastro",
                      style: titleStyle, textAlign: TextAlign.center)),

              SizedBox(height: screenHeight * 0.03),
              emailReturn(),
              SizedBox(height: screenHeight * 0.03),
              emailRewriteReturn(),
              SizedBox(height: screenHeight * 0.03),
              passwordReturn(),
              SizedBox(height: screenHeight * 0.03),
              passwordRewriteReturn(),
              SizedBox(height: screenHeight * 0.03),
              buttonCreateNewUser()
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}