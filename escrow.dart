import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EscrowPaymentAdmin extends StatefulWidget {
  const EscrowPaymentAdmin({super.key});

  @override
  State<EscrowPaymentAdmin> createState() => _EscrowPaymentAdminState();
}

class _EscrowPaymentAdminState extends State<EscrowPaymentAdmin> {
  final List<EscrowTransaction> transactions = [
    EscrowTransaction(
      id: 'ESC-001',
      amount: 2500.00,
      sender: 'John Smith',
      receiver: 'Sarah Johnson',
      status: EscrowStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Website Development Project',
    ),
    EscrowTransaction(
      id: 'ESC-002',
      amount: 1500.00,
      sender: 'Mike Wilson',
      receiver: 'Emma Davis',
      status: EscrowStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Mobile App Design',
    ),
    EscrowTransaction(
      id: 'ESC-003',
      amount: 3200.00,
      sender: 'Tech Solutions Inc.',
      receiver: 'Creative Agency Ltd.',
      status: EscrowStatus.disputed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      description: 'E-commerce Platform',
    ),
    EscrowTransaction(
      id: 'ESC-004',
      amount: 1800.00,
      sender: 'David Brown',
      receiver: 'Lisa Miller',
      status: EscrowStatus.held,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      description: 'Logo Design Package',
    ),
  ];

  EscrowStatus _selectedFilter = EscrowStatus.all;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 24),

            // Stats Cards
            _buildStatsCards(),
            const SizedBox(height: 24),

            // Controls Section
            _buildControlsSection(),
            const SizedBox(height: 16),

            // Transactions Table
            Expanded(
              child: _buildTransactionsTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escrow Payments',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage and monitor all escrow transactions',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: const Color(0xFF1A1A1A).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        _StatCard(
          title: 'Total Escrow',
          value: '\$9,000.00',
          color: const Color(0xFF0066FF),
          icon: Icons.account_balance_wallet,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: 'Pending',
          value: '\$2,500.00',
          color: const Color(0xFFFFA000),
          icon: Icons.pending_actions,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: 'Completed',
          value: '\$1,500.00',
          color: const Color(0xFF00C853),
          icon: Icons.check_circle,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: 'Disputed',
          value: '\$3,200.00',
          color: const Color(0xFFF44336),
          icon: Icons.warning,
        ),
      ],
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          // Search Box
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                  hintText: 'Search transactions...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xFF666666),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<EscrowStatus>(
                value: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
                items: EscrowStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.displayName,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // New Escrow Button
          ElevatedButton.icon(
            onPressed: () {
              _showCreateEscrowDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'New Escrow',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable() {
    final filteredTransactions = transactions.where((transaction) {
      final matchesSearch = _searchQuery.isEmpty ||
          transaction.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          transaction.sender.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          transaction.receiver.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == EscrowStatus.all ||
          transaction.status == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Transaction ID',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Parties',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return _TransactionRow(
                  transaction: transaction,
                  onAction: (action) {
                    _handleTransactionAction(action, transaction);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateEscrowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create New Escrow',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Sender',
                  labelStyle: const TextStyle(fontFamily: 'Roboto'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Receiver',
                  labelStyle: const TextStyle(fontFamily: 'Roboto'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: const TextStyle(fontFamily: 'Roboto'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(fontFamily: 'Roboto'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Roboto'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle escrow creation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Create Escrow',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTransactionAction(EscrowAction action, EscrowTransaction transaction) {
    switch (action) {
      case EscrowAction.view:
        _showTransactionDetails(transaction);
        break;
      case EscrowAction.release:
        _releaseFunds(transaction);
        break;
      case EscrowAction.hold:
        _holdFunds(transaction);
        break;
      case EscrowAction.resolve:
        _resolveDispute(transaction);
        break;
    }
  }

  void _showTransactionDetails(EscrowTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Transaction Details - ${transaction.id}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(title: 'Amount:', value: '\$${transaction.amount.toStringAsFixed(2)}'),
              _DetailRow(title: 'Sender:', value: transaction.sender),
              _DetailRow(title: 'Receiver:', value: transaction.receiver),
              _DetailRow(title: 'Status:', value: transaction.status.displayName),
              _DetailRow(title: 'Created:', value: DateFormat('MMM dd, yyyy').format(transaction.createdAt)),
              _DetailRow(title: 'Description:', value: transaction.description),
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

  void _releaseFunds(EscrowTransaction transaction) {
    // Implement release funds logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funds released for ${transaction.id}'),
        backgroundColor: const Color(0xFF00C853),
      ),
    );
  }

  void _holdFunds(EscrowTransaction transaction) {
    // Implement hold funds logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funds held for ${transaction.id}'),
        backgroundColor: const Color(0xFFFFA000),
      ),
    );
  }

  void _resolveDispute(EscrowTransaction transaction) {
    // Implement dispute resolution logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dispute resolved for ${transaction.id}'),
        backgroundColor: const Color(0xFF0066FF),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: const Color(0xFF1A1A1A).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final EscrowTransaction transaction;
  final Function(EscrowAction) onAction;

  const _TransactionRow({
    required this.transaction,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE0E0E0).withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.id,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: const Color(0xFF1A1A1A).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: ${transaction.sender}',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  'To: ${transaction.receiver}',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: transaction.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: transaction.status.color),
              ),
              child: Text(
                transaction.status.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: transaction.status.color,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              child: Text(
                DateFormat('MMM dd, yyyy').format(transaction.createdAt),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 18),
                  color: const Color(0xFF0066FF),
                  onPressed: () => onAction(EscrowAction.view),
                ),

                if (transaction.status == EscrowStatus.pending) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle, size: 18),
                    color: const Color(0xFF00C853),
                    onPressed: () => onAction(EscrowAction.release),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause_circle, size: 18),
                    color: const Color(0xFFFFA000),
                    onPressed: () => onAction(EscrowAction.hold),
                  ),
                ],
                if (transaction.status == EscrowStatus.disputed)
                  IconButton(
                    icon: const Icon(Icons.gavel, size: 18),
                    color: const Color(0xFF0066FF),
                    onPressed: () => onAction(EscrowAction.resolve),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum EscrowStatus {
  all('All', Colors.grey),
  pending('Pending', Color(0xFFFFA000)),
  completed('Completed', Color(0xFF00C853)),
  disputed('Disputed', Color(0xFFF44336)),
  held('Held', Color(0xFF9C27B0));

  final String displayName;
  final Color color;

  const EscrowStatus(this.displayName, this.color);
}

enum EscrowAction {
  view,
  release,
  hold,
  resolve,
}

class EscrowTransaction {
  final String id;
  final double amount;
  final String sender;
  final String receiver;
  final EscrowStatus status;
  final DateTime createdAt;
  final String description;

  const EscrowTransaction({
    required this.id,
    required this.amount,
    required this.sender,
    required this.receiver,
    required this.status,
    required this.createdAt,
    required this.description,
  });
}
