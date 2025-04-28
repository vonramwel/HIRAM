import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 8),
          const Text(
            'Maria Clara',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportedUsersTab(),
                _buildReportedListingsTab(),
                _buildReportedTransactionsTab(),
                const Center(child: Text('No Messages')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportedUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('user_reports').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            return _buildReportCard(
              title:
                  "First Name Last Name", // You can fetch actual user data if needed
              subtitle: report['reason'] ?? '',
              onAlert: () {},
              onFreeze: () {},
              onBan: () {},
            );
          },
        );
      },
    );
  }

  Widget _buildReportedListingsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('listing_reports').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            return _buildReportCard(
              title: "Listing ID: ${report['listingId']}",
              subtitle: report['reason'] ?? '',
              onAlert: () {},
              onFreeze: null,
              onBan: null,
            );
          },
        );
      },
    );
  }

  Widget _buildReportedTransactionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transaction_reports')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            return _buildReportCard(
              title: "Transaction ID: ${report['transactionId']}",
              subtitle: report['reason'] ?? '',
              onAlert: () {},
              onFreeze: null,
              onBan: null,
            );
          },
        );
      },
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required VoidCallback onAlert,
    VoidCallback? onFreeze,
    VoidCallback? onBan,
  }) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: onAlert, child: const Text('Alert')),
                      const SizedBox(width: 8),
                      if (onFreeze != null)
                        ElevatedButton(
                            onPressed: onFreeze, child: const Text('Freeze')),
                      const SizedBox(width: 8),
                      if (onBan != null)
                        ElevatedButton(
                          onPressed: onBan,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Ban'),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
