import 'package:flutter/material.dart';
import 'job_serachpage.dart';
import 'package:intl/intl.dart';

class ManageProposalsPage extends StatefulWidget {
  final String userId;
  final String userType; // 'freelancer' or 'client'
  final ApiService apiService;

  const ManageProposalsPage({
    super.key,
    required this.userId,
    required this.userType,
    required this.apiService,
  });

  @override
  State<ManageProposalsPage> createState() => _ManageProposalsPageState();
}

class _ManageProposalsPageState extends State<ManageProposalsPage>
    with SingleTickerProviderStateMixin {
  final Color _successGreen = const Color(0xFF10B981);
  final Color _primaryColor = const Color(0xFF6366F1);

  late TabController _tabController;
  List<dynamic> proposals = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedFilter = 'all'; // all, pending, accepted, rejected, withdrawn

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadProposals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadProposals() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = widget.userType == 'freelancer'
          ? await widget.apiService.getMyProposals(widget.userId)
          : await widget.apiService.getProposalsForMyJobs(widget.userId);

      print('📥 Received proposals response: $response');

      setState(() {
        proposals = response['proposals'] ?? [];
        isLoading = false;
      });

      print('✅ Loaded ${proposals.length} proposals');
    } catch (e) {
      print('❌ Error loading proposals: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<dynamic> getFilteredProposals(String status) {
    if (status == 'all') return proposals;
    return proposals.where((p) => p['status'] == status).toList();
  }

  Future<void> updateProposalStatus(String proposalId, String status) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await widget.apiService.updateProposalStatus(proposalId, status);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Proposal ${status == 'accepted' ? 'accepted' : 'rejected'} ✅"),
            backgroundColor: status == 'accepted' ? _successGreen : Colors.orange,
          ),
        );
        loadProposals(); // Reload data
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> withdrawProposal(String proposalId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Withdraw Proposal?"),
        content: const Text("Are you sure you want to withdraw this proposal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await widget.apiService.withdrawProposal(proposalId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Proposal withdrawn ✅"),
            backgroundColor: Colors.orange,
          ),
        );
        loadProposals();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = proposals.where((p) => p['status'] == 'pending').length;
    final acceptedCount = proposals.where((p) => p['status'] == 'accepted').length;
    final rejectedCount = proposals.where((p) => p['status'] == 'rejected').length;
    final withdrawnCount = proposals.where((p) => p['status'] == 'withdrawn').length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          widget.userType == 'freelancer' ? 'Manage  Proposals' : 'Received Proposals',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_successGreen, _primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadProposals,
            tooltip: "Refresh",
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("All"),
                  const SizedBox(height: 2),
                  Text(
                    "${proposals.length}",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pending"),
                  const SizedBox(height: 2),
                  Text(
                    "$pendingCount",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Accepted"),
                  const SizedBox(height: 2),
                  Text(
                    "$acceptedCount",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Other"),
                  const SizedBox(height: 2),
                  Text(
                    "${rejectedCount + withdrawnCount}",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primaryColor),
            const SizedBox(height: 16),
            Text(
              "Loading proposals...",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                "Failed to load proposals",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_successGreen, _primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: loadProposals,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildProposalList(proposals, 'all'),
          _buildProposalList(getFilteredProposals('pending'), 'pending'),
          _buildProposalList(getFilteredProposals('accepted'), 'accepted'),
          _buildProposalList([
            ...getFilteredProposals('rejected'),
            ...getFilteredProposals('withdrawn')
          ], 'other'),
        ],
      ),
    );
  }

  Widget _buildProposalList(List<dynamic> proposalList, String filter) {
    if (proposalList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 100,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                filter == 'all'
                    ? "No proposals yet"
                    : "No ${filter == 'other' ? 'rejected/withdrawn' : filter} proposals",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.userType == 'freelancer'
                    ? "Start applying to jobs to see your proposals here"
                    : "You'll see proposals from freelancers here",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadProposals,
      color: _primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: proposalList.length,
        itemBuilder: (context, index) {
          final proposal = proposalList[index];
          return _buildProposalCard(proposal);
        },
      ),
    );
  }

  Widget _buildProposalCard(Map<String, dynamic> proposal) {
    final status = proposal['status'] ?? 'pending';

    // FIXED: Handle both populated and non-populated data
    String jobTitle;
    if (proposal['jobId'] is Map) {
      jobTitle = proposal['jobId']['title'] ?? proposal['jobTitle'] ?? 'Unknown Job';
    } else {
      jobTitle = proposal['jobTitle'] ?? 'Unknown Job';
    }

    String freelancerName;
    if (proposal['freelancerId'] is Map) {
      freelancerName = proposal['freelancerId']['name'] ?? proposal['freelancerName'] ?? 'Unknown Freelancer';
    } else {
      freelancerName = proposal['freelancerName'] ?? 'Unknown Freelancer';
    }

    final proposedAmount = proposal['proposedAmount']?.toString() ?? '0';
    final estimatedDuration = proposal['estimatedDuration'] ?? 'Not specified';
    final coverLetter = proposal['coverLetter'] ?? 'No cover letter';
    final submittedDate = proposal['submittedDate'] ?? proposal['createdAt'] ?? '';
    final proposalId = proposal['_id'];

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'accepted':
        statusColor = _successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'withdrawn':
        statusColor = Colors.orange;
        statusIcon = Icons.remove_circle;
        break;
      default:
        statusColor = _primaryColor;
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_successGreen.withOpacity(0.1), _primaryColor.withOpacity(0.1)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_successGreen, _primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.work_outline, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.userType == 'client') ...[
                            const SizedBox(height: 4),
                            Text(
                              "by $freelancerName",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount & Duration
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(
                        Icons.attach_money,
                        "Bid Amount",
                        "\$$proposedAmount",
                        _successGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoRow(
                        Icons.schedule_outlined,
                        "Duration",
                        estimatedDuration,
                        _primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Cover Letter
                Text(
                  "Cover Letter",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    coverLetter,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 12),

                // Submitted Date
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      "Submitted: ${_formatDate(submittedDate)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                // Action Buttons
                if (status == 'pending') ...[
                  const SizedBox(height: 16),
                  if (widget.userType == 'client')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => updateProposalStatus(proposalId, 'rejected'),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text("Reject"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red.shade700,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.red.shade200),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_successGreen, _primaryColor],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => updateProposalStatus(proposalId, 'accepted'),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text("Accept"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => withdrawProposal(proposalId),
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                        label: const Text("Withdraw Proposal"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade700,
                          side: BorderSide(color: Colors.orange.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}