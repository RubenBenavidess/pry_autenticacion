import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.user;
        final userModel = authService.userModel;

        return Scaffold(
          appBar: AppBar(
            title: Text('Bienvenido'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context, authService),
              ),
            ],
          ),
          drawer: _buildDrawer(context, authService, userModel),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del usuario
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hola, ${userModel?.displayName ?? user?.displayName ?? 'Usuario'}!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rol: ${userModel?.role?.toUpperCase() ?? 'USER'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Información de la cuenta
                Text(
                  'Información de la Cuenta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                _buildInfoCard(
                  title: 'Email',
                  value: user?.email ?? 'No disponible',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 12),

                _buildInfoCard(
                  title: 'Nombre',
                  value:
                      userModel?.displayName ??
                      user?.displayName ??
                      'No disponible',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),

                _buildInfoCard(
                  title: 'Rol',
                  value: userModel?.role ?? 'user',
                  icon: Icons.admin_panel_settings_outlined,
                ),
                const SizedBox(height: 12),

                _buildInfoCard(
                  title: 'Cuenta creada',
                  value: userModel?.createdAt != null
                      ? _formatDate(userModel!.createdAt)
                      : 'No disponible',
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 32),

                // Menú de acciones según el rol
                Text(
                  'Acciones Disponibles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                _buildActionMenu(context, userModel?.role ?? 'user'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, String role) {
    List<Widget> actions = [];

    // Acciones para todos los usuarios
    actions.addAll([
      _buildActionButton(
        title: 'Mi Perfil',
        subtitle: 'Ver y editar información personal',
        icon: Icons.person,
        color: Colors.blue,
        onTap: () => _showSnackBar(context, 'Función de perfil en desarrollo'),
      ),
      const SizedBox(height: 12),
      _buildActionButton(
        title: 'Configuraciones',
        subtitle: 'Ajustes de la aplicación',
        icon: Icons.settings,
        color: Colors.grey,
        onTap: () => _showSnackBar(context, 'Configuraciones en desarrollo'),
      ),
    ]);

    // Acciones específicas para administradores
    if (role == 'admin') {
      actions.addAll([
        const SizedBox(height: 12),
        _buildActionButton(
          title: 'Panel de Administración',
          subtitle: 'Gestionar usuarios y sistema',
          icon: Icons.admin_panel_settings,
          color: Colors.red,
          onTap: () => _showSnackBar(context, 'Panel de admin en desarrollo'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          title: 'Reportes',
          subtitle: 'Ver estadísticas y reportes',
          icon: Icons.analytics,
          color: Colors.green,
          onTap: () => _showSnackBar(context, 'Reportes en desarrollo'),
        ),
      ]);
    }

    return Column(children: actions);
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AuthService authService,
    userModel,
  ) {
    final user = authService.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userModel?.displayName ?? user?.displayName ?? 'Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Perfil en desarrollo');
            },
          ),
          if (userModel?.role == 'admin') ...[
            Divider(),
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: Colors.red),
              title: Text('Panel Admin'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Panel de administración en desarrollo');
              },
            ),
          ],
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuraciones'),
            onTap: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Configuraciones en desarrollo');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Cerrar Sesión'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context, authService);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authService.signOut();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
