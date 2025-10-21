import 'package:flutter/material.dart';

// Esta pantalla será responsable de mostrar la lista de usuarios
// y de lanzar el diálogo para crear uno nuevo.

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {

  // En el futuro, esta lista vendrá de nuestro gestor de estado (Provider/BLoC)
  final List<dynamic> _users = []; 

  // Esta función encapsula toda la lógica y UI para el formulario de creación
  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Usamos un widget separado para el formulario para mantener este archivo limpio
        return const _AddUserDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Equipo'),
        // El color viene de nuestro AppTheme, manteniendo la consistencia
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      // Mostramos un mensaje si la lista está vacía, o la lista si tiene usuarios
      body: _users.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay usuarios en el sistema.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                // TODO: Reemplazar esto con un widget de tarjeta de usuario real
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Usuario ${index + 1}'),
                  subtitle: const Text('Rol: Residente de Obra'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        // El color del botón también lo define nuestro AppTheme
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }
}


// --- Widget Privado para el Diálogo del Formulario ---
// Lo ponemos aquí para no crear un archivo nuevo para un widget que
// solo se usará en esta pantalla. Es una buena práctica de encapsulación.

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir Nuevo Usuario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
             const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Contraseña Temporal'),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Lógica para validar y guardar el usuario
            Navigator.of(context).pop();
          },
          child: const Text('Guardar Usuario'),
        ),
      ],
    );
  }
}