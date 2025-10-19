import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/my_comment_model.dart';

class CommentWidget extends StatelessWidget {
  final Comentario comentario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommentWidget({
    super.key,
    required this.comentario,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = comentario.userId == Provider.of<User?>(context)?.uid;

    return Card(
      color: const Color(0xFFEBD0BD),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comentario.texto,
              style: const TextStyle(fontSize: 16, color: Colors.brown),

            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(comentario.data),
                  style: TextStyle(color: Colors.blueGrey[600], fontSize: 12),
                ),
                if (isCurrentUser)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Colors.brown),
                        tooltip: 'Editar',
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.brown),
                        tooltip: 'Apagar',
                        onPressed: onDelete,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
