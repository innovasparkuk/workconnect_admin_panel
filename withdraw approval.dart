import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WithdrawApprovals extends StatefulWidget {
  const WithdrawApprovals({super.key});

  @override
  State<WithdrawApprovals> createState() => _WithdrawApprovalsState();
}

class _WithdrawApprovalsState extends State<WithdrawApprovals> {
  final List<WithdrawalRequest> _withdrawalRequests = [
    WithdrawalRequest(
      id: 'WD001',
      userName: 'John Doe',
      amount: 2500.00,
      method: 'Bank Transfer',
      accountNumber: '****1234',
      requestDate: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'Pending',
      userId: 'USR001',
    ),
    WithdrawalRequest(
      id: 'WD002',
      userName: 'Sarah Wilson',
      amount: 1500.50,
      method: 'PayPal',
      accountNumber: 'sarah@email.com',
      requestDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'Pending',
      userId: 'USR002',
    ),
    WithdrawalRequest(
      id: 'WD003',
      userName: 'Mike Johnson',
      amount: 3200.75,
      method: 'Bank Transfer',
      accountNumber: '****5678',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Pending',
      userId: 'USR003',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Statistics Cards
          _buildStatisticsCards(),
          const SizedBox(height: 24),

          // Withdrawal Requests Table
          Expanded(
            child: _buildWithdrawalTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Withdraw Approvals',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and approve withdrawal requests from users',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: const Color(0xFF1A1A1A).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending Requests',
              _withdrawalRequests.length.toString(),
              Icons.pending_actions,
              const Color(0xFFFFA000),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total Amount',
              '\$${_calculateTotalAmount()}',
              Icons.attach_money,
              const Color(0xFF0066FF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Approved Today',
              '12',
              Icons.verified,
              const Color(0xFF00C853),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
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
                    fontSize: 12,
                    color: const Color(0xFF1A1A1A).withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'User & Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Method',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: _withdrawalRequests.length,
              itemBuilder: (context, index) {
                return _buildWithdrawalRow(_withdrawalRequests[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalRow(WithdrawalRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
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
                  request.userName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${request.id}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: const Color(0xFF1A1A1A).withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.accountNumber,
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
            child: Text(
              '\$${request.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                request.method,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0066FF),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Text(
              DateFormat('MMM dd, yyyy').format(request.requestDate),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: const Color(0xFF1A1A1A).withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Approve Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => _approveWithdrawal(request),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Reject Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => _rejectWithdrawal(request),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                // View Details
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _viewDetails(request),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.visibility,
                      color: const Color(0xFF1A1A1A),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalAmount() {
    double total = 0;
    for (var request in _withdrawalRequests) {
      total += request.amount;
    }
    return total.toStringAsFixed(2);
  }

  void _approveWithdrawal(WithdrawalRequest request) {
    // Implement approval logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Approve Withdrawal',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: const Color(0xFF1A1A1A),
          ),
        ),
        content: Text(
          'Are you sure you want to approve this withdrawal request of \$${request.amount.toStringAsFixed(2)}?',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: const Color(0xFF1A1A1A).withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle approval
              Navigator.pop(context);
              _showSuccessMessage('Withdrawal approved successfully!');
            },
            child: Text(
              'Approve',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: const Color(0xFF00C853),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rejectWithdrawal(WithdrawalRequest request) {
    // Implement rejection logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reject Withdrawal',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: const Color(0xFF1A1A1A),
          ),
        ),
        content: Text(
          'Are you sure you want to reject this withdrawal request?',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: const Color(0xFF1A1A1A).withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle rejection
              Navigator.pop(context);
              _showSuccessMessage('Withdrawal rejected!');
            },
            child: Text(
              'Reject',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewDetails(WithdrawalRequest request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Withdrawal Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Request ID', request.id),
            _buildDetailRow('User Name', request.userName),
            _buildDetailRow('User ID', request.userId),
            _buildDetailRow('Amount', '\$${request.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Payment Method', request.method),
            _buildDetailRow('Account', request.accountNumber),
            _buildDetailRow('Request Date',
                DateFormat('MMM dd, yyyy - HH:mm').format(request.requestDate)),
            _buildDetailRow('Status', request.status),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A).withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00C853),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class WithdrawalRequest {
  final String id;
  final String userName;
  final double amount;
  final String method;
  final String accountNumber;
  final DateTime requestDate;
  final String status;
  final String userId;

  WithdrawalRequest({
    required this.id,
    required this.userName,
    required this.amount,
    required this.method,
    required this.accountNumber,
    required this.requestDate,
    required this.status,
    required this.userId,
  });
}