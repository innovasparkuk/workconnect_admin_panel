import 'package:flutter/material.dart';
import 'job_serachpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;
  final ApiService apiService;

  const JobDetailsPage({
    super.key,
    required this.jobId,
    required this.apiService,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final Color _successGreen = const Color(0xFF10B981);
  final Color _primaryColor = const Color(0xFF6366F1);

  Map<String, dynamic>? job;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadJobDetails();
  }

  Future<void> loadJobDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await widget.apiService.getJobDetails(widget.jobId);
      setState(() {
        job = response['job'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void showProposalSheet() async {
    if (job == null) return;
    final prefs = await SharedPreferences.getInstance();
    final freelancerId = prefs.getString('userId') ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProposalSubmissionSheet(
        job: job!,
        apiService: widget.apiService,
        freelancerId: freelancerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          job?['title'] ?? 'Job Details',
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
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Share feature coming soon...")),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: _primaryColor,
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
                "Failed to load job details",
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
                  onPressed: loadJobDetails,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
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
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_successGreen.withOpacity(0.1), _primaryColor.withOpacity(0.1)],
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_successGreen, _primaryColor],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.work, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job!['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job!['company'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          Icons.attach_money,
                          "Salary",
                          "\$${job!['minSalary']} - \$${job!['maxSalary']}",
                          _successGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoCard(
                          Icons.location_on_outlined,
                          "Location",
                          job!['location'],
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          Icons.category_outlined,
                          "Type",
                          job!['category'],
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoCard(
                          Icons.people_outline,
                          "Applicants",
                          "${job!['applicantsCount'] ?? 0}",
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  if (job!['remote'] == true) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade50, Colors.purple.shade100],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work, color: Colors.purple.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Remote Position",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Description
                  _sectionTitle("Job Description"),
                  const SizedBox(height: 12),
                  Text(
                    job!['description'],
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Skills
                  if (job!['skills'] != null && job!['skills'].isNotEmpty) ...[
                    _sectionTitle("Required Skills"),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (job!['skills'] as List).map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_successGreen.withOpacity(0.1), _primaryColor.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _primaryColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // Requirements
                  if (job!['requirements'] != null &&
                      job!['requirements'].isNotEmpty) ...[
                    _sectionTitle("Requirements"),
                    const SizedBox(height: 12),
                    ...(job!['requirements'] as List).map((req) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_successGreen, _primaryColor],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                req,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 25),
                  ],

                  // Benefits
                  if (job!['benefits'] != null && job!['benefits'].isNotEmpty) ...[
                    _sectionTitle("Benefits"),
                    const SizedBox(height: 12),
                    ...(job!['benefits'] as List).map((benefit) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: _successGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                benefit,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: job == null
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: job!['status'] == 'open'
                  ? LinearGradient(
                colors: [_successGreen, _primaryColor],
              )
                  : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: job!['status'] == 'open'
                  ? [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: ElevatedButton.icon(
              onPressed: job!['status'] == 'open' ? showProposalSheet : null,
              icon: const Icon(Icons.send_rounded),
              label: Text(
                job!['status'] == 'open' ? "Submit Proposal" : "Job Closed",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: job!['status'] == 'open' ? Colors.transparent : Colors.grey.shade400,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// --------------------------
// Proposal Submission Sheet
// --------------------------
class ProposalSubmissionSheet extends StatefulWidget {
  final Map<String, dynamic> job;
  final ApiService apiService;
  final String freelancerId;
  const ProposalSubmissionSheet({
    super.key,
    required this.job,
    required this.apiService,
    required this.freelancerId,
  });

  @override
  State<ProposalSubmissionSheet> createState() => _ProposalSubmissionSheetState();
}

class _ProposalSubmissionSheetState extends State<ProposalSubmissionSheet> {
  final Color _successGreen = const Color(0xFF10B981);
  final Color _primaryColor = const Color(0xFF6366F1);

  final TextEditingController coverLetterController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  bool isSubmitting = false;

  Future<void> submitProposal() async {
    if (coverLetterController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await widget.apiService.submitProposal(
        jobId: widget.job['_id'],
        freelancerId: widget.freelancerId,
        coverLetter: coverLetterController.text.trim(),
        proposedAmount: double.parse(amountController.text.trim()),
        estimatedDuration: durationController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Proposal submitted successfully! ✅"),
            backgroundColor: _successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Submit Proposal",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "For: ${widget.job['title']}",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 25),
            _buildTextField(
              controller: coverLetterController,
              label: "Cover Letter",
              hint: "Explain why you're the best fit for this job...",
              maxLines: 6,
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: amountController,
              label: "Proposed Amount (\$)",
              hint: "Your bid amount",
              keyboardType: TextInputType.number,
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: durationController,
              label: "Estimated Duration",
              hint: "e.g., 2 weeks, 1 month",
              icon: Icons.schedule_outlined,
            ),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_successGreen, _primaryColor],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : submitProposal,
                  icon: isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.send_rounded),
                  label: Text(isSubmitting ? "Submitting..." : "Submit Proposal"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: _primaryColor) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}