import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/domain.dart';
import '../core/services.dart';
import '../features/feature_pages.dart';
import '../theme/app_theme.dart';

class UtmPawsitiveApp extends StatelessWidget {
  const UtmPawsitiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTM Paws-itive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
      },
    );
  }
}

class PawsitiveApp extends UtmPawsitiveApp {
  const PawsitiveApp({super.key});
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return StreamBuilder<AppUserProfile?>(
          stream: FirestoreGateway.instance.watchUser(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              return const _MissingProfile();
            }

            if (profile.isSuspended) {
              return _SuspendedAccount(profile: profile);
            }

            return RoleShell(profile: profile);
          },
        );
      },
    );
  }
}

class RoleShell extends StatefulWidget {
  const RoleShell({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  late int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = _pagesForRole(widget.profile.role);
    final destinations = _destinationsForRole(widget.profile.role);

    if (_index >= pages.length) {
      _index = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile.role.label),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationsPage(profile: widget.profile))),
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () => AuthService.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations,
      ),
    );
  }

  List<Widget> _pagesForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          OverviewPage(profile: widget.profile),
          ReportsPage(profile: widget.profile),
          CatsPage(profile: widget.profile),
          ShopPage(profile: widget.profile),
          AdminPage(profile: widget.profile),
        ];
      case UserRole.volunteer:
        return [
          VolunteerCasesPage(profile: widget.profile),
          MapPage(profile: widget.profile),
          CatsPage(profile: widget.profile),
          LeaderboardPage(profile: widget.profile),
          ProfilePage(profile: widget.profile),
        ];
      case UserRole.user:
        return [
          WelcomePage(profile: widget.profile),
          ReportCatPage(profile: widget.profile),
          CatsPage(profile: widget.profile),
          ShopPage(profile: widget.profile),
          ProfilePage(profile: widget.profile),
        ];
    }
  }

  List<NavigationDestination> _destinationsForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Cats'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ];
      case UserRole.volunteer:
        return const [
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Cases'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Cats'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Rankings'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ];
      case UserRole.user:
        return const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_a_photo_outlined), selectedIcon: Icon(Icons.add_a_photo), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Cats'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ];
    }
  }
}

class _MissingProfile extends StatelessWidget {
  const _MissingProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 68),
              const SizedBox(height: 12),
              Text('Profile not found', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Contact an administrator to complete your account setup.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuspendedAccount extends StatelessWidget {
  const _SuspendedAccount({required this.profile});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 68, color: Colors.red),
              const SizedBox(height: 12),
              Text('Account suspended', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${profile.fullName} cannot access the system right now.'),
            ],
          ),
        ),
      ),
    );
  }
}
