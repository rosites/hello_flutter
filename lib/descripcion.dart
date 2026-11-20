import 'package:flutter/material.dart';

import 'servicio_http.dart';

class PantallaDescripcion extends StatelessWidget {
  final Map<String, dynamic> pelicula;

  const PantallaDescripcion({
    super.key,
    required this.pelicula,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descripción de la película'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      pelicula['imagen'] ?? '',
                      width: 220,
                      height: 330,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.movie,
                          size: 150,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  pelicula['titulo'] ?? '',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  'Año de estreno: ${pelicula['anio']}',
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 10),

                Text(
                  'Director: ${pelicula['director']}',
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 10),

                Text(
                  'Género: ${pelicula['genero']}',
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Sinopsis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  pelicula['sinopsis'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                const Divider(),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.language),
                    label: const Text(
                      'Consultar información en internet',
                    ),
                    onPressed: () {
                      final consulta =
                          ServicioHttp.consultarPelicula(
                        pelicula['titulo'] ?? '',
                      );

                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Información de Wikipedia',
                          ),
                          content: FutureBuilder<String>(
                            future: consulta,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 80,
                                  child: Center(
                                    child:
                                        CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return const Text(
                                  'No se pudo obtener información. '
                                  'Intenta nuevamente.',
                                );
                              }

                              return SingleChildScrollView(
                                child: Text(
                                  snapshot.data ?? '',
                                ),
                              );
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}