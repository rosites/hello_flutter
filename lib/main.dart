
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
  obtenerPokemon();
}

Future<void> obtenerPokemon() async {
  try {
    final url = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon/pikachu',
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);
      debugPrint('Pokémon obtenido: ${datos['name']}');
    } else {
      debugPrint('Error al obtener los datos');
    }
  } catch (e) {
    debugPrint('Error de conexión: $e');
  }
}

// Función para guardar datos en Firebase.
Future<void> guardarPokemon() async {
  await FirebaseFirestore.instance.collection('pokemon').add({
    'nombre': 'Pikachu',
    'tipo': 'Eléctrico',
    'numero': 25,
    'fecha': FieldValue.serverTimestamp(),
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              color: Colors.black87,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<http.Response>(
                    future: http.get(
                      Uri.parse(
                        'https://pokeapi.co/api/v2/pokemon/pikachu',
                      ),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Error al obtener datos',
                          style: TextStyle(color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.data!.statusCode != 200) {
                        return const Text(
                          'Error en la respuesta de la API',
                          style: TextStyle(color: Colors.white),
                        );
                      }

                      final datos = jsonDecode(snapshot.data!.body);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(
                            datos['sprites']['front_default'],
                            width: 120,
                            height: 120,
                          ),
                          Text(
                            'Pokémon: ${datos['name']}',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  const Icon(
                    Icons.movie,
                    size: 70,
                    color: Colors.amber,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Mi catálogo Pokémon',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Conoce a tus Pokémon favoritos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await guardarPokemon();

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '¡Pikachu guardado en Firebase!',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error al guardar: $e',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Guardar en Firebase'),
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



