import 'package:flutter/material.dart';

class FreelancerProfileSetupPage extends StatefulWidget {
  const FreelancerProfileSetupPage({super.key});

  @override
  State<FreelancerProfileSetupPage> createState() =>
      _FreelancerProfileSetupPageState();
}

class _FreelancerProfileSetupPageState
    extends State<FreelancerProfileSetupPage> {
  final Color _primaryColor = const Color(0xFF66B2FF);
  final Color _secondaryColor = const Color(0xFF00C853);
  final Color _accentColor = const Color(0xFF4CAF50);
  final Color _darkColor = const Color(0xFF2E7D32);
  final Color _lightColor = const Color(0xFFE8F5E9);
  final Color _successGreen = const Color(0xFF2ECC71);

  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _portfolioTitleController = TextEditingController();
  final TextEditingController _portfolioDescController = TextEditingController();
  final TextEditingController _portfolioLinkController = TextEditingController();

  List<String> _skills = [];
  List<Map<String, String>> _portfolioItems = [];
  String _selectedExperience = 'Entry Level';
  String _selectedCategory = 'Web Development';

  final List<String> _experienceLevels = [
    'Entry Level',
    'Intermediate',
    'Expert',
  ];

  final List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'UI/UX Design',
    'Graphic Design',
    'Content Writing',
    'Digital Marketing',
    'Data Science',
    'Video Editing',
  ];

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
      _skillInputController.clear();
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  void _addPortfolioItem() {
    if (_portfolioTitleController.text.trim().isNotEmpty) {
      setState(() {
        _portfolioItems.add({
          'title': _portfolioTitleController.text.trim(),
          'desc': _portfolioDescController.text.trim(),
          'link': _portfolioLinkController.text.trim(),
        });
        _portfolioTitleController.clear();
        _portfolioDescController.clear();
        _portfolioLinkController.clear();
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          _buildHeader(),
          // Step Indicator
          _buildStepIndicator(),
          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoPage(),
                _buildSkillsPage(),
                _buildPortfolioPage(),
              ],
            ),
          ),
          // Bottom Navigation
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_successGreen, _primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Setup Your Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "Stand out and attract the best clients",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final List<String> stepLabels = ['Basic Info', 'Skills', 'Portfolio'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: isDone || isActive
                              ? LinearGradient(
                              colors: [_successGreen, _primaryColor])
                              : null,
                          color: isDone || isActive
                              ? null
                              : Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stepLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? _primaryColor
                              : isDone
                              ? _successGreen
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _totalSteps - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── STEP 1: Basic Info ───────────────────────────────────────────────────
  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar picker
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_successGreen, _primaryColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 50),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _lightColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt,
                        color: _primaryColor, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionLabel("Full Name"),
          _buildTextField(
            controller: _nameController,
            hint: "e.g. John Doe",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          _buildSectionLabel("Professional Title"),
          _buildTextField(
            controller: _titleController,
            hint: "e.g. Full Stack Developer",
            icon: Icons.work_outline,
          ),
          const SizedBox(height: 16),

          _buildSectionLabel("Category"),
          _buildDropdown(
            value: _selectedCategory,
            items: _categories,
            icon: Icons.category_outlined,
            onChanged: (val) => setState(() => _selectedCategory = val!),
          ),
          const SizedBox(height: 16),

          _buildSectionLabel("Experience Level"),
          Row(
            children: _experienceLevels.map((level) {
              final isSelected = _selectedExperience == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedExperience = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                          colors: [_successGreen, _primaryColor])
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade200,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Text(
                      level,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          _buildSectionLabel("Hourly Rate (\$)"),
          _buildTextField(
            controller: _hourlyRateController,
            hint: "e.g. 25",
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          _buildSectionLabel("Bio"),
          _buildTextField(
            controller: _bioController,
            hint:
            "Write a short bio about yourself, your expertise, and what makes you unique...",
            icon: Icons.notes_outlined,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── STEP 2: Skills ────────────────────────────────────────────────────────
  Widget _buildSkillsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _successGreen.withOpacity(0.1),
                  _primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: _primaryColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Add skills that best represent your expertise. Clients search by skills.",
                    style: TextStyle(
                      color: _darkColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionLabel("Add Skills"),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillInputController,
                  decoration: InputDecoration(
                    hintText: "e.g. Flutter, Figma, Python...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon:
                    Icon(Icons.code, color: _primaryColor, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      BorderSide(color: _primaryColor, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _addSkill,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_successGreen, _primaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_skills.isNotEmpty) ...[
            _buildSectionLabel("Your Skills (${_skills.length})"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills
                  .map(
                    (skill) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Chip(
                    label: Text(
                      skill,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    backgroundColor: Colors.transparent,
                    deleteIcon: const Icon(Icons.close,
                        size: 16, color: Colors.white70),
                    onDeleted: () => _removeSkill(skill),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    avatar: null,
                    // gradient via Container trick
                    visualDensity: VisualDensity.compact,
                    color: WidgetStateProperty.all(
                        _primaryColor), // fallback
                  ),
                ),
              )
                  .toList(),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.psychology_outlined,
                        size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      "No skills added yet",
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          _buildSectionLabel("Suggested Skills"),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter',
              'React',
              'Node.js',
              'Python',
              'Figma',
              'WordPress',
              'Photoshop',
              'SQL',
              'AWS',
              'Firebase',
            ]
                .where((s) => !_skills.contains(s))
                .map(
                  (suggestion) => GestureDetector(
                onTap: () =>
                    setState(() => _skills.add(suggestion)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _lightColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _accentColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: _darkColor),
                      const SizedBox(width: 4),
                      Text(
                        suggestion,
                        style: TextStyle(
                          color: _darkColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── STEP 3: Portfolio ─────────────────────────────────────────────────────
  Widget _buildPortfolioPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add portfolio form
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_successGreen, _primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_box_outlined,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Add Portfolio Item",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _darkColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionLabel("Project Title"),
                _buildTextField(
                  controller: _portfolioTitleController,
                  hint: "e.g. E-commerce App",
                  icon: Icons.title,
                ),
                const SizedBox(height: 12),
                _buildSectionLabel("Description"),
                _buildTextField(
                  controller: _portfolioDescController,
                  hint: "Brief description of what you built...",
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _buildSectionLabel("Project Link (optional)"),
                _buildTextField(
                  controller: _portfolioLinkController,
                  hint: "https://github.com/yourproject",
                  icon: Icons.link,
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: _addPortfolioItem,
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_successGreen, _primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Add Project",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_portfolioItems.isNotEmpty) ...[
            _buildSectionLabel("Added Projects (${_portfolioItems.length})"),
            const SizedBox(height: 12),
            ..._portfolioItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _primaryColor.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _successGreen.withOpacity(0.2),
                            _primaryColor.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "${i + 1}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (item['desc']!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              item['desc']!,
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (item['link']!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.link,
                                    size: 13,
                                    color: _primaryColor),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item['link']!,
                                    style: TextStyle(
                                      color: _primaryColor,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.red.shade300, size: 20),
                      onPressed: () =>
                          setState(() => _portfolioItems.removeAt(i)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Icon(Icons.work_outline,
                        size: 55, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text(
                      "No projects added yet",
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: _prevStep,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _lightColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _accentColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_ios,
                            size: 14, color: _darkColor),
                        const SizedBox(width: 4),
                        Text(
                          "Back",
                          style: TextStyle(
                            color: _darkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isLast
                    ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          "Profile saved successfully!"),
                      backgroundColor: _successGreen,
                    ),
                  );
                }
                    : _nextStep,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_successGreen, _primaryColor],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? "Save Profile" : "Continue",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isLast
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Reusable Widgets ──────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: _primaryColor, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: _primaryColor),
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Row(
              children: [
                Icon(icon, color: _primaryColor, size: 18),
                const SizedBox(width: 10),
                Text(item, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}