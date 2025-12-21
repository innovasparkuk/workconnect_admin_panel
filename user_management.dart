import 'package:admin/setting.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkConnect Admin',
      theme: ThemeData(
        primaryColor: Color(0xFF0066FF),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF0066FF),
          secondary: Color(0xFF00C853),
          background: Color(0xFFF8FAFC),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        // Fixed CardTheme without shadowColor
        cardTheme: const CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: AdminUserManagement(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr, // Force LTR
          child: child!,
        );
      },
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserType type;
  UserStatus status;
  bool isBlocked;
  final String joinDate;
  final String? phone;
  final double? rating;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.status,
    required this.isBlocked,
    required this.joinDate,
    this.phone,
    this.rating,
    this.profileImage,
  });
}

enum UserType { client, freelancer }
enum UserStatus { verified, pending, rejected }

class AdminUserManagement extends StatefulWidget {
  @override
  _AdminUserManagementState createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  List<User> users = [
    User(
      id: '1',
      name: 'Ahmed Raza',
      email: 'ahmed@gmail.com',
      type: UserType.freelancer,
      status: UserStatus.verified,
      isBlocked: false,
      joinDate: '2024-01-15',
      phone: '+92 300 1234567',
      rating: 4.8,
      profileImage: '👨‍💻',
    ),
    User(
      id: '2',
      name: 'Sarah Khan',
      email: 'sarah@gmail.com',
      type: UserType.client,
      status: UserStatus.pending,
      isBlocked: false,
      joinDate: '2024-02-20',
      phone: '+92 321 9876543',
      profileImage: '👩‍💼',
    ),
    User(
      id: '3',
      name: 'Ali Hassan',
      email: 'ali@gmail.com',
      type: UserType.freelancer,
      status: UserStatus.rejected,
      isBlocked: true,
      joinDate: '2024-01-10',
      phone: '+92 333 4567890',
      rating: 4.2,
      profileImage: '👨‍🎨',
    ),
    User(
      id: '4',
      name: 'Fatima Noor',
      email: 'fatima@gmail.com',
      type: UserType.client,
      status: UserStatus.verified,
      isBlocked: false,
      joinDate: '2024-03-05',
      phone: '+92 345 1122334',
      profileImage: '👩‍💻',
    ),
  ];

