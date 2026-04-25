import 'package:flutter/material.dart';
import 'job_detail_page.dart';
import 'job_serachpage.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  final String category;
  final String minSalary;
  final String maxSalary;
  final bool remoteOnly;
  final ApiService apiService;

  const SearchResultsPage({
    super.key,
    required this.query,
    required this.category,
    required this.minSalary,
    required this.maxSalary,
    required this.remoteOnly,
    required this.apiService,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final Color _successGreen = const Color(0xFF10B981);
  final Color _primaryColor = const Color(0xFF6366F1);

  List<dynamic> jobs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    searchJobs();
  }

  Future<void> searchJobs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await widget.apiService.searchJobs(
        query: widget.query.isEmpty ? null : widget.query,
        category: widget.category,
        minSalary: widget.minSalary.isEmpty ? null : widget.minSalary,
        maxSalary: widget.maxSalary.isEmpty ? null : widget.maxSalary,
        remote: widget.remoteOnly,
      );

      setState(() {
        jobs = response['jobs'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        titleSpacing: 0,
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
        foregroundColor: Colors.white,
        title: const Text(
          "Search Results",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: searchJobs,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Search Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_successGreen.withOpacity(0.1), _primaryColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primaryColor.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.search_rounded, color: _primaryColor, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.query.isEmpty ? "All Jobs" : 'Results for: "${widget.query}"',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                    if (!isLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_successGreen, _primaryColor],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${jobs.length} Jobs",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (widget.category != 'All') _filterChip("📁 ${widget.category}"),
                    if (widget.minSalary.isNotEmpty) _filterChip("💵 Min: \$${widget.minSalary}"),
                    if (widget.maxSalary.isNotEmpty) _filterChip("💰 Max: \$${widget.maxSalary}"),
                    if (widget.remoteOnly) _filterChip("🏠 Remote"),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Results List
          Expanded(
            child: isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: _primaryColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Searching for jobs...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
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
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Oops! Something went wrong",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
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
                        onPressed: searchJobs,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Try Again"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : jobs.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 100,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No jobs found",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Try adjusting your filters or search query",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: searchJobs,
              color: _primaryColor,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return _buildJobCard(context, job);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_successGreen, _primaryColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Filters"),
                content: const Text("Advanced filters coming soon..."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.tune),
          label: const Text("Filters"),
        ),
      ),
    );
  }

  Widget _filterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final title = job['title'] ?? 'Unknown Position';
    final company = job['company'] ?? 'Unknown Company';
    final location = job['location'] ?? 'Unknown Location';
    final minSalary = job['minSalary']?.toString() ?? '0';
    final maxSalary = job['maxSalary']?.toString() ?? '0';
    final salary = "\$$minSalary - \$$maxSalary";
    final remote = job['remote'] ?? false;
    final category = job['category'] ?? 'Full-time';
    final applicants = job['applicantsCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailsPage(
                  jobId: job['_id'],
                  apiService: widget.apiService,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_successGreen, _primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.work_outline, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _jobDetailChip(Icons.attach_money, salary, _successGreen),
                    _jobDetailChip(Icons.location_on_outlined, location, Colors.blue),
                    _jobDetailChip(Icons.category_outlined, category, Colors.orange),
                    if (remote)
                      _jobDetailChip(Icons.home_work_outlined, "Remote", Colors.purple),
                  ],
                ),
                if (applicants > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        "$applicants applicant${applicants > 1 ? 's' : ''}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _jobDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}