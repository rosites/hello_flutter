import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'descripcion.dart';
import 'administracion.dart';

class PantallaCatalogo extends StatelessWidget {
  const PantallaCatalogo({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    final esAdministrador =
        usuario?.uid == 'IPivky9tyNfO49tiEuDqIkyrrdA2';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de películas'),
        backgroundColor: Colors.amber,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menú',
            onSelected: (opcion) async {
              if (opcion == 'administracion' &&
                  esAdministrador) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PantallaAdministracion(),
                  ),
                );
              } else if (opcion == 'salir') {
                await FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'catalogo',
                child: Row(
                  children: [
                    Icon(Icons.movie),
                    SizedBox(width: 12),
                    Text('Catálogo de películas'),
                  ],
                ),
              ),
              if (esAdministrador)
                const PopupMenuItem(
                  value: 'administracion',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 12),
                      Text('Administración'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'salir',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('peliculas')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar las películas'),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final peliculas = snapshot.data!.docs;

          if (peliculas.isEmpty) {
            return const Center(
              child: Text('No hay películas disponibles'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: peliculas.length,
            itemBuilder: (context, index) {
              final pelicula =
                  peliculas[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Image.network(
                    pelicula['imagen'] ?? '',
                    width: 65,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.movie, size: 50);
                    },
                  ),
                  title: Text(
                    pelicula['titulo'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${pelicula['anio']} • ${pelicula['genero']}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PantallaDescripcion(
                          pelicula: pelicula,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}