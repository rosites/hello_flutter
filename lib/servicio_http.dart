import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicioHttp {
  static Future<String> consultarPelicula(String titulo) async {
    final url = Uri.https(
      'es.wikipedia.org',
      '/w/api.php',
      {
        'action': 'query',
        'generator': 'search',
        'gsrsearch': '$titulo película',
        'gsrlimit': '1',
        'prop': 'extracts',
        'exintro': '1',
        'explaintext': '1',
        'format': 'json',
        'origin': '*',
      },
    );

    final respuesta = await http.get(url).timeout(
      const Duration(seconds: 15),
    );

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);
      final paginas = datos['query']?['pages'];

      if (paginas != null && paginas.isNotEmpty) {
        final pagina = paginas.values.first;

        return pagina['extract'] ??
            'No se encontró información adicional.';
      }

      return 'No se encontró información sobre esta película.';
    }

    throw Exception('Error al consultar Wikipedia');
  }
}