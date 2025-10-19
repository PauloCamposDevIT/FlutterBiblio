import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/my_book_model.dart';
import '../widgets/my_book_card.dart';
import '../widgets/my_custom_appbar.dart';

class ReadListScreen extends StatelessWidget {
  const ReadListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFCE1),
      appBar: const CustomAppBar(title: 'Livros Lidos'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('livrosLidos')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final livrosLidos = snapshot.data!.docs.map((doc) {
            return Livro(
              id: doc['livroId'],
              titulo: doc['titulo'],
              autor: doc['autor'],
              urlImagem: doc['urlImagem'],
            );
          }).toList();

          return ListView.builder(
            itemCount: livrosLidos.length,
            itemBuilder: (context, index) => BookCard(livro: livrosLidos[index]),
          );
        },
      ),
    );
  }
}