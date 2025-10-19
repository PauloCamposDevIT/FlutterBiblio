import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class TelaRegisto extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TelaRegisto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFCE1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Icon(
                    Icons.person_add,
                    size: 72,
                    color: Color(0xFF9d6550),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "Criar Conta",
                    style: TextStyle(
                      color: Color(0xFF9d6550),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Formulário para o registo
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // parte do email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Color(0xFF9D6550)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF9d6550), width: 2),
                            ),
                            filled: true,
                            fillColor: Color(0xFFfaeee5),
                          ),
                          validator: (value) =>
                          value!.contains('@') ? null : 'Email inválido',
                        ),
                        const SizedBox(height: 15),

                        // parte da password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Color(0xFF9D6550)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF9d6550), width: 2),
                            ),
                            filled: true,
                            fillColor: Color(0xFFfaeee5),
                          ),
                          validator: (value) =>
                          value!.length >= 6 ? null : 'Mínimo 6 caracteres',
                        ),
                        const SizedBox(height: 15),

                        // Botão para fazer o registo
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF9d6550),
                              foregroundColor: Color(0xFFfaeee5),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                User? user = await AuthService().signUp(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                if (user != null) {
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                }
                              }
                            },
                            child: const Text(
                              'Registar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // route de volta para o log in
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Já tem conta?"),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Inicie sessão aqui",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9D6550),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
