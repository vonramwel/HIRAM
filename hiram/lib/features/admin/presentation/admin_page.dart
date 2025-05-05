import 'package:flutter/material.dart';
import 'reported_user/pages/reported_users_tab.dart';
import 'reported_listings/pages/reported_listings_tab.dart';
import 'reported_transactions/reported_transactions_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/presentation/login_page.dart'; // Import your login screen
import '../../inbox/presentation/inbox_page.dart'; // Import your inbox screen
import '../../../testing/mock_up_data.dart'; // Adjust the path based on your structure

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
                  const InboxPage()
                ],
              ),
            ),
          ],
        ));
    // //   floatingActionButton: FloatingActionButton(
    // //     onPressed: () async {
    // //       final generator = MockListingGenerator();

    // //       try {
    // //         await generator.generateMockListings(
    // //             count: 10); // You can adjust the count
    // //         if (context.mounted) {
    // //           ScaffoldMessenger.of(context).showSnackBar(
    // //             const SnackBar(
    // //                 content: Text("Mock listings generated successfully")),
    // //           );
    // //         }
    // //       } catch (e) {
    // //         if (context.mounted) {
    // //           ScaffoldMessenger.of(context).showSnackBar(
    // //             SnackBar(content: Text("Failed to generate mock listings: $e")),
    // //           );
    // //         }
    // //       }
    // //     },
    // //     child: const Icon(Icons.add),
    // //     tooltip: 'Generate Mock Listings',
    // //   ),
    // // );
  }
}
