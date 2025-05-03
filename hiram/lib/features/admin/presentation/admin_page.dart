import 'package:flutter/material.dart';
import 'reported_user/pages/reported_users_tab.dart';
import 'reported_listings/pages/reported_listings_tab.dart';
import 'reported_transactions/reported_transactions_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/presentation/login_page.dart'; // Import your login screen

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        title: const Text('ADMIN'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Listings'),
            Tab(text: 'Transactions'),
            Tab(text: 'Inbox'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const ReportedUsersTab(),
                const ReportedListingsTab(),
                const ReportedTransactionsTab(),
                const Center(child: Text('No Messages')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
