import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaAutenticacion extends StatefulWidget {
  final bool esRegistro;

  const PantallaAutenticacion({
    super.key,
    required this.esRegistro,
  });

  @override
  State<PantallaAutenticacion> createState() =>
      _PantallaAutenticacionState();
}

class _PantallaAutenticacionState
    extends State<PantallaAutenticacion> {
  final correo = TextEditingController();
  final contrasena = TextEditingController();

  bool cargando = false;

  Future<void> autenticar() async {
    if (correo.text.trim().isEmpty || contrasena.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      if (widget.esRegistro) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: correo.text.trim(),
          password: contrasena.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: correo.text.trim(),
          password: contrasena.text,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensaje = 'No se pudo completar la solicitud';

      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña debe tener al menos 6 caracteres';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo electrónico no es válido';
      } else if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        mensaje = 'Correo o contraseña incorrectos';
      } else if (e.code == 'network-request-failed') {
        mensaje = 'Comprueba tu conexión a internet';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  @override
  void dispose() {
    correo.dispose();
    contrasena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esRegistro ? 'Registrarse' : 'Iniciar sesión',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: SizedBox(
            width: 350,
            child: Column(
              children: [
                const Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.amber,
                ),

                const SizedBox(height: 20),

                Text(
                  widget.esRegistro
                      ? 'Crear una cuenta'
                      : 'Ingresa a tu cuenta',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: correo,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: contrasena,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cargando ? null : autenticar,
                    child: cargando
                        ? const CircularProgressIndicator()
                        : Text(
                            widget.esRegistro
                                ? 'Crear cuenta'
                                : 'Iniciar sesión',
                          ),
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