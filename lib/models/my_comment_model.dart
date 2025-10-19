import 'package:cloud_firestore/cloud_firestore.dart';

class Comentario {
  final String id;
  final String livroId;
  final String userId;
  final String texto;
  final DateTime data;

  Comentario({
    required this.id,
    required this.livroId,
    required this.userId,
    required this.texto,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'livroId': livroId,
      'userId': userId,
      'texto': texto,
      'data': Timestamp.fromDate(data),
    };
  }
}
