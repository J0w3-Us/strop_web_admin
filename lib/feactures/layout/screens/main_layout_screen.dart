import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App Shell profesional con Top App Bar, sidebar colapsable, breadcrumbs y Drawer en pantallas chicas
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _collapsed = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        final isWide = constraints.maxWidth >= 1200;
        final showSidebar = !isNarrow;
        final collapsed = showSidebar ? (_collapsed || !isWide) : false;
        final sidebarWidth = collapsed ? 72.0 : 240.0;

        final navItems = <_NavItemData>[
          _NavItemData(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: '/app/dashboard',
          ),
          _NavItemData(
            icon: Icons.folder_open_outlined,
            label: 'Proyectos',
            route: '/app/projects',
          ),
          _NavItemData(
            icon: Icons.bug_report_outlined,
            label: 'Incidencias',
            route: '/app/incidents',
          ),
          _NavItemData(
            icon: Icons.verified_outlined,
            label: 'Autorizaciones',
            route: '/app/authorizations',
          ),
        ];

        Widget topBar() {
          return Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (isNarrow)
                  IconButton(
                    tooltip: 'Menú',
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                if (!isNarrow)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      'STROP',
                      style: TextStyle(
                        color: const Color(0xFF0A2C52),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                if (!isNarrow)
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v) {
                          final q = v.trim();
                          if (q.isNotEmpty) {
                            context.go(
                              '/app/projects?q=${Uri.encodeComponent(q)}',
                            );
                          }
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF8A9BB5),
                          ),
                          hintText: 'Buscar...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                PopupMenuButton<int>(
                  tooltip: 'Notificaciones',
                  icon: const Icon(Icons.notifications_outlined),
                  onSelected: (value) {
                    switch (value) {
                      case 1:
                        context.go('/app/authorizations');
                        break;
                      case 2:
                        context.go('/app/incidents');
                        break;
                      default:
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 1,
                      child: Text('2 nuevas autorizaciones'),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('1 incidencia abierta'),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(value: 0, child: Text('Ver todas')),
                  ],
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Cuenta',
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.go('/login');
                    } else if (value == 'settings') {
                      context.go('/app/settings');
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'profile', child: Text('Perfil')),
                    PopupMenuItem(
                      value: 'settings',
                      child: Text('Configuración'),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Cerrar sesión'),
                    ),
                  ],
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF0A2C52),
                    child: Text('S', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        }

        Widget breadcrumbs() {
          final crumbs = _buildBreadcrumbs(location);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFFF5F7FB)),
            child: Row(
              children: [
                for (var i = 0; i < crumbs.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF8A9BB5),
                      ),
                    ),
                  if (crumbs[i].route != null)
                    InkWell(
                      onTap: () => context.go(crumbs[i].route!),
                      child: Text(
                        crumbs[i].label,
                        style: const TextStyle(
                          color: Color(0xFF0A2C52),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      crumbs[i].label,
                      style: const TextStyle(color: Color(0xFF8A9BB5)),
                    ),
                ],
              ],
            ),
          );
        }

        Widget sidebar({bool inDrawer = false}) {
          final content = Container(
            width: inDrawer ? null : sidebarWidth,
            height: double.infinity,
            color: const Color(0xFF0A2C52),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: collapsed
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: collapsed ? 0 : 16.0,
                    ),
                    child: collapsed
                        ? const Text(
                            'S',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          )
                        : const Text(
                            'STROP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (final item in navItems)
                          _SideNavItem(
                            icon: item.icon,
                            label: item.label,
                            selected: location.startsWith(item.route),
                            collapsed: collapsed,
                            onTap: () {
                              if (inDrawer) Navigator.of(context).pop();
                              context.go(item.route);
                            },
                          ),
                      ],
                    ),
                  ),
                  if (!isNarrow)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: collapsed ? 0 : 8,
                        vertical: 8,
                      ),
                      child: _SideNavItem(
                        icon: Icons.logout,
                        label: 'Cerrar sesión',
                        collapsed: collapsed,
                        selected: false,
                        onTap: () => context.go('/login'),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );

          // Auto expand/collapse on hover (no botones de colapsar/pin)
          return inDrawer
              ? content
              : MouseRegion(
                  onEnter: (_) => setState(() => _collapsed = false),
                  onExit: (_) => setState(() => _collapsed = true),
                  child: content,
                );
        }

        // BODY
        return Scaffold(
          key: _scaffoldKey,
          drawer: isNarrow
              ? Drawer(width: 280, child: sidebar(inDrawer: true))
              : null,
          body: Container(
            color: const Color(0xFFF5F7FB),
            child: showSidebar
                ? Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: sidebarWidth,
                        child: sidebar(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            topBar(),
                            breadcrumbs(),
                            Expanded(
                              child: SafeArea(top: false, child: widget.child),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      topBar(),
                      breadcrumbs(),
                      Expanded(
                        child: SafeArea(top: false, child: widget.child),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  List<_Crumb> _buildBreadcrumbs(String location) {
    // Default crumbs
    final List<_Crumb> crumbs = [_Crumb('Inicio', '/app/dashboard')];
    if (location.startsWith('/app/projects')) {
      crumbs.add(_Crumb('Proyectos', '/app/projects'));
      if (location.endsWith('/new')) {
        crumbs.add(_Crumb('Nuevo', null));
      } else if (RegExp(r'^/app/projects/[^/]+$').hasMatch(location)) {
        crumbs.add(_Crumb('Detalle', null));
      }
    } else if (location.startsWith('/app/incidents')) {
      crumbs.add(_Crumb('Incidencias', null));
    } else if (location.startsWith('/app/authorizations')) {
      crumbs.add(_Crumb('Autorizaciones', null));
    } else if (location.startsWith('/app/dashboard')) {
      // already covered
    }
    return crumbs;
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}

class _Crumb {
  const _Crumb(this.label, this.route);
  final String label;
  final String? route;
}

class _SideNavItem extends StatefulWidget {
  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
    this.collapsed = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? Colors.white.withValues(alpha: 0.08)
        : _hovered
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.transparent;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 0.0 : 12.0,
            vertical: 10.0,
          ),
          decoration: BoxDecoration(
            color: bg,
            border: widget.selected
                ? const Border(left: BorderSide(color: Colors.white, width: 2))
                : null,
          ),
          child: widget.collapsed
              ? Center(
                  child: Icon(widget.icon, color: Colors.white70, size: 20),
                )
              : Row(
                  children: [
                    Icon(widget.icon, color: Colors.white70),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
