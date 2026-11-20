import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaAdministracion extends StatefulWidget {
  const PantallaAdministracion({super.key});

  @override
  State<PantallaAdministracion> createState() =>
      _PantallaAdministracionState();
}

class _PantallaAdministracionState
    extends State<PantallaAdministracion> {
  final titulo = TextEditingController();
  final anio = TextEditingController();
  final director = TextEditingController();
  final genero = TextEditingController();
  final sinopsis = TextEditingController();
  final imagen = TextEditingController();

  bool guardando = false;

  Future<void> agregarPelicula() async {
    final anioNumero = int.tryParse(anio.text.trim());

    if (titulo.text.trim().isEmpty ||
        anioNumero == null ||
        anioNumero <= 0 ||
        director.text.trim().isEmpty ||
        genero.text.trim().isEmpty ||
        sinopsis.text.trim().isEmpty ||
        imagen.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos correctamente'),
        ),
      );
      return;
    }

    final url = Uri.tryParse(imagen.text.trim());

    if (url == null ||
        !['http', 'https'].contains(url.scheme) ||
        url.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce una URL de imagen válida'),
        ),
      );
      return;
    }

    setState(() => guardando = true);

    try {
      await FirebaseFirestore.instance
          .collection('peliculas')
          .add({
        'titulo': titulo.text.trim(),
        'anio': anioNumero,
        'director': director.text.trim(),
        'genero': genero.text.trim(),
        'sinopsis': sinopsis.text.trim(),
        'imagen': imagen.text.trim(),
      });

      if (!mounted) return;

      titulo.clear();
      anio.clear();
      director.clear();
      genero.clear();
      sinopsis.clear();
      imagen.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película agregada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => guardando = false);
      }
    }
  }

  Future<void> eliminarPelicula(String id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar película'),
        content: Text('¿Deseas eliminar "$nombre" del catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('peliculas')
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película eliminada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
        ),
      );
    }
  }

  Widget campo(
    String nombre,
    TextEditingController controlador, {
    int lineas = 1,
    TextInputType tipo = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controlador,
        maxLines: lineas,
        keyboardType: tipo,
        enabled: !guardando,
        decoration: InputDecoration(
          labelText: nombre,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titulo.dispose();
    anio.dispose();
    director.dispose();
    genero.dispose();
    sinopsis.dispose();
    imagen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agregar película',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                campo('Título', titulo),

                campo(
                  'Año de estreno',
                  anio,
                  tipo: TextInputType.number,
                ),

                campo('Director', director),

                campo('Género cinematográfico', genero),

                campo('Sinopsis', sinopsis, lineas: 4),

                campo(
                  'URL de la imagen',
                  imagen,
                  tipo: TextInputType.url,
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        guardando ? null : agregarPelicula,
                    icon: const Icon(Icons.add),
                    label: Text(
                      guardando
                          ? 'Guardando...'
                          : 'Guardar película',
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Divider(),

                const SizedBox(height: 20),

                const Text(
                  'Películas registradas',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('peliculas')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Error al cargar las películas',
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
                      return const Text(
                        'No hay películas registradas',
                      );
                    }

                    return Column(
                      children: peliculas.map((documento) {
                        final pelicula = documento.data()
                            as Map<String, dynamic>;

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.movie),
                            title: Text(
                              pelicula['titulo'] ?? '',
                            ),
                            subtitle: Text(
                              '${pelicula['anio']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Eliminar película',
                              onPressed: () {
                                eliminarPelicula(
                                  documento.id,
                                  pelicula['titulo'] ?? '',
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}