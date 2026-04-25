import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:workconnect1/search_result_page.dart';
import 'package:workconnect1/user_services.dart';
import 'manage_proposal.dart';

void main() {
  runApp(const JobSearchApp());
}

class JobSearchApp extends StatelessWidget {
  const JobSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkConnect - Job Search',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Roboto",
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ECC71),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      ),
      home: const JobSearchPage(userId: ''),
    );
  }
}

class JobSearchPage extends StatefulWidget {
  const JobSearchPage({super.key, required userId});

  @override
  State<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends State<JobSearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minSalaryController = TextEditingController();
  final TextEditingController maxSalaryController = TextEditingController();

  static const Color _successGreen = Color(0xFF2ECC71);
  static const Color _primaryColor = Color(0xFF66B2FF);
  static const Color _midBlue = Color(0xFF1A8FE3);
  static const Color _secondaryColor = Color(0xFF00C853);
  static const Color _accentColor = Color(0xFF4CAF50);
  static const Color _darkColor = Color(0xFF2E7D32);
  static const Color _lightColor = Color(0xFFE8F5E9);
  static const Color _bg = Color(0xFFF0F4FF);
  static const Color _darkText = Color(0xFF111827);
  static const Color _mutedText = Color(0xFF6B7280);

  static const _heroGradient = LinearGradient(
    colors: [_successGreen, _midBlue, _primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  String selectedCategory = "All";
  bool remoteOnly = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> categories = [
    {"label": "All", "icon": Icons.apps_rounded},
    {"label": "Full-time", "icon": Icons.work_rounded},
    {"label": "Part-time", "icon": Icons.timelapse_rounded},
    {"label": "Remote", "icon": Icons.wifi_rounded},
    {"label": "On-site", "icon": Icons.location_on_rounded},
  ];

  static const String BASE_URL = "http://10.247.43.79:3000";
  late final ApiService _apiService = ApiService(baseUrl: BASE_URL);
  late final ProposalGenerator _proposalGenerator = ProposalGenerator();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    searchController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    super.dispose();
  }

  void resetFilters() {
    setState(() {
      searchController.clear();
      minSalaryController.clear();
      maxSalaryController.clear();
      selectedCategory = "All";
      remoteOnly = false;
    });
  }

  void searchJobs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          query: searchController.text.trim(),
          category: selectedCategory,
          minSalary: minSalaryController.text.trim(),
          maxSalary: maxSalaryController.text.trim(),
          remoteOnly: remoteOnly,
          apiService: _apiService,
        ),
      ),
    );
  }

  Future<void> openAutoProposalSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AutoProposalSheet(proposalGenerator: _proposalGenerator),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(Icons.work_outline_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "WorkConnect",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              final userId = await UserService.getUserId();
              if (userId == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please login first"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              }
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageProposalsPage(
                      userId: userId,
                      apiService: _apiService,
                      userType: 'freelancer',
                    ),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.description_outlined,
                      color: Colors.white, size: 13),
                  SizedBox(width: 5),
                  Text(
                    "Proposals",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsRow(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 12),
                child: _SectionHeader(
                    icon: Icons.category_rounded, label: "Job Type"),
              ),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 12),
                child: _SectionHeader(
                    icon: Icons.attach_money_rounded,
                    label: "Salary Range (USD)"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSalaryCard(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildRemoteToggle(),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildActionButtons(),
              ),
              const SizedBox(height: 32),
              _buildAiSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── HERO BANNER ──────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 90, 22, 20),
      decoration: BoxDecoration(
        gradient: _heroGradient,
        borderRadius:
        const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: _successGreen.withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: -4,
            offset: const Offset(-8, 12),
          ),
          BoxShadow(
            color: _primaryColor.withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: -4,
            offset: const Offset(8, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.09),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 10,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _successGreen.withOpacity(0.18),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: text LEFT + card RIGHT, vertically centered ──
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: badge + title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _successGreen.withOpacity(0.6),
                                  width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _successGreen,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        _successGreen.withOpacity(0.8),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "10,000+ Active Listings",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Title
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                                  colors: [Colors.white, Color(0xFFB9F5D8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                            child: const Text(
                              "Find Your\nDream Career",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.15,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    color: Color(0x44000000),
                                    offset: Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Subtitle
                          Text(
                            "Thousands of opportunities —\napply in seconds with AI.",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.82),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right: Instant Apply card — centered vertically
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4)),
                            ),
                            child: const Icon(Icons.rocket_launch_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Instant\nApply",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: _successGreen.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _successGreen.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _successGreen,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _successGreen.withOpacity(0.8),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "AI",
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Bottom stat pills ──
              Row(
                children: [
                  _HeroStatPill(
                      icon: Icons.business_center_rounded,
                      label: "12K Jobs",
                      color: _successGreen),
                  const SizedBox(width: 8),
                  _HeroStatPill(
                      icon: Icons.people_alt_rounded,
                      label: "5K+ Companies",
                      color: _primaryColor),
                  const SizedBox(width: 8),
                  _HeroStatPill(
                      icon: Icons.wifi_rounded,
                      label: "Remote Friendly",
                      color: Colors.white),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _midBlue.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Job title, skill, company…",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_successGreen, _midBlue]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search_rounded,
                color: Colors.white, size: 17),
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.cancel_rounded,
                color: Colors.grey.shade400, size: 20),
            onPressed: () => setState(() => searchController.clear()),
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatChip(
            icon: Icons.business_center_rounded,
            label: "12K+ Jobs",
            color: _successGreen),
        const SizedBox(width: 10),
        _StatChip(
            icon: Icons.people_alt_rounded,
            label: "5K+ Companies",
            color: _midBlue),
        const SizedBox(width: 10),
        _StatChip(
            icon: Icons.flash_on_rounded,
            label: "Instant Apply",
            color: const Color(0xFFF59E0B)),
      ],
    );
  }

  // ── Category Chips ─────────────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final label = cat["label"] as String;
          final icon = cat["icon"] as IconData;
          final sel = selectedCategory == label;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                gradient: sel ? _heroGradient : null,
                color: sel ? null : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? Colors.transparent : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: sel
                    ? [
                  BoxShadow(
                    color: _midBlue.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 14,
                      color: sel ? Colors.white : Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.grey.shade700,
                      fontWeight:
                      sel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Salary Card ────────────────────────────────────────────────────────────
  Widget _buildSalaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SalaryField(
              controller: minSalaryController,
              label: "Minimum",
              hint: "0",
              icon: Icons.south_rounded,
              iconColor: _successGreen,
              bgColor: _lightColor,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Expanded(
            child: _SalaryField(
              controller: maxSalaryController,
              label: "Maximum",
              hint: "999,999",
              icon: Icons.north_rounded,
              iconColor: _midBlue,
              bgColor: const Color(0xFFE8F4FF),
            ),
          ),
        ],
      ),
    );
  }

  // ── Remote Toggle ──────────────────────────────────────────────────────────
  Widget _buildRemoteToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: remoteOnly ? _lightColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: remoteOnly
              ? _successGreen.withOpacity(0.4)
              : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: remoteOnly ? _successGreen : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.home_work_rounded,
              color: remoteOnly ? Colors.white : Colors.grey.shade500,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Remote Only",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: remoteOnly ? _darkColor : _darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Filter positions to remote work only",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: remoteOnly ? _accentColor : _mutedText,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: remoteOnly,
            onChanged: (v) => setState(() => remoteOnly = v),
            activeColor: _successGreen,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: resetFilters,
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text("Reset Filters",
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _mutedText,
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _heroGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _midBlue.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: searchJobs,
                icon: const Icon(Icons.search_rounded, size: 17),
                label: const Text("Search Jobs",
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── AI Section ─────────────────────────────────────────────────────────────
  Widget _buildAiSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                  child:
                  Divider(color: Colors.grey.shade200, thickness: 1.5)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    "AI Tools",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              Expanded(
                  child:
                  Divider(color: Colors.grey.shade200, thickness: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: _heroGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _successGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(-4, 8),
                ),
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(4, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35)),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 26),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check,
                            color: _successGreen, size: 9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Proposal Writer",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Craft winning proposals in seconds",
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _AiBadge(label: "Free"),
                          const SizedBox(width: 6),
                          _AiBadge(label: "Instant"),
                          const SizedBox(width: 6),
                          _AiBadge(label: "Smart"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: openAutoProposalSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.45)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Try Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero Stat Pill ────────────────────────────────────────────────────────────
class _HeroStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _HeroStatPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  static const Color _midBlue = Color(0xFF1A8FE3);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _midBlue),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  final String label;
  const _AiBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9.5,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SalaryField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _SalaryField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 11, color: iconColor),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            prefixText: "\$ ",
            prefixStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 15),
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROPOSAL GENERATOR (logic unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class ProposalGenerator {
  String generateProposal(
      String jobDescription, {
        String? skills,
        String? experience,
        String? name,
      }) {
    final keywords = _extractKeywords(jobDescription);
    final hasFlutter =
        keywords.contains('flutter') || keywords.contains('dart');
    final hasReact =
        keywords.contains('react') || keywords.contains('javascript');
    final hasBackend = keywords.contains('backend') ||
        keywords.contains('api') ||
        keywords.contains('database');
    final hasFullStack =
        keywords.contains('full-stack') || keywords.contains('fullstack');
    final hasRemote = keywords.contains('remote');

    String proposal = "";

    if (name != null && name.isNotEmpty) {
      proposal += "Dear Hiring Manager,\n\n";
      proposal +=
      "My name is $name, and I am writing to express my strong interest in this opportunity. ";
    } else {
      proposal += "Dear Hiring Manager,\n\n";
      proposal +=
      "I am writing to express my strong interest in this position. ";
    }

    if (hasFlutter) {
      proposal +=
      "I am an experienced Flutter developer with a proven track record of building high-quality mobile applications. ";
      proposal +=
      "My expertise includes state management, API integration, custom UI design, and cross-platform development. ";
    } else if (hasReact) {
      proposal +=
      "I am a skilled React developer with extensive experience in building modern web applications. ";
      proposal +=
      "My expertise includes component architecture, state management, RESTful API integration, and responsive design. ";
    } else if (hasBackend) {
      proposal +=
      "I am an experienced backend developer with strong skills in API development, database design, and server-side programming. ";
      proposal +=
      "My expertise includes building scalable systems, optimizing performance, and ensuring data security. ";
    } else if (hasFullStack) {
      proposal +=
      "I am a full-stack developer with comprehensive experience in both frontend and backend technologies. ";
      proposal +=
      "My expertise spans across the entire development lifecycle, from database design to user interface implementation. ";
    } else {
      proposal +=
      "I am a dedicated professional with strong technical skills and a passion for delivering high-quality solutions. ";
      proposal +=
      "My experience includes working on diverse projects that have honed my problem-solving abilities. ";
    }

    if (skills != null && skills.isNotEmpty) {
      proposal += "Additionally, my skillset includes: $skills. ";
    }

    proposal += "\n\n";
    proposal +=
    "What sets me apart is my commitment to understanding project requirements thoroughly and delivering solutions that exceed expectations. ";

    if (hasRemote) {
      proposal +=
      "I have extensive experience working remotely and am proficient in asynchronous communication and collaborative tools. ";
    }

    if (experience != null && experience.isNotEmpty) {
      proposal += "With $experience of hands-on experience, ";
    } else {
      proposal += "With my hands-on experience, ";
    }

    proposal +=
    "I ensure clean, maintainable code following industry best practices. ";
    proposal +=
    "I am comfortable working in agile environments and adapt quickly to new technologies and frameworks.";
    proposal += "\n\n";

    proposal +=
    "I am confident that my technical skills, work ethic, and dedication to quality make me an excellent fit for this project. ";
    proposal +=
    "I would welcome the opportunity to discuss how I can contribute to your team's success. ";
    proposal +=
    "Thank you for considering my application. I look forward to the possibility of working together.\n\n";
    proposal += "Best regards";

    return proposal;
  }

  List<String> _extractKeywords(String text) {
    final lowerText = text.toLowerCase();
    final keywords = <String>[];
    final techKeywords = [
      'flutter', 'dart', 'react', 'javascript', 'python', 'java',
      'backend', 'frontend', 'full-stack', 'fullstack', 'api',
      'database', 'mobile', 'web', 'android', 'ios', 'remote',
      'node', 'express'
    ];
    for (var keyword in techKeywords) {
      if (lowerText.contains(keyword)) keywords.add(keyword);
    }
    return keywords;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTO PROPOSAL BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class AutoProposalSheet extends StatefulWidget {
  final ProposalGenerator proposalGenerator;
  const AutoProposalSheet({super.key, required this.proposalGenerator});

  @override
  State<AutoProposalSheet> createState() => _AutoProposalSheetState();
}

class _AutoProposalSheetState extends State<AutoProposalSheet> {
  final TextEditingController jobDescController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  static const Color _successGreen = Color(0xFF2ECC71);
  static const Color _primaryColor = Color(0xFF66B2FF);
  static const Color _midBlue = Color(0xFF1A8FE3);

  static const _heroGradient = LinearGradient(
    colors: [_successGreen, _midBlue, _primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  String result = '';
  bool loading = false;

  Future<void> generate() async {
    if (jobDescController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter job description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      loading = true;
      result = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final proposal = widget.proposalGenerator.generateProposal(
        jobDescController.text,
        skills: skillsController.text.trim().isNotEmpty
            ? skillsController.text.trim()
            : null,
        experience: experienceController.text.trim().isNotEmpty
            ? experienceController.text.trim()
            : null,
        name: nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : null,
      );
      setState(() {
        result = proposal;
        loading = false;
      });
    } catch (e) {
      setState(() {
        result = "";
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F4FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  gradient: _heroGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _heroGradient,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: _successGreen.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(-3, 6)),
                  BoxShadow(
                      color: _primaryColor.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(3, 6)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(14),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.35)),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AI Proposal Writer",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        SizedBox(height: 3),
                        Text("Craft a winning proposal in seconds",
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _FieldLabel(label: "Job Description", required: true),
            const SizedBox(height: 8),
            _FormCard(
                child: TextField(
                    controller: jobDescController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    decoration: InputDecoration(
                        hintText: "Paste the job description here…",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero))),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(label: "Your Name"),
                          const SizedBox(height: 8),
                          _FormCard(
                              child: TextField(
                                  controller: nameController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      hintText: "Ali Ahmed",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13),
                                      prefixIcon: Icon(
                                          Icons.person_outline_rounded,
                                          size: 17,
                                          color: Colors.grey.shade400),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 14)))),
                        ])),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(label: "Experience"),
                          const SizedBox(height: 8),
                          _FormCard(
                              child: TextField(
                                  controller: experienceController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      hintText: "3 years",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13),
                                      prefixIcon: Icon(
                                          Icons.work_history_outlined,
                                          size: 17,
                                          color: Colors.grey.shade400),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 14)))),
                        ])),
              ],
            ),
            const SizedBox(height: 16),
            _FieldLabel(label: "Your Skills"),
            const SizedBox(height: 8),
            _FormCard(
                child: TextField(
                    controller: skillsController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        hintText: "Flutter, Firebase, REST APIs, Git…",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.code_rounded,
                            size: 17, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 14)))),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: _heroGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: _midBlue.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5))
                    ]),
                child: ElevatedButton.icon(
                  onPressed: loading ? null : generate,
                  icon: loading
                      ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_fix_high_rounded, size: 19),
                  label: Text(
                      loading
                          ? "Crafting Proposal…"
                          : "Generate Proposal",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Generated Proposal",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827))),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Copied to clipboard!"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2)));
                    },
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: const Text("Copy",
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        foregroundColor: _midBlue,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: const Color(0xFF2ECC71).withOpacity(0.2),
                        width: 1.5)),
                child: SelectableText(result,
                    style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.7,
                        color: Color(0xFF1B5E20))),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
                letterSpacing: 0.2)),
        if (required)
          const Text(" *",
              style: TextStyle(
                  color: Color(0xFF2ECC71),
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ]),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API SERVICE — unchanged
// ─────────────────────────────────────────────────────────────────────────────

class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> searchJobs(
      {String? query,
        String? category,
        String? minSalary,
        String? maxSalary,
        bool? remote}) async {
    try {
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['query'] = query;
      if (category != null && category != 'All')
        queryParams['category'] = category;
      if (minSalary != null && minSalary.isNotEmpty)
        queryParams['minSalary'] = minSalary;
      if (maxSalary != null && maxSalary.isNotEmpty)
        queryParams['maxSalary'] = maxSalary;
      if (remote == true) queryParams['remote'] = 'true';
      final uri = Uri.parse('$baseUrl/jobs/search')
          .replace(queryParameters: queryParams);
      final response =
      await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to search jobs: ${response.body}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getJobDetails(String jobId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/jobs/$jobId'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to fetch job details');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> submitProposal(
      {required String jobId,
        required String freelancerId,
        required String coverLetter,
        required double proposedAmount,
        required String estimatedDuration}) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/proposals/submit'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'jobId': jobId,
            'freelancerId': freelancerId,
            'coverLetter': coverLetter,
            'proposedAmount': proposedAmount,
            'estimatedDuration': estimatedDuration
          }))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) return jsonDecode(response.body);
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to submit proposal');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getMyProposals(String freelancerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/proposals/freelancer/$freelancerId'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to fetch proposals');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getProposalsForMyJobs(
      String clientId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/proposals/client/$clientId'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to fetch proposals');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProposalStatus(
      String proposalId, String status) async {
    try {
      final response = await http
          .put(Uri.parse('$baseUrl/proposals/$proposalId/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'status': status}))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update proposal');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> withdrawProposal(String proposalId) async {
    try {
      final response = await http
          .put(Uri.parse('$baseUrl/proposals/$proposalId/withdraw'),
          headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to withdraw proposal');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

class HomePageWithProposalButton extends StatelessWidget {
  final String userId;
  final String userType;
  final ApiService apiService;

  const HomePageWithProposalButton(
      {super.key,
        required this.userId,
        required this.userType,
        required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(child: Text('WorkConnect'))),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ManageProposalsPage(
                        userId: userId,
                        userType: userType,
                        apiService: apiService)));
          },
          icon: const Icon(Icons.description),
          label: Text(userType == 'freelancer'
              ? 'My Proposals'
              : 'Received Proposals'),
        ),
      ),
    );
  }
}