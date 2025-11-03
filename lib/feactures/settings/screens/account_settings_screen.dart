import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de configuración de cuenta del administrador
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEmailValidated = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    if (_emailFormKey.currentState!.validate()) {
      // Simular envío de código de verificación
      setState(() => _isEmailValidated = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código de verificación enviado a ${_newEmailController.text}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Mostrar diálogo de confirmación
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email Validado'),
          content: Text(
            'Se ha enviado un código de verificación a:\n${_newEmailController.text}\n\nPor favor, revisa tu bandeja de entrada.',
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Entendido'))],
        ),
      );
    }
  }

  void _changePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      // Verificar que las contraseñas coinciden
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Simular cambio de contraseña
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contraseña Cambiada'),
          content: const Text(
            'Tu contraseña ha sido actualizada correctamente.\n\n'
            'Por seguridad, serás redirigido a la pantalla de inicio de sesión.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8800)),
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Configuración de Cuenta',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF0A2C52)),
            ),
            const SizedBox(height: 32),

            // Sección de Validación de Email
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _emailFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, color: Color(0xFF0A2C52), size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Validación de Email',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A2C52)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Verifica tu dirección de correo electrónico para mayor seguridad.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _newEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Nuevo Email',
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icon(Icons.alternate_email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        // Validación comentada para pruebas contra API externa.
                        // Descomentar el bloque siguiente cuando quieras reactivar la validación local.
                        /*
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un email';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Ingresa un email válido';
                          }
                          return null;
                        },
                        */
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _validateEmail,
                            icon: const Icon(Icons.verified_outlined),
                            label: const Text('Validar Email'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A2C52),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          if (_isEmailValidated) ...[
                            const SizedBox(width: 16),
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Email validado',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección de Cambio de Contraseña
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_outlined, color: Color(0xFF0A2C52), size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Cambiar Contraseña',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A2C52)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Actualiza tu contraseña para mantener tu cuenta segura.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // Contraseña Actual
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña Actual',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                          ),
                        ),
                        // Comentado para permitir pruebas sin validación local.
                        /*
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña actual';
                          }
                          return null;
                        },
                        */
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 16),

                      // Nueva Contraseña
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'Nueva Contraseña',
                          prefixIcon: const Icon(Icons.vpn_key),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                          ),
                        ),
                        // Comentado para pruebas con API. Descomentar para reactivar reglas de contraseña.
                        /*
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una nueva contraseña';
                          }
                          if (value.length < 8) {
                            return 'La contraseña debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                        */
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 16),

                      // Confirmar Nueva Contraseña
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Nueva Contraseña',
                          prefixIcon: const Icon(Icons.check_circle_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        // Comentado para permitir pruebas rápidas sin validación local.
                        /*
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirma tu nueva contraseña';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                        */
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 24),

                      // Indicador de seguridad de contraseña
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'La contraseña debe tener al menos 8 caracteres.',
                                style: TextStyle(color: Colors.blue, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón de Cambiar Contraseña
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _changePassword,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Cambiar Contraseña'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
