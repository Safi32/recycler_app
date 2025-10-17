import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:recycler/controllers/auth_controller.dart';

class SettlementsScreen extends StatefulWidget {
  SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedGroup;
  List<String> _groups = ['All Groups'];
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  // Load groups from Firebase or your data source
  Future<void> _loadGroups() async {
    try {
      // Fetch unique groups from settlements or users collection
      final snapshot = await _firestore.collection('settlements').get();
      final groups = snapshot.docs
          .map((doc) => doc.data()['group'] as String?)
          .where((group) => group != null)
          .cast<String>()
          .toSet()
          .toList();

      setState(() {
        _groups = ['All Groups', ...groups];
        _selectedGroup = 'All Groups';
      });
    } catch (e) {
      setState(() {
        _selectedGroup = 'All Groups';
      });
    }
  }

  Stream<QuerySnapshot> _getSettlements() {
    Query query = _firestore
        .collection('settlements')
        .orderBy('createdAt', descending: true);

    if (_selectedGroup != null && _selectedGroup != 'All Groups') {
      query = query.where('group', isEqualTo: _selectedGroup);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlements'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildActionButtons(),
          Expanded(child: _buildSettlementsList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Text(
            'Filter by Group:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<String>(
                value: _selectedGroup,
                isExpanded: true,
                underline: const SizedBox(),
                items: _groups.map((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGroup = newValue;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _triggerWeeklySettlements,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Trigger Weekly Settlements'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _exportToCSV,
              icon: const Icon(Icons.download),
              label: const Text('Export to CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getSettlements(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error loading settlements'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No settlements found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final settlements = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: settlements.length,
          itemBuilder: (context, index) {
            final settlementData =
                settlements[index].data() as Map<String, dynamic>;
            final settlementId = settlements[index].id;

            return _buildSettlementCard(settlementData, settlementId, index);
          },
        );
      },
    );
  }

  Widget _buildSettlementCard(Map<String, dynamic> data, String id, int index) {
    final userId = data['userId'] ?? 'N/A';
    final group = data['group'] ?? 'N/A';
    final totalWeight = data['totalWeight']?.toDouble() ?? 0.0;
    final penalty = data['penalty']?.toDouble() ?? 0.0;
    final reward = data['reward']?.toDouble() ?? 0.0;
    final net = reward - penalty;
    final weekStart = data['weekStart'];
    final weekEnd = data['weekEnd'];
    final createdAt = data['createdAt'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.grey[800]!, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settlement #settlement-${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 12),

              // User and Group Info
              _buildInfoRow('User ID:', userId),
              _buildInfoRow('Group:', group),
              _buildInfoRow('Week:', _formatWeek(weekStart, weekEnd)),

              const SizedBox(height: 12),

              // Financial Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Weight: ${totalWeight.toStringAsFixed(2)} kg',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reward: ${reward.toStringAsFixed(2)} credits',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Penalty: ${penalty.toStringAsFixed(2)} credits',
                        style: TextStyle(color: Colors.red[300], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Net: ${net.toStringAsFixed(2)} credits',
                        style: TextStyle(
                          color: net >= 0 ? Colors.green[300] : Colors.red[300],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatWeek(dynamic start, dynamic end) {
    if (start == null || end == null) return 'N/A';
    try {
      final startDate = (start as Timestamp).toDate();
      final endDate = (end as Timestamp).toDate();
      return '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _triggerWeeklySettlements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trigger Weekly Settlements'),
        content: const Text(
          'Are you sure you want to trigger weekly settlements for all users? This will calculate rewards and penalties for each group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processWeeklySettlements();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _processWeeklySettlements() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing settlements...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Calculate date range for the week
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      int processedCount = 0;

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        final userGroup = userData['group'] ?? 'default';

        // Get recycling requests for this user in the week
        final requestsSnapshot = await _firestore
            .collection('recyclingRequests')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'completed')
            .where(
              'completedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
            )
            .where(
              'completedAt',
              isLessThanOrEqualTo: Timestamp.fromDate(weekEnd),
            )
            .get();

        // Calculate total weight
        double totalWeight = 0.0;
        for (var request in requestsSnapshot.docs) {
          final weight = request.data()['weight']?.toDouble() ?? 0.0;
          totalWeight += weight;
        }

        // Calculate rewards and penalties based on weight
        // Reward: 0.5 credits per kg
        final double rewardRate = 0.5;
        final double reward = totalWeight * rewardRate;

        // Penalty: if total weight < 5kg, penalty of 2 credits
        final double minWeightThreshold = 5.0;
        final double penalty = totalWeight < minWeightThreshold ? 2.0 : 0.0;

        // Create settlement document
        await _firestore.collection('settlements').add({
          'userId': userId,
          'userName': userData['name'] ?? 'Unknown',
          'group': userGroup,
          'totalWeight': totalWeight,
          'reward': reward,
          'penalty': penalty,
          'net': reward - penalty,
          'weekStart': Timestamp.fromDate(weekStart),
          'weekEnd': Timestamp.fromDate(weekEnd),
          'createdAt': FieldValue.serverTimestamp(),
          'requestsCount': requestsSnapshot.docs.length,
        });

        // Update user's credits
        final currentCredits = userData['credits']?.toDouble() ?? 0.0;
        final newCredits = currentCredits + reward - penalty;
        await _firestore.collection('users').doc(userId).update({
          'credits': newCredits,
        });

        processedCount++;
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully processed $processedCount settlements'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing settlements: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _exportToCSV() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export to CSV'),
        content: const Text('Select what data you want to export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData('settlements');
            },
            child: const Text('Settlements'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData('requests');
            },
            child: const Text('Requests'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData('users');
            },
            child: const Text('Users'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(String dataType) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing CSV export...'),
                ],
              ),
            ),
          ),
        ),
      );

      String csvContent = '';

      switch (dataType) {
        case 'settlements':
          csvContent = await _generateSettlementsCSV();
          break;
        case 'requests':
          csvContent = await _generateRequestsCSV();
          break;
        case 'users':
          csvContent = await _generateUsersCSV();
          break;
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // In a real app, you would use packages like:
      // - csv package to generate CSV
      // - path_provider to get file path
      // - share_plus or file_picker to save/share the file

      // For now, show success message with data preview
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$dataType CSV Ready'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CSV Preview (first 500 characters):'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      csvContent.length > 500
                          ? '${csvContent.substring(0, 500)}...'
                          : csvContent,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'To save this file, implement file download using packages like share_plus or file_picker.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _generateSettlementsCSV() async {
    final snapshot = await _firestore
        .collection('settlements')
        .orderBy('createdAt', descending: true)
        .get();

    final buffer = StringBuffer();
    buffer.writeln(
      'Settlement ID,User ID,User Name,Group,Total Weight (kg),Reward (credits),Penalty (credits),Net (credits),Week Start,Week End,Created At',
    );

    for (var doc in snapshot.docs) {
      final data = doc.data();
      buffer.writeln(
        '${doc.id},'
        '${data['userId'] ?? ''},'
        '${data['userName'] ?? ''},'
        '${data['group'] ?? ''},'
        '${data['totalWeight'] ?? 0},'
        '${data['reward'] ?? 0},'
        '${data['penalty'] ?? 0},'
        '${data['net'] ?? 0},'
        '${_formatTimestampForCSV(data['weekStart'])},'
        '${_formatTimestampForCSV(data['weekEnd'])},'
        '${_formatTimestampForCSV(data['createdAt'])}',
      );
    }

    return buffer.toString();
  }

  Future<String> _generateRequestsCSV() async {
    final snapshot = await _firestore
        .collection('recyclingRequests')
        .orderBy('createdAt', descending: true)
        .get();

    final buffer = StringBuffer();
    buffer.writeln(
      'Request ID,User ID,Category,Weight (kg),Status,Location,Created At,Completed At',
    );

    for (var doc in snapshot.docs) {
      final data = doc.data();
      buffer.writeln(
        '${doc.id},'
        '${data['userId'] ?? ''},'
        '${data['category'] ?? ''},'
        '${data['weight'] ?? 0},'
        '${data['status'] ?? ''},'
        '${data['location'] ?? ''},'
        '${_formatTimestampForCSV(data['createdAt'])},'
        '${_formatTimestampForCSV(data['completedAt'])}',
      );
    }

    return buffer.toString();
  }

  Future<String> _generateUsersCSV() async {
    final snapshot = await _firestore.collection('users').get();

    final buffer = StringBuffer();
    buffer.writeln(
      'User ID,Name,Email,Phone,Role,Group,Credits,Active,Created At',
    );

    for (var doc in snapshot.docs) {
      final data = doc.data();
      buffer.writeln(
        '${doc.id},'
        '${data['name'] ?? ''},'
        '${data['email'] ?? ''},'
        '${data['phone'] ?? ''},'
        '${data['role'] ?? ''},'
        '${data['group'] ?? ''},'
        '${data['credits'] ?? 0},'
        '${data['isActive'] ?? false},'
        '${_formatTimestampForCSV(data['createdAt'])}',
      );
    }

    return buffer.toString();
  }

  String _formatTimestampForCSV(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    } catch (e) {
      return '';
    }
  }
}
