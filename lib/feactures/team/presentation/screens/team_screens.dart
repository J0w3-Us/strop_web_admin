import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strop_admin_panel/core/providers/team_provider.dart';
import 'package:strop_admin_panel/core/widgets/async_state_builder.dart';

// Esta pantalla será responsable de mostrar la lista de usuarios
// y de lanzar el diálogo para crear uno nuevo.

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    // Load users from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().fetchTeamData();
    });
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
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
      // Mostramos la lista desde el provider
      body: Consumer<TeamProvider>(
        builder: (context, team, _) {
          return AsyncStateBuilder(
            state: team.state,
            loadingBuilder: (ctx) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (ctx, msg) =>
                Center(child: Text(msg ?? 'Error cargando usuarios')),
            successBuilder: (ctx) {
              final users = team.users;
              if (users.isEmpty) {
                return const Center(
                  child: Text(
                    'Aún no hay usuarios en el sistema.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final u = users[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(u.name),
                    subtitle: Text(u.role ?? 'Residente'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await team.delete(u.id);
                      },
                    ),
                  );
                },
              );
            },
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
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir Nuevo Usuario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roleCtrl,
              decoration: const InputDecoration(
                labelText: 'Rol (ej. Residente)',
              ),
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
            final name = _nameCtrl.text.trim();
            final email = _emailCtrl.text.trim();
            final role = _roleCtrl.text.trim();
            if (name.isEmpty) return;
            // Crear usuario via provider
            final team = context.read<TeamProvider>();
            team.create(
              name,
              email: email.isEmpty ? null : email,
              role: role.isEmpty ? null : role,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Guardar Usuario'),
        ),
      ],
    );
  }
}