  UserType? selectedUserType;
  UserStatus? selectedStatus;
  String searchQuery = '';
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(); // ✅ Add this line
  }

  @override
  void dispose() {
    searchController.dispose(); // ✅ Add this line
    super.dispose();
  }

  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final bool isTablet = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'User Management',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        backgroundColor: Color(0xFF0066FF),
        elevation: 0,
        centerTitle: true,
        // ✅ Settings Icon Added Here
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminSettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000), // Website width kam kiya
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 20, // Horizontal padding optimize kiya
              vertical: isMobile ? 8 : 16,
            ),
            child: Column(
              children: [
                // Header with Stats - NEW COLORS
                _buildHeaderStats(isMobile),
                SizedBox(height: isMobile ? 16 : 24),

                // Filters and Search Section
                _buildFiltersSection(isMobile, isTablet),
                SizedBox(height: isMobile ? 16 : 24),

                // Users List
                Expanded(
                  child: _buildUsersList(isMobile, isTablet),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStats(bool isMobile) {
    final totalUsers = users.length;
    final verifiedUsers = users.where((user) => user.status == UserStatus.verified).length;
    final pendingUsers = users.where((user) => user.status == UserStatus.pending).length;

    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0066FF),
            Color(0xFF0066FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total Users', totalUsers.toString(), Icons.people_alt, isMobile),
          ),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem('Verified', verifiedUsers.toString(), Icons.verified, isMobile),
          ),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem('Pending', pendingUsers.toString(), Icons.pending, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, bool isMobile) {
    // Different colors for different icons
    Color iconColor;
    switch (icon) {
      case Icons.people_alt:
        iconColor = Colors.amber; // Total Users - Amber/Gold
        break;
      case Icons.verified:
        iconColor = Color(0xFF00C853); // Verified - Green
        break;
      case Icons.pending:
        iconColor = Colors.orange; // Pending - Orange
        break;
      default:
        iconColor = Colors.white;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor, // Different colors for each icon
            size: isMobile ? 14 : 18,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isMobile ? 10 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Professional Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    textDirection: TextDirection.ltr, // ✅ LTR force karein
                    textAlign: TextAlign.left, // ✅ Left align karein
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      hintTextDirection: TextDirection.ltr, // ✅ Hint bhi LTR
                      prefixIcon: Container(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.search, color: Color(0xFF0066FF), size: 22),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey, size: 20),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            searchController.clear();
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Professional Filters Row - BOTH FILTERS INCLUDED
          if (isMobile) ...[
            // Mobile Layout
            Column(
              children: [
                _buildUserTypeFilter(isMobile), // ✅ User Type Filter
                SizedBox(height: 12),
                _buildStatusFilter(isMobile),   // ✅ Status Filter
              ],
            ),
          ] else ...[
            // Desktop Layout
            Row(
              children: [
                Expanded(
                  child: _buildUserTypeFilter(isMobile), // ✅ User Type Filter
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatusFilter(isMobile),   // ✅ Status Filter
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserTypeFilter(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<UserType>(
        value: selectedUserType,
        decoration: InputDecoration(
          labelText: 'User Type',
          prefixIcon: Icon(Icons.group, color: Color(0xFF0066FF), size: 20),
          floatingLabelStyle: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.w600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        dropdownColor: Colors.white,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text('All Types', style: TextStyle(color: Colors.black)),
          ),
          DropdownMenuItem(
            value: UserType.client,
            child: Row(
              children: [
                Icon(Icons.business_center, size: 18, color: Colors.blue.shade600),
                SizedBox(width: 8),
                Text('Clients', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: UserType.freelancer,
            child: Row(
              children: [
                Icon(Icons.work, size: 18, color: Colors.green.shade600),
                SizedBox(width: 8),
                Text('Freelancers', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedUserType = value;
          });
        },
      ),
    );
  }

  Widget _buildStatusFilter(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<UserStatus>(
        value: selectedStatus,
        decoration: InputDecoration(
          labelText: 'Status',
          prefixIcon: Icon(Icons.verified_user, color: Color(0xFF0066FF), size: 20),
          floatingLabelStyle: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.w600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        dropdownColor: Colors.white,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text('All Status', style: TextStyle(color: Colors.black)),
          ),
          DropdownMenuItem(
            value: UserStatus.verified,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10),
                Text('Verified', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: UserStatus.pending,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10),
                Text('Pending', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: UserStatus.rejected,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10),
                Text('Rejected', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedStatus = value;
          });
        },
      ),
    );
  }

  Widget _buildUsersList(bool isMobile, bool isTablet) {
    List<User> filteredUsers = users.where((user) {
      bool matchesSearch = user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesType = selectedUserType == null || user.type == selectedUserType;
      bool matchesStatus = selectedStatus == null || user.status == selectedStatus;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 1.1,
      ),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user, isMobile);
      },
    );
  }

  Widget _buildUserCard(User user, bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar and Status
              Row(
                children: [
                  Container(
                    width: isMobile ? 50 : 60,
                    height: isMobile ? 50 : 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0066FF), Color(0xFF0051CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        user.profileImage ?? '👤',
                        style: TextStyle(fontSize: isMobile ? 20 : 24),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isMobile ? 12 : 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusIndicator(user.status),
                ],
              ),
              SizedBox(height: 16),

              // User Details
              _buildDetailItem(Icons.phone, user.phone ?? 'Not provided', isMobile),
              SizedBox(height: 8),
              _buildDetailItem(Icons.calendar_today, 'Joined ${user.joinDate}', isMobile),
              if (user.rating != null) ...[
                SizedBox(height: 8),
                _buildDetailItem(Icons.star, 'Rating: ${user.rating}/5', isMobile),
              ],
              SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(user, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, bool isMobile) {
    return Row(
      children: [
        Icon(icon, size: isMobile ? 14 : 16, color: Colors.grey.shade500),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: isMobile ? 12 : 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(UserStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case UserStatus.verified:
        color = Color(0xFF00C853);
        icon = Icons.verified;
        break;
      case UserStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case UserStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            status.toString().split('.').last,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(User user, bool isMobile) {
    return Row(
      children: [
        // Verify/Accept Button
        if (user.status == UserStatus.pending || user.status == UserStatus.rejected)
          Expanded(
            child: ElevatedButton(
              onPressed: () => _verifyUser(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00C853),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 16),
                  SizedBox(width: 4),
                  Text(
                    user.status == UserStatus.rejected ? 'Accept' : 'Verify',
                    style: TextStyle(fontSize: isMobile ? 12 : 13),
                  ),
                ],
              ),
            ),
          ),

        if (user.status == UserStatus.pending || user.status == UserStatus.rejected)
          SizedBox(width: 8),

        // Reject Button (only for pending)
        if (user.status == UserStatus.pending)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _rejectUser(user),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Reject',
                    style: TextStyle(fontSize: isMobile ? 12 : 13),
                  ),
                ],
              ),
            ),
          ),

        if (user.status == UserStatus.pending) SizedBox(width: 8),

        // Block/Unblock Button
        Expanded(
          child: OutlinedButton(
            onPressed: user.isBlocked ? () => _unblockUser(user) : () => _blockUser(user),
            style: OutlinedButton.styleFrom(
              foregroundColor: user.isBlocked ? Color(0xFF0066FF) : Colors.orange,
              side: BorderSide(color: user.isBlocked ? Color(0xFF0066FF) : Colors.orange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(user.isBlocked ? Icons.lock_open : Icons.block, size: 16),
                SizedBox(width: 4),
                Text(
                  user.isBlocked ? 'Unblock' : 'Block',
                  style: TextStyle(fontSize: isMobile ? 12 : 13),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 8),

        // View Details Button
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () => _viewUserDetails(user),
            icon: Icon(Icons.more_vert, color: Color(0xFF0066FF), size: 18),
            padding: EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  void _verifyUser(User user) {
    setState(() {
      user.status = UserStatus.verified;
    });
    _showSnackBar('✅ ${user.name} has been verified successfully');
  }

  void _rejectUser(User user) {
    setState(() {
      user.status = UserStatus.rejected;
    });
    _showSnackBar('❌ ${user.name} verification has been rejected');
  }

  void _blockUser(User user) {
    setState(() {
      user.isBlocked = true;
    });
    _showSnackBar('🚫 ${user.name} has been blocked');
  }

  void _unblockUser(User user) {
    setState(() {
      user.isBlocked = false;
    });
    _showSnackBar('✅ ${user.name} has been unblocked');
  }

  void _viewUserDetails(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUserDetailsSheet(user),
    );
  }

  Widget _buildUserDetailsSheet(User user) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF0051CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    user.profileImage ?? '👤',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                user.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                user.email,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
            SizedBox(height: 24),
            _buildDetailRow('Phone', user.phone ?? 'Not provided'),
            _buildDetailRow('User Type', user.type == UserType.client ? 'Client' : 'Freelancer'),
            _buildDetailRow('Status', _getStatusText(user.status)),
            _buildDetailRow('Account Status', user.isBlocked ? 'Blocked' : 'Active'),
            _buildDetailRow('Join Date', user.joinDate),
            if (user.rating != null) _buildDetailRow('Rating', '${user.rating}/5'),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade700),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return 'Verified';
      case UserStatus.pending:
        return 'Pending Verification';
      case UserStatus.rejected:
        return 'Rejected';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF0066FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(20),
      ),
    );
  }
}