


// ============================================================ // FREELANCER EARNING DASHBOARD — Single-file Flutter App // Packages: flutter_riverpod, fl_chart, shimmer, google_fonts, // local_auth, intl // ============================================================ import 'da




// ============================================================
//  FREELANCER EARNING DASHBOARD — Single-file Flutter App
//  Packages: flutter_riverpod, fl_chart, shimmer, google_fonts,
//            local_auth, intl
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:universal_platform/universal_platform.dart';

// ─────────────────────────────────────────────
//  THEME / CONSTANTS
// ─────────────────────────────────────────────
const Color kPrimary = Color(0xFF3ECFB2);    // teal-green (left of image)
const Color kSecondary = Color(0xFF56C8E8);  // sky-blue  (right of image)
const Color kBg = Color(0xFFF2FAFA);
const Color kCard = Colors.white;
const Color kText = Color(0xFF1A2E2C);
const Color kSubText = Color(0xFF6B8E8B);
const Color kSuccess = Color(0xFF27AE60);
const Color kWarning = Color(0xFFF39C12);
const Color kError = Color(0xFFE74C3C);
const Color kPurple = Color(0xFF8E44AD);

final kGradient = LinearGradient(
  colors: [Color(0xFF3ECFB2), Color(0xFF56C8E8)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

TextTheme _textTheme(TextTheme base) => GoogleFonts.poppinsTextTheme(base);

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
enum ProjectStatus { active, completed, disputed }
enum TransactionStatus { completed, pending, failed, refunded }
enum WithdrawalStatus { completed, processing, failed }
enum AccountStatus { verified, pending }
enum TransferSpeed { standard, instant, express }

class Project {
  final String id, name, client;
  final double budget, released;
  final ProjectStatus status;
  final List<Milestone> milestones;

  const Project({
    required this.id,
    required this.name,
    required this.client,
    required this.budget,
    required this.released,
    required this.status,
    required this.milestones,
  });
}

class Milestone {
  final String title;
  final double amount;
  final bool completed;

  const Milestone(
      {required this.title, required this.amount, required this.completed});
}

class Transaction {
  final String id, project, type;
  final double amount;
  final DateTime date;
  final TransactionStatus status;

  const Transaction({
    required this.id,
    required this.project,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class BankAccount {
  final String id;
  String bankName,
      holderName,
      maskedAccount,
      maskedRouting,
      accountType,
      nickname;
  AccountStatus status;
  bool isDefault;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.holderName,
    required this.maskedAccount,
    required this.maskedRouting,
    required this.accountType,
    required this.nickname,
    required this.status,
    required this.isDefault,
  });

  BankAccount copyWith({
    String? bankName,
    String? holderName,
    String? maskedAccount,
    String? maskedRouting,
    String? accountType,
    String? nickname,
    AccountStatus? status,
    bool? isDefault,
  }) =>
      BankAccount(
        id: id,
        bankName: bankName ?? this.bankName,
        holderName: holderName ?? this.holderName,
        maskedAccount: maskedAccount ?? this.maskedAccount,
        maskedRouting: maskedRouting ?? this.maskedRouting,
        accountType: accountType ?? this.accountType,
        nickname: nickname ?? this.nickname,
        status: status ?? this.status,
        isDefault: isDefault ?? this.isDefault,
      );
}

class OtherPaymentMethod {
  final String id, name, email, icon;
  bool isActive;

  OtherPaymentMethod({
    required this.id,
    required this.name,
    required this.email,
    required this.icon,
    required this.isActive,
  });
}

class WithdrawalRecord {
  final String id, method;
  final double amount, fee, received;
  final DateTime date;
  final WithdrawalStatus status;

  const WithdrawalRecord({
    required this.id,
    required this.method,
    required this.amount,
    required this.fee,
    required this.received,
    required this.date,
    required this.status,
  });
}

// ─────────────────────────────────────────────
//  DUMMY DATA
// ─────────────────────────────────────────────
final List<Project> _dummyProjects = [
  Project(
    id: 'P001',
    name: 'E-commerce Dev',
    client: 'TechCorp Inc.',
    budget: 5000,
    released: 2000,
    status: ProjectStatus.active,
    milestones: [
      Milestone(title: 'UI Design', amount: 1000, completed: true),
      Milestone(title: 'Backend API', amount: 2000, completed: true),
      Milestone(title: 'Testing & Deploy', amount: 2000, completed: false),
    ],
  ),
  Project(
    id: 'P002',
    name: 'Mobile App',
    client: 'StartupXYZ',
    budget: 3500,
    released: 1500,
    status: ProjectStatus.active,
    milestones: [
      Milestone(title: 'Wireframes', amount: 500, completed: true),
      Milestone(title: 'iOS Development', amount: 1500, completed: false),
      Milestone(title: 'Android & QA', amount: 1500, completed: false),
    ],
  ),
  Project(
    id: 'P003',
    name: 'Logo Design',
    client: 'BrandCo',
    budget: 500,
    released: 250,
    status: ProjectStatus.active,
    milestones: [
      Milestone(title: 'Concepts (3)', amount: 250, completed: true),
      Milestone(title: 'Final Files', amount: 250, completed: false),
    ],
  ),
];

final List<Transaction> _dummyTransactions = [
  Transaction(
      id: 'TXN-2024-001',
      project: 'E-commerce Dev',
      type: 'Milestone Release',
      amount: 2000,
      date: DateTime(2024, 1, 15),
      status: TransactionStatus.completed),
  Transaction(
      id: 'TXN-2024-002',
      project: 'Mobile App',
      type: 'Milestone Release',
      amount: 1500,
      date: DateTime(2024, 1, 10),
      status: TransactionStatus.completed),
  Transaction(
      id: 'TXN-2024-003',
      project: 'Logo Design',
      type: 'Initial Payment',
      amount: 250,
      date: DateTime(2024, 1, 8),
      status: TransactionStatus.completed),
  Transaction(
      id: 'TXN-2023-045',
      project: 'Dashboard UI',
      type: 'Final Payment',
      amount: 3200,
      date: DateTime(2023, 12, 20),
      status: TransactionStatus.completed),
  Transaction(
      id: 'TXN-2023-041',
      project: 'API Integration',
      type: 'Partial Release',
      amount: 800,
      date: DateTime(2023, 12, 10),
      status: TransactionStatus.pending),
  Transaction(
      id: 'TXN-2023-038',
      project: 'SEO Audit',
      type: 'Full Payment',
      amount: 450,
      date: DateTime(2023, 11, 25),
      status: TransactionStatus.failed),
];

List<BankAccount> _dummyBankAccounts() => [
  BankAccount(
    id: 'BA001',
    bankName: 'Chase Bank',
    holderName: 'John Freelancer',
    maskedAccount: '****1234',
    maskedRouting: '****5678',
    accountType: 'Checking',
    nickname: 'Primary Account',
    status: AccountStatus.verified,
    isDefault: true,
  ),
  BankAccount(
    id: 'BA002',
    bankName: 'Bank of America',
    holderName: 'John Freelancer',
    maskedAccount: '****7890',
    maskedRouting: '****4321',
    accountType: 'Savings',
    nickname: 'Savings Account',
    status: AccountStatus.verified,
    isDefault: false,
  ),
  BankAccount(
    id: 'BA003',
    bankName: 'Wells Fargo',
    holderName: 'John Freelancer',
    maskedAccount: '****5566',
    maskedRouting: '****9900',
    accountType: 'Checking',
    nickname: 'Business Account',
    status: AccountStatus.pending,
    isDefault: false,
  ),
];

List<OtherPaymentMethod> _dummyOtherMethods() => [
  OtherPaymentMethod(
      id: 'OM001',
      name: 'PayPal',
      email: 'john@example.com',
      icon: '💳',
      isActive: true),
  OtherPaymentMethod(
      id: 'OM002',
      name: 'Payoneer',
      email: 'john@payoneer.com',
      icon: '🌐',
      isActive: true),
  OtherPaymentMethod(
      id: 'OM003',
      name: 'Wise',
      email: 'john@wise.com',
      icon: '🦋',
      isActive: false),
  OtherPaymentMethod(
      id: 'OM004',
      name: 'Crypto Wallet',
      email: '0x1234...abcd',
      icon: '₿',
      isActive: true),
];

final List<WithdrawalRecord> _dummyWithdrawals = [
  WithdrawalRecord(
      id: 'WD-2024-001',
      method: 'Bank Transfer (Chase ****1234)',
      amount: 1000,
      fee: 0,
      received: 1000,
      date: DateTime(2024, 1, 5),
      status: WithdrawalStatus.completed),
  WithdrawalRecord(
      id: 'WD-2023-044',
      method: 'PayPal',
      amount: 500,
      fee: 0,
      received: 500,
      date: DateTime(2023, 12, 15),
      status: WithdrawalStatus.completed),
  WithdrawalRecord(
      id: 'WD-2023-031',
      method: 'Wise',
      amount: 750,
      fee: 0,
      received: 750,
      date: DateTime(2023, 11, 10),
      status: WithdrawalStatus.processing),
];

// ─────────────────────────────────────────────
//  STATE CLASSES
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
//  STATE CLASSES (UNCHANGED)
// ─────────────────────────────────────────────
class DashboardState {
  final bool isLoading;
  final int selectedTab;
  final double availableBalance;
  final List<Project> projects;
  final List<Transaction> transactions;
  final List<BankAccount> bankAccounts;
  final List<OtherPaymentMethod> otherMethods;
  final List<WithdrawalRecord> withdrawalHistory;
  final String chartFilter;
  final String errorMessage;
  final bool isOnline;

  const DashboardState({
    required this.isLoading,
    required this.selectedTab,
    required this.availableBalance,
    required this.projects,
    required this.transactions,
    required this.bankAccounts,
    required this.otherMethods,
    required this.withdrawalHistory,
    required this.chartFilter,
    this.errorMessage = '',
    this.isOnline = true,
  });

  DashboardState copyWith({
    bool? isLoading,
    int? selectedTab,
    double? availableBalance,
    List<Project>? projects,
    List<Transaction>? transactions,
    List<BankAccount>? bankAccounts,
    List<OtherPaymentMethod>? otherMethods,
    List<WithdrawalRecord>? withdrawalHistory,
    String? chartFilter,
    String? errorMessage,
    bool? isOnline,
  }) =>
      DashboardState(
        isLoading: isLoading ?? this.isLoading,
        selectedTab: selectedTab ?? this.selectedTab,
        availableBalance: availableBalance ?? this.availableBalance,
        projects: projects ?? this.projects,
        transactions: transactions ?? this.transactions,
        bankAccounts: bankAccounts ?? this.bankAccounts,
        otherMethods: otherMethods ?? this.otherMethods,
        withdrawalHistory: withdrawalHistory ?? this.withdrawalHistory,
        chartFilter: chartFilter ?? this.chartFilter,
        errorMessage: errorMessage ?? this.errorMessage,
        isOnline: isOnline ?? this.isOnline,
      );
}

// ─────────────────────────────────────────────
//  CROSS-PLATFORM DASHBOARD NOTIFIER
// ─────────────────────────────────────────────
class DashboardNotifier extends StateNotifier<DashboardState> {
  late final String baseUrl;

  DashboardNotifier() : super(DashboardState(
    isLoading: true,
    selectedTab: 2,
    availableBalance: 0,
    projects: [],
    transactions: [],
    bankAccounts: [],
    otherMethods: [],
    withdrawalHistory: [],
    chartFilter: 'Monthly',
  )) {
    _initBaseUrl();
  }

  Future<void> _initBaseUrl() async {
    // Cross-platform base URL detection
    if (UniversalPlatform.isWeb) {
      baseUrl = 'http://localhost:5000';
    } else if (UniversalPlatform.isAndroid) {
      // Try emulator first, fallback to localhost
      baseUrl = 'http://10.0.2.2:5000';
    } else {
      baseUrl = 'http://localhost:5000';
    }

    print('📍 Running on: ${UniversalPlatform.isAndroid ? "Android" :
    UniversalPlatform.isIOS ? "iOS" :
    UniversalPlatform.isWeb ? "Web" :
    UniversalPlatform.isWindows ? "Windows" :
    UniversalPlatform.isMacOS ? "macOS" :
    UniversalPlatform.isLinux ? "Linux" : "Unknown"}');
    print('📍 API Base URL: $baseUrl');

    await _loadDataFromServer();
  }

  Future<void> _loadDataFromServer() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      // Test connection first
      final testResponse = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 3));

      if (testResponse.statusCode != 200) {
        throw Exception('Server not responding');
      }

      state = state.copyWith(isOnline: true);

      // Fetch all data in parallel
      final results = await Future.wait([
        _fetchEarnings(),
        _fetchProjects(),
        _fetchTransactions(),
        _fetchWithdrawals(),
        _fetchPaymentMethods(),
      ]);

      final earningsData = results[0];
      final projectsData = results[1];
      final transactionsData = results[2];
      final withdrawalsData = results[3];
      final paymentMethodsData = results[4];

      state = state.copyWith(
        isLoading: false,
        availableBalance: earningsData['availableBalance'] ?? 0,
        projects: _parseProjects(projectsData),
        transactions: _parseTransactions(transactionsData),
        withdrawalHistory: _parseWithdrawals(withdrawalsData),
        bankAccounts: _parseBankAccounts(paymentMethodsData),
        otherMethods: _parseOtherMethods(paymentMethodsData),
        errorMessage: '',
      );
    } catch (e) {
      print('⚠️ Error loading data: $e');
      print('⚠️ Using fallback dummy data');

      state = state.copyWith(
        isLoading: false,
        isOnline: false,
        errorMessage: 'Offline mode - Using local data',
        availableBalance: 3200,
        projects: _getDummyProjects(),
        transactions: _getDummyTransactions(),
        withdrawalHistory: _getDummyWithdrawals(),
        bankAccounts: _getDummyBankAccounts(),
        otherMethods: _getDummyOtherMethods(),
      );
    }
  }

  // API CALLS WITH CROSS-PLATFORM SUPPORT
  Future<Map<String, dynamic>> _fetchEarnings() async {
    try {
      final uri = Uri.parse('$baseUrl/api/freelancer/earnings');
      print('🌐 Fetching: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return {
            'availableBalance': (data['data']['availableBalance'] ?? 0).toDouble(),
            'inEscrow': (data['data']['inEscrow'] ?? 0).toDouble(),
            'totalEarned': (data['data']['totalEarned'] ?? 0).toDouble(),
          };
        }
      }
    } catch (e) {
      print('Earnings fetch error: $e');
    }
    return {'availableBalance': 3200, 'inEscrow': 9000, 'totalEarned': 14500};
  }

  Future<Map<String, dynamic>> _fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/freelancer/projects'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Projects fetch error: $e');
    }
    return {'success': false};
  }

  Future<Map<String, dynamic>> _fetchTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/freelancer/transactions'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Transactions fetch error: $e');
    }
    return {'success': false};
  }

  Future<Map<String, dynamic>> _fetchWithdrawals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/freelancer/withdrawals'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Withdrawals fetch error: $e');
    }
    return {'success': false};
  }

  Future<Map<String, dynamic>> _fetchPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/freelancer/payment-methods'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Payment methods fetch error: $e');
    }
    return {'success': false};
  }

  // PARSE METHODS (Same as before)
  List<Project> _parseProjects(Map<String, dynamic> response) {
    if (!response['success']) return _getDummyProjects();

    final List<dynamic> projectsJson = response['data'];
    return projectsJson.map((json) {
      List<Milestone> milestones = (json['milestones'] as List).map((m) {
        return Milestone(
          title: m['title'],
          amount: (m['amount'] as num).toDouble(),
          completed: m['completed'],
        );
      }).toList();

      ProjectStatus status;
      switch (json['status']) {
        case 'completed': status = ProjectStatus.completed;
        case 'disputed': status = ProjectStatus.disputed;
        default: status = ProjectStatus.active;
      }

      return Project(
        id: json['id'],
        name: json['name'],
        client: json['client'],
        budget: (json['budget'] as num).toDouble(),
        released: (json['released'] as num).toDouble(),
        status: status,
        milestones: milestones,
      );
    }).toList();
  }

  List<Transaction> _parseTransactions(Map<String, dynamic> response) {
    if (!response['success']) return _getDummyTransactions();

    final List<dynamic> transactionsJson = response['data'];
    return transactionsJson.map((json) {
      TransactionStatus status;
      switch (json['status']) {
        case 'pending': status = TransactionStatus.pending;
        case 'failed': status = TransactionStatus.failed;
        case 'refunded': status = TransactionStatus.refunded;
        default: status = TransactionStatus.completed;
      }

      return Transaction(
        id: json['id'],
        project: json['projectName'],
        type: json['type'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        status: status,
      );
    }).toList();
  }

  List<WithdrawalRecord> _parseWithdrawals(Map<String, dynamic> response) {
    if (!response['success']) return _getDummyWithdrawals();

    final List<dynamic> withdrawalsJson = response['data'];
    return withdrawalsJson.map((json) {
      WithdrawalStatus status;
      switch (json['status']) {
        case 'processing': status = WithdrawalStatus.processing;
        case 'failed': status = WithdrawalStatus.failed;
        default: status = WithdrawalStatus.completed;
      }

      return WithdrawalRecord(
        id: json['id'],
        method: json['method'],
        amount: (json['amount'] as num).toDouble(),
        fee: (json['fee'] as num).toDouble(),
        received: (json['received'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        status: status,
      );
    }).toList();
  }

  List<BankAccount> _parseBankAccounts(Map<String, dynamic> response) {
    if (!response['success']) return _getDummyBankAccounts();

    final List<dynamic> methodsJson = response['data'];
    final bankMethods = methodsJson.where((m) => m['type'] == 'bank').toList();

    return bankMethods.map((json) {
      return BankAccount(
        id: json['id'],
        bankName: json['details']['bankName'] ?? '',
        holderName: json['details']['holderName'] ?? '',
        maskedAccount: json['details']['accountNumber'] ?? '',
        maskedRouting: json['details']['routingNumber'] ?? '',
        accountType: json['details']['accountType'] ?? 'Checking',
        nickname: json['details']['nickname'] ?? '',
        status: json['status'] == 'verified' ? AccountStatus.verified : AccountStatus.pending,
        isDefault: json['isDefault'] ?? false,
      );
    }).toList();
  }

  List<OtherPaymentMethod> _parseOtherMethods(Map<String, dynamic> response) {
    if (!response['success']) return _getDummyOtherMethods();

    final List<dynamic> methodsJson = response['data'];
    final otherMethods = methodsJson.where((m) => m['type'] != 'bank').toList();

    final icons = {'paypal': '💳', 'payoneer': '🌐', 'wise': '🦋', 'crypto': '₿'};

    return otherMethods.map((json) {
      return OtherPaymentMethod(
        id: json['id'],
        name: json['type'].toString().toUpperCase(),
        email: json['details']['email'] ?? json['details']['walletAddress'] ?? '',
        icon: icons[json['type']] ?? '💳',
        isActive: json['isActive'] ?? false,
      );
    }).toList();
  }

  // DUMMY DATA (FALLBACK)
  List<Project> _getDummyProjects() => [
    Project(
      id: 'P001',
      name: 'E-commerce Dev',
      client: 'TechCorp Inc.',
      budget: 5000,
      released: 2000,
      status: ProjectStatus.active,
      milestones: [
        Milestone(title: 'UI Design', amount: 1000, completed: true),
        Milestone(title: 'Backend API', amount: 2000, completed: true),
        Milestone(title: 'Testing & Deploy', amount: 2000, completed: false),
      ],
    ),
    Project(
      id: 'P002',
      name: 'Mobile App',
      client: 'StartupXYZ',
      budget: 3500,
      released: 1500,
      status: ProjectStatus.active,
      milestones: [
        Milestone(title: 'Wireframes', amount: 500, completed: true),
        Milestone(title: 'iOS Development', amount: 1500, completed: false),
        Milestone(title: 'Android & QA', amount: 1500, completed: false),
      ],
    ),
  ];

  List<Transaction> _getDummyTransactions() => [
    Transaction(
      id: 'TXN-001',
      project: 'E-commerce Dev',
      type: 'Milestone Release',
      amount: 2000,
      date: DateTime(2024, 1, 15),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'TXN-002',
      project: 'Mobile App',
      type: 'Milestone Release',
      amount: 1500,
      date: DateTime(2024, 1, 10),
      status: TransactionStatus.completed,
    ),
  ];

  List<WithdrawalRecord> _getDummyWithdrawals() => [
    WithdrawalRecord(
      id: 'WD-001',
      method: 'Bank Transfer',
      amount: 1000,
      fee: 0,
      received: 1000,
      date: DateTime(2024, 1, 5),
      status: WithdrawalStatus.completed,
    ),
  ];

  List<BankAccount> _getDummyBankAccounts() => [
    BankAccount(
      id: 'BA001',
      bankName: 'Chase Bank',
      holderName: 'John Freelancer',
      maskedAccount: '****1234',
      maskedRouting: '****5678',
      accountType: 'Checking',
      nickname: 'Primary Account',
      status: AccountStatus.verified,
      isDefault: true,
    ),
  ];

  List<OtherPaymentMethod> _getDummyOtherMethods() => [
    OtherPaymentMethod(
      id: 'OM001',
      name: 'PayPal',
      email: 'john@example.com',
      icon: '💳',
      isActive: true,
    ),
  ];

  void setTab(int tab) => state = state.copyWith(selectedTab: tab);
  void setChartFilter(String f) => state = state.copyWith(chartFilter: f);

  Future<void> refresh() async {
    await _loadDataFromServer();
  }

  Future<void> completeMilestone(String projectId, int milestoneIndex) async {
    if (!state.isOnline) {
      print('Offline mode: Cannot complete milestone');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/freelancer/projects/$projectId/milestones/$milestoneIndex'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        await _loadDataFromServer();
      }
    } catch (e) {
      print('Error completing milestone: $e');
    }
  }

  Future<void> deductBalance(double amount, WithdrawalRecord record) async {
    if (!state.isOnline) {
      // Local update when offline
      final newBal = (state.availableBalance - amount).clamp(0, double.infinity).toDouble();
      state = state.copyWith(
        availableBalance: newBal,
        withdrawalHistory: [record, ...state.withdrawalHistory],
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/freelancer/withdrawals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'fee': record.fee,
          'received': record.received,
          'method': record.method,
        }),
      );

      if (response.statusCode == 201) {
        await _loadDataFromServer();
      }
    } catch (e) {
      print('Error processing withdrawal: $e');
      // Local fallback
      final newBal = (state.availableBalance - amount).clamp(0, double.infinity).toDouble();
      state = state.copyWith(
        availableBalance: newBal,
        withdrawalHistory: [record, ...state.withdrawalHistory],
      );
    }
  }

  void addBankAccount(BankAccount acc) {
    state = state.copyWith(bankAccounts: [...state.bankAccounts, acc]);
  }

  void updateBankAccount(BankAccount acc) {
    final list = state.bankAccounts.map((b) => b.id == acc.id ? acc : b).toList();
    state = state.copyWith(bankAccounts: list);
  }

  void deleteBankAccount(String id) {
    final list = state.bankAccounts.where((b) => b.id != id).toList();
    state = state.copyWith(bankAccounts: list);
  }

  void setDefaultBankAccount(String id) {
    final list = state.bankAccounts.map((b) => b.copyWith(isDefault: b.id == id)).toList();
    state = state.copyWith(bankAccounts: list);
  }

  void verifyBankAccount(String id) {
    final list = state.bankAccounts.map((b) => b.id == id ? b.copyWith(status: AccountStatus.verified) : b).toList();
    state = state.copyWith(bankAccounts: list);
  }

  void deleteOtherMethod(String id) {
    final list = state.otherMethods.where((m) => m.id != id).toList();
    state = state.copyWith(otherMethods: list);
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(
      (ref) => DashboardNotifier(),
);

// ─────────────────────────────────────────────
//  MAIN
// ─────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: FreelancerApp()));
}

class FreelancerApp extends StatelessWidget {
  const FreelancerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelancer Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kPrimary,
        textTheme: _textTheme(ThemeData.light().textTheme),
        scaffoldBackgroundColor: kBg,
      ),
      home: const EarningsDashboard(),
    );
  }
}

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class EarningsDashboard extends ConsumerWidget {
  const EarningsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);
    final w = MediaQuery.of(context).size.width;

    // Responsive content width — narrows on tablet/web for pro look
    final double maxW = w > 900 ? 860 : w > 600 ? 680 : double.infinity;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // ── Slim gradient header — title only ──

          // ── Body with centered constrained width ──
          Expanded(
            child: state.isLoading
                ? _buildShimmer(context, w)
                : RefreshIndicator(
              color: kPrimary,
              onRefresh: () async => notifier.refresh(),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: _buildBody(context, ref, state, w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  // ── Shimmer Loading ──
  Widget _buildShimmer(BuildContext context, double w) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _shimmerBox(180),
          const SizedBox(height: 12),
          _shimmerBox(50),
          const SizedBox(height: 12),
          _shimmerBox(300),
          const SizedBox(height: 12),
          _shimmerBox(150),
        ],
      ),
    );
  }

  Widget _shimmerBox(double h) => Container(
    height: h,
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
  );

  // ── Body ──
  Widget _buildBody(
      BuildContext context, WidgetRef ref, DashboardState state, double w) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _EscrowCard(),
        const SizedBox(height: 16),
        _TabBar(),
        const SizedBox(height: 16),
        _TabContent(),
      ],
    );
  }

}

// ─────────────────────────────────────────────
//  ESCROW CARD
// ─────────────────────────────────────────────
class _EscrowCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Revenue Shield',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  const Icon(Icons.verified, color: kPrimary, size: 14),
                  const SizedBox(width: 4),
                  Text('100% Protected',
                      style: GoogleFonts.poppins(
                          color: kPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (ctx, constraints) {
              final isNarrow = constraints.maxWidth < 340;
              return isNarrow
                  ? Column(children: _escrowItems())
                  : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _escrowItems());
            }),
          ],
        ),
      ),
    );
  }

  List<Widget> _escrowItems() => [
    _EscrowItem(label: 'In Escrow', value: '\$9,000', icon: Icons.savings),
    _EscrowItem(
        label: 'Released', value: '\$5,500', icon: Icons.check_circle),
    _EscrowItem(label: 'Active', value: '2', icon: Icons.play_circle),
    _EscrowItem(label: 'Disputes', value: '1', icon: Icons.gavel),
  ];
}

class _EscrowItem extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _EscrowItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        Text(label,
            style:
            GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  TAB BAR
// ─────────────────────────────────────────────
class _TabBar extends ConsumerWidget {
  static const _tabs = ['Projects', 'Transactions', 'Payments', 'Earnings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(dashboardProvider).selectedTab;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSel = selected == i;
          return GestureDetector(
            onTap: () =>
                ref.read(dashboardProvider.notifier).setTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSel ? kGradient : null,
                color: isSel ? null : Colors.white,
                borderRadius: BorderRadius.circular(21),
                boxShadow: isSel
                    ? [
                  BoxShadow(
                      color: kPrimary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
                    : null,
              ),
              child: Text(_tabs[i],
                  style: GoogleFonts.poppins(
                      color: isSel ? Colors.white : kSubText,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13)),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TAB CONTENT
// ─────────────────────────────────────────────
class _TabContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(dashboardProvider).selectedTab;
    switch (tab) {
      case 0:
        return const _ProjectsTab();
      case 1:
        return const _TransactionsTab();
      case 2:
        return const _PaymentsTab();
      case 3:
        return const _EarningsTab();
      default:
        return const SizedBox();
    }
  }
}

// ─────────────────────────────────────────────
//  PROJECTS TAB
// ─────────────────────────────────────────────
class _ProjectsTab extends ConsumerWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(dashboardProvider).projects;
    return Column(
      children: projects.map((p) => _ProjectCard(project: p)).toList(),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final progress = p.released / p.budget;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kText)),
                          Text(p.client,
                              style: GoogleFonts.poppins(
                                  color: kSubText, fontSize: 12)),
                        ],
                      ),
                    ),
                    _statusBadge(p.status),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Released: \$${p.released.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: kSubText)),
                              Text('Budget: \$${p.budget.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: kPrimary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: kPrimary.withOpacity(0.15),
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(kPrimary),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: kSubText,
                    ),
                  ]),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text('Milestones',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: kText)),
                  const SizedBox(height: 8),
                  ...p.milestones.map((m) => _MilestoneRow(m: m)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(ProjectStatus s) {
    final colors = {
      ProjectStatus.active: kSuccess,
      ProjectStatus.completed: kPrimary,
      ProjectStatus.disputed: kError,
    };
    final labels = {
      ProjectStatus.active: 'Active',
      ProjectStatus.completed: 'Completed',
      ProjectStatus.disputed: 'Disputed',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors[s]!.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(labels[s]!,
          style: GoogleFonts.poppins(
              color: colors[s]!, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final Milestone m;
  const _MilestoneRow({required this.m});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            m.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: m.completed ? kSuccess : kSubText,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(m.title,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: m.completed ? kText : kSubText,
                    decoration:
                    m.completed ? TextDecoration.none : null)),
          ),
          Text('\$${m.amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: m.completed ? kSuccess : kSubText)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TRANSACTIONS TAB
// ─────────────────────────────────────────────
class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(dashboardProvider).transactions;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transaction History',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: kText)),
              const SizedBox(height: 12),
              ...txns.map((t) => _TxnRow(t: t)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TxnRow extends StatelessWidget {
  final Transaction t;
  const _TxnRow({required this.t});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      TransactionStatus.completed: kSuccess,
      TransactionStatus.pending: kWarning,
      TransactionStatus.failed: kError,
      TransactionStatus.refunded: kPurple,
    };
    final statusLabels = {
      TransactionStatus.completed: 'Completed',
      TransactionStatus.pending: 'Pending',
      TransactionStatus.failed: 'Failed',
      TransactionStatus.refunded: 'Refunded',
    };
    final fmt = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: kGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_downward, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.project,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: kText)),
                Text('${t.id} · ${fmt.format(t.date)}',
                    style:
                    GoogleFonts.poppins(color: kSubText, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+\$${t.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: kSuccess,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColors[t.status]!.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(statusLabels[t.status]!,
                    style: GoogleFonts.poppins(
                        color: statusColors[t.status]!,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PAYMENTS TAB
// ─────────────────────────────────────────────
class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    return Column(
      children: [
        _BalanceCard(balance: state.availableBalance),
        const SizedBox(height: 16),
        _BankAccountsSection(),
        const SizedBox(height: 16),
        _OtherMethodsSection(),
        const SizedBox(height: 16),
        _WithdrawalHistorySection(),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Balance',
                    style:
                    GoogleFonts.poppins(color: kSubText, fontSize: 13)),
                const SizedBox(height: 4),
                Text('\$${NumberFormat('#,##0.00').format(balance)}',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: kText)),
                Text('Ready to withdraw',
                    style: GoogleFonts.poppins(
                        color: kSuccess, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openWithdrawal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: kGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: kPrimary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(children: [
                const Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('Withdraw Now',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openWithdrawal(BuildContext context) async {
    // Biometric auth
    final auth = LocalAuthentication();
    bool authed = false;
    try {
      final canCheck = await auth.canCheckBiometrics;
      if (canCheck) {
        authed = await auth.authenticate(
          localizedReason: 'Authenticate to proceed with withdrawal',
          options: const AuthenticationOptions(biometricOnly: false),
        );
      } else {
        authed = true; // No biometrics available, proceed
      }
    } catch (_) {
      authed = true; // Fallback on simulator/error
    }
    if (!authed) return;
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _WithdrawalModal(maxBalance: balance),
      );
    }
  }
}

// ─────────────────────────────────────────────
//  WITHDRAWAL MODAL (multi-step)
// ─────────────────────────────────────────────
class _WithdrawalModal extends ConsumerStatefulWidget {
  final double maxBalance;
  const _WithdrawalModal({required this.maxBalance});

  @override
  ConsumerState<_WithdrawalModal> createState() => _WithdrawalModalState();
}

class _WithdrawalModalState extends ConsumerState<_WithdrawalModal> {
  int _step = 0;
  double _amount = 0;
  int _methodIndex = 0; // 0=Bank,1=PayPal,2=Payoneer,3=Wise,4=Crypto
  String? _selectedBankId;
  TransferSpeed _speed = TransferSpeed.standard;
  String _note = '';
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _methods = [
    'Bank Transfer',
    'PayPal',
    'Payoneer',
    'Wise',
    'Crypto'
  ];
  static const _methodIcons = ['🏦', '💳', '🌐', '🦋', '₿'];

  double get _fee {
    if (_methodIndex != 0) return 0;
    switch (_speed) {
      case TransferSpeed.instant:
        return 2.99;
      case TransferSpeed.express:
        return 0.99;
      default:
        return 0;
    }
  }

  double get _received => _amount - _fee;

  String get _arrivalText {
    if (_methodIndex != 0) return '1-3 business days';
    switch (_speed) {
      case TransferSpeed.instant:
        return '30 minutes';
      case TransferSpeed.express:
        return '1 business day';
      default:
        return '3-5 business days';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banks = ref.watch(dashboardProvider).bankAccounts;
    _selectedBankId ??=
        banks.firstWhere((b) => b.isDefault, orElse: () => banks.first).id;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _StepIndicator(current: _step, total: 4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStep(banks),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(List<BankAccount> banks) {
    switch (_step) {
      case 0:
        return _stepAmount();
      case 1:
        return _stepMethod();
      case 2:
        return _stepBankDetails(banks);
      case 3:
        return _stepReview(banks);
      default:
        return const SizedBox();
    }
  }

  // Step 1 — Amount
  Widget _stepAmount() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Amount',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 20, color: kText)),
          Text(
              'Min \$50 · Max \$${NumberFormat('#,##0.00').format(widget.maxBalance)}',
              style: GoogleFonts.poppins(color: kSubText, fontSize: 12)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _amountController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(
                fontSize: 32, fontWeight: FontWeight.bold, color: kText),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: GoogleFonts.poppins(
                  fontSize: 32, fontWeight: FontWeight.bold, color: kPrimary),
              hintText: '0.00',
              hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[300],
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kPrimary, width: 2)),
            ),
            validator: (v) {
              final val = double.tryParse(v ?? '');
              if (val == null) return 'Enter a valid amount';
              if (val < 50) return 'Minimum withdrawal is \$50';
              if (val > widget.maxBalance)
                return 'Exceeds available balance';
              return null;
            },
            onChanged: (v) =>
                setState(() => _amount = double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 20),
          // Quick buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [50, 100, 500, 1000].map((q) {
              return GestureDetector(
                onTap: () {
                  _amountController.text = q.toString();
                  setState(() => _amount = q.toDouble());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kPrimary.withOpacity(0.3)),
                  ),
                  child: Text('\$$q',
                      style: GoogleFonts.poppins(
                          color: kPrimary, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList()
              ..add(GestureDetector(
                onTap: () {
                  _amountController.text =
                      widget.maxBalance.toStringAsFixed(2);
                  setState(() => _amount = widget.maxBalance);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: kGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Max',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              )),
          ),
          const SizedBox(height: 24),
          // Fee calculator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              _feeRow('Withdrawal Amount',
                  '\$${NumberFormat('#,##0.00').format(_amount)}'),
              _feeRow('Fee', '0% — FREE',
                  valueColor: kSuccess),
              const Divider(height: 20),
              _feeRow('You Receive',
                  '\$${NumberFormat('#,##0.00').format(_received)}',
                  isBold: true),
            ]),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 190,  // Reduced width
              child: _GradientButton(
                label: 'Continue',
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _step = 1);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(color: kSubText, fontSize: 13)),
          Text(value,
              style: GoogleFonts.poppins(
                  color: valueColor ?? kText,
                  fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
        ],
      ),
    );
  }

  // Step 2 — Select Method
  Widget _stepMethod() {
    final icons = _methodIcons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Method',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 20, color: kText)),
        const SizedBox(height: 20),
        ...List.generate(_methods.length, (i) {
          final isSel = _methodIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _methodIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSel ? kPrimary : Colors.grey[200]!,
                    width: isSel ? 2 : 1),
                boxShadow: isSel
                    ? [
                  BoxShadow(
                      color: kPrimary.withOpacity(0.1),
                      blurRadius: 10)
                ]
                    : null,
              ),
              child: Row(children: [
                Text(icons[i], style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                    child: Text(_methods[i],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, color: kText))),
                Radio<int>(
                  value: i,
                  groupValue: _methodIndex,
                  activeColor: kPrimary,
                  onChanged: (v) => setState(() => _methodIndex = v!),
                ),
              ]),
            ),
          );
        }),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _OutlineButton(
                  label: 'Back', onTap: () => setState(() => _step = 0))),
          const SizedBox(width: 12),
          Expanded(
              child: _GradientButton(
                  label: 'Continue',
                  onTap: () => setState(() =>
                  _step = _methodIndex == 0 ? 2 : 3))),
        ]),
      ],
    );
  }

  // Step 3 — Bank Details
  Widget _stepBankDetails(List<BankAccount> banks) {
    final verifiedBanks =
    banks.where((b) => b.status == AccountStatus.verified).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bank Transfer Details',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 20, color: kText)),
        const SizedBox(height: 20),
        Text('Select Bank Account',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: kText)),
        const SizedBox(height: 8),
        ...verifiedBanks.map((b) {
          final isSel = _selectedBankId == b.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedBankId = b.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSel ? kPrimary : Colors.grey[200]!,
                    width: isSel ? 2 : 1),
              ),
              child: Row(children: [
                const Icon(Icons.account_balance, color: kPrimary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${b.bankName} ${b.maskedAccount}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      Text(b.accountType,
                          style: GoogleFonts.poppins(
                              color: kSubText, fontSize: 11)),
                    ],
                  ),
                ),
                Radio<String>(
                  value: b.id,
                  groupValue: _selectedBankId,
                  activeColor: kPrimary,
                  onChanged: (v) => setState(() => _selectedBankId = v),
                ),
              ]),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text('Transfer Speed',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: kText)),
        const SizedBox(height: 8),
        ...[
          (TransferSpeed.standard, 'Standard', '3-5 days', 'FREE'),
          (TransferSpeed.instant, 'Instant', '30 min', '\$2.99'),
          (TransferSpeed.express, 'Express', '1 day', '\$0.99'),
        ].map((s) {
          final isSel = _speed == s.$1;
          return GestureDetector(
            onTap: () => setState(() => _speed = s.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSel ? kPrimary : Colors.grey[200]!,
                    width: isSel ? 2 : 1),
              ),
              child: Row(children: [
                Radio<TransferSpeed>(
                  value: s.$1,
                  groupValue: _speed,
                  activeColor: kPrimary,
                  onChanged: (v) => setState(() => _speed = v!),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$2,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      Text(s.$3,
                          style: GoogleFonts.poppins(
                              color: kSubText, fontSize: 11)),
                    ],
                  ),
                ),
                Text(s.$4,
                    style: GoogleFonts.poppins(
                        color: s.$4 == 'FREE' ? kSuccess : kText,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          );
        }),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Reference Note (Optional)',
            labelStyle: GoogleFonts.poppins(color: kSubText),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimary),
            ),
          ),
          style: GoogleFonts.poppins(),
          onChanged: (v) => _note = v,
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _OutlineButton(
                  label: 'Back', onTap: () => setState(() => _step = 1))),
          const SizedBox(width: 12),
          Expanded(
              child: _GradientButton(
                  label: 'Review',
                  onTap: () => setState(() => _step = 3))),
        ]),
      ],
    );
  }

  // Step 4 — Review
  Widget _stepReview(List<BankAccount> banks) {
    final selBank =
    banks.firstWhere((b) => b.id == _selectedBankId, orElse: () => banks.first);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Confirm',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 20, color: kText)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: kGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Text('Withdrawal Amount',
                style:
                GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Text('\$${NumberFormat('#,##0.00').format(_amount)}',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 36)),
          ]),
        ),
        const SizedBox(height: 16),
        _reviewItem(
            'Amount', '\$${NumberFormat('#,##0.00').format(_amount)}'),
        _reviewItem('Fees', '\$${_fee.toStringAsFixed(2)}'),
        _reviewItem('You Receive',
            '\$${NumberFormat('#,##0.00').format(_received)}',
            isBold: true, valueColor: kSuccess),
        const Divider(),
        _reviewItem('Method', _methods[_methodIndex]),
        if (_methodIndex == 0)
          _reviewItem('Bank Account',
              '${selBank.bankName} ${selBank.maskedAccount}'),
        _reviewItem('Estimated Arrival', _arrivalText),
        if (_note.isNotEmpty) _reviewItem('Reference', _note),
        const SizedBox(height: 20),
        _GradientButton(
          label: 'Confirm Withdrawal',
          onTap: () => _confirm(selBank),
        ),
        const SizedBox(height: 10),
        _OutlineButton(
            label: 'Back',
            onTap: () => setState(
                    () => _step = _methodIndex == 0 ? 2 : 1)),
      ],
    );
  }

  void _confirm(BankAccount bank) {
    final wdId = 'WD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final record = WithdrawalRecord(
      id: wdId,
      method: _methodIndex == 0
          ? 'Bank Transfer (${bank.bankName} ${bank.maskedAccount})'
          : _methods[_methodIndex],
      amount: _amount,
      fee: _fee,
      received: _received,
      date: DateTime.now(),
      status: WithdrawalStatus.processing,
    );
    ref.read(dashboardProvider.notifier).deductBalance(_amount, record);
    Navigator.of(context).pop();
    _showSuccess(wdId);
  }

  void _showSuccess(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  gradient: kGradient, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Withdrawal Initiated!',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: kText)),
            const SizedBox(height: 8),
            Text('Withdrawal ID: $id',
                style: GoogleFonts.poppins(
                    color: kSubText, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Your funds are on the way.',
                style: GoogleFonts.poppins(
                    color: kSubText, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _GradientButton(label: 'Done', onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _reviewItem(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(color: kSubText, fontSize: 13)),
          Text(value,
              style: GoogleFonts.poppins(
                  color: valueColor ?? kText,
                  fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current, total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final labels = ['Amount', 'Method', 'Details', 'Review'];
    return Row(
      children: List.generate(total, (i) {
        final done = i < current;
        final active = i == current;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done ? kPrimary : Colors.grey[300],
                  ),
                ),
              Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: (done || active) ? kGradient : null,
                    color: (done || active) ? null : Colors.grey[200],
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 14)
                        : Text('${i + 1}',
                        style: GoogleFonts.poppins(
                            color: active
                                ? Colors.white
                                : kSubText,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(labels[i],
                    style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: (done || active) ? kPrimary : kSubText)),
              ]),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
//  BANK ACCOUNTS SECTION
// ─────────────────────────────────────────────
class _BankAccountsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banks = ref.watch(dashboardProvider).bankAccounts;
    final notifier = ref.read(dashboardProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Saved Bank Accounts',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: kText)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddBankModal(context, ref, null),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: kGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.add, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('Add Bank',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 11)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...banks.map((b) => _BankAccountCard(
            bank: b,
            onSetDefault: () => notifier.setDefaultBankAccount(b.id),
            onVerify: () => notifier.verifyBankAccount(b.id),
            onEdit: () => _showAddBankModal(context, ref, b),
            onDelete: () => _confirmDelete(context, notifier, b),
          )),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, DashboardNotifier notifier, BankAccount b) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
        Text('Delete Account', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Remove ${b.bankName} ${b.maskedAccount}?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: kSubText))),
          TextButton(
              onPressed: () {
                notifier.deleteBankAccount(b.id);
                Navigator.pop(context);
              },
              child: Text('Delete',
                  style: GoogleFonts.poppins(color: kError))),
        ],
      ),
    );
  }

  void _showAddBankModal(
      BuildContext context, WidgetRef ref, BankAccount? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBankModal(existing: existing, ref: ref),
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  final BankAccount bank;
  final VoidCallback onSetDefault, onVerify, onEdit, onDelete;

  const _BankAccountCard({
    required this.bank,
    required this.onSetDefault,
    required this.onVerify,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(12),
        border: bank.isDefault
            ? Border.all(color: kPrimary, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: kGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(bank.bankName,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 6),
                    if (bank.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('Default',
                            style: GoogleFonts.poppins(
                                color: kPrimary, fontSize: 9)),
                      ),
                  ]),
                  Text(bank.nickname,
                      style: GoogleFonts.poppins(
                          color: kSubText, fontSize: 11)),
                ],
              ),
            ),
            _statusChip(bank.status),
            IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: kSubText),
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: kError),
                onPressed: onDelete),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _infoBox('Account', bank.maskedAccount),
            const SizedBox(width: 10),
            _infoBox('Routing', bank.maskedRouting),
            const SizedBox(width: 10),
            _infoBox('Type', bank.accountType),
          ]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!bank.isDefault)
                SizedBox(
                  width: 140,
                  child: OutlinedButton(
                    onPressed: onSetDefault,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kPrimary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: Text('Set as Default',
                        style: GoogleFonts.poppins(fontSize: 11)),
                  ),
                ),
              if (!bank.isDefault && bank.status == AccountStatus.pending)
                const SizedBox(width: 8),
              if (bank.status == AccountStatus.pending)
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: onVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kWarning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 0,
                    ),
                    child: Text('Verify Account',
                        style: GoogleFonts.poppins(fontSize: 11)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(AccountStatus s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: s == AccountStatus.verified
            ? kSuccess.withOpacity(0.12)
            : kWarning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        s == AccountStatus.verified ? 'Verified' : 'Pending',
        style: GoogleFonts.poppins(
            color: s == AccountStatus.verified ? kSuccess : kWarning,
            fontSize: 10,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoBox(String label, String value) => Expanded(
    child: Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.poppins(
                color: kSubText, fontSize: 9)),
        Text(value,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: kText)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  ADD BANK MODAL
// ─────────────────────────────────────────────
class _AddBankModal extends StatefulWidget {
  final BankAccount? existing;
  final WidgetRef ref;

  const _AddBankModal({required this.existing, required this.ref});

  @override
  State<_AddBankModal> createState() => _AddBankModalState();
}

class _AddBankModalState extends State<_AddBankModal> {
  final _formKey = GlobalKey<FormState>();
  String _bankName = '', _holder = '', _account = '', _confirmAccount = '',
      _routing = '', _confirmRouting = '', _accountType = 'Checking',
      _nickname = '';
  bool _checkUploaded = false;

  static const _banks = [
    'Chase Bank',
    'Bank of America',
    'Wells Fargo',
    'Citibank',
    'US Bank',
    'Capital One',
    'TD Bank',
    'PNC Bank',
    'Other'
  ];
  static const _types = ['Checking', 'Savings', 'Business'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final b = widget.existing!;
      _bankName = b.bankName;
      _holder = b.holderName;
      _accountType = b.accountType;
      _nickname = b.nickname;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the row content
              children: [
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 220), // Width reduced
                    child: Text(
                        widget.existing == null
                            ? 'Add Bank Account'
                            : 'Edit Bank Account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: kText)),
                  ),
                ),
                const SizedBox(width: 8), // Space between text and close button
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdown(
                        label: 'Bank Name',
                        value: _bankName.isEmpty ? null : _bankName,
                        items: _banks,
                        onChanged: (v) =>
                            setState(() => _bankName = v ?? '')),
                    _buildField('Account Holder Name', (v) => _holder = v,
                        initial: _holder),
                    _buildField('Account Number', (v) => _account = v,
                        isNumber: true,
                        validator: (v) => v!.length < 8
                            ? 'Enter valid account number'
                            : null),
                    _buildField(
                        'Confirm Account Number',
                            (v) => _confirmAccount = v,
                        isNumber: true,
                        validator: (v) =>
                        v != _account ? 'Account numbers don\'t match' : null),
                    _buildField(
                        'Routing Number (9 digits)', (v) => _routing = v,
                        isNumber: true,
                        validator: (v) => v!.length != 9
                            ? 'Routing number must be 9 digits'
                            : null),
                    _buildField(
                        'Confirm Routing Number',
                            (v) => _confirmRouting = v,
                        isNumber: true,
                        validator: (v) =>
                        v != _routing ? 'Routing numbers don\'t match' : null),
                    _buildDropdown(
                        label: 'Account Type',
                        value: _accountType,
                        items: _types,
                        onChanged: (v) =>
                            setState(() => _accountType = v ?? 'Checking')),
                    _buildField('Nickname (Optional)', (v) => _nickname = v,
                        initial: _nickname, isRequired: false),
                    const SizedBox(height: 8),
                    // Upload check
                    GestureDetector(
                      onTap: () =>
                          setState(() => _checkUploaded = !_checkUploaded),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _checkUploaded
                              ? kSuccess.withOpacity(0.08)
                              : kBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _checkUploaded
                                ? kSuccess
                                : Colors.grey[300]!,
                            width: _checkUploaded ? 1.5 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Icon(
                            _checkUploaded
                                ? Icons.check_circle
                                : Icons.upload_file,
                            color: _checkUploaded ? kSuccess : kSubText,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upload Canceled Check',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13)),
                                Text(
                                    _checkUploaded
                                        ? 'check_scan.jpg uploaded ✓'
                                        : 'Optional – speeds up verification',
                                    style: GoogleFonts.poppins(
                                        color: _checkUploaded
                                            ? kSuccess
                                            : kSubText,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 200, // Reduced width (200 pixels)
                        child: _GradientButton(
                          label: widget.existing == null
                              ? 'Add Bank Account'
                              : 'Save Changes',
                          onTap: _submit,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, Function(String) onChanged,
      {String initial = '',
        bool isNumber = false,
        bool isRequired = true,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: initial,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
        isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: kSubText, fontSize: 13),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator ??
            (isRequired
                ? (v) => v!.isEmpty ? 'Required' : null
                : null),
      ),
    );
  }

  Widget _buildDropdown(
      {required String label,
        required String? value,
        required List<String> items,
        required Function(String?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: kSubText, fontSize: 13),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: GoogleFonts.poppins(fontSize: 14, color: kText),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = widget.ref.read(dashboardProvider.notifier);

    if (widget.existing == null) {
      // Add new
      final id = 'BA${DateTime.now().millisecondsSinceEpoch}';
      notifier.addBankAccount(BankAccount(
        id: id,
        bankName: _bankName,
        holderName: _holder,
        maskedAccount: '****${_account.substring(max(0, _account.length - 4))}',
        maskedRouting: '****${_routing.substring(max(0, _routing.length - 4))}',
        accountType: _accountType,
        nickname: _nickname.isEmpty ? _bankName : _nickname,
        status: AccountStatus.pending,
        isDefault: false,
      ));
    } else {
      // Edit existing
      notifier.updateBankAccount(widget.existing!.copyWith(
        bankName: _bankName,
        holderName: _holder,
        accountType: _accountType,
        nickname: _nickname.isEmpty ? _bankName : _nickname,
      ));
    }
    Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────
//  OTHER PAYMENT METHODS
// ─────────────────────────────────────────────
class _OtherMethodsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(dashboardProvider).otherMethods;
    final notifier = ref.read(dashboardProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Other Payment Methods',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 15, color: kText)),
          const SizedBox(height: 12),
          ...methods.map((m) => _OtherMethodRow(
              method: m,
              onDelete: () => notifier.deleteOtherMethod(m.id),
              onEdit: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Edit ${m.name} — Coming Soon',
                      style: GoogleFonts.poppins()),
                  backgroundColor: kPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              })),
        ],
      ),
    );
  }
}

class _OtherMethodRow extends StatelessWidget {
  final OtherPaymentMethod method;
  final VoidCallback onDelete, onEdit;
  const _OtherMethodRow(
      {required this.method,
        required this.onDelete,
        required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Text(method.icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(method.name,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, fontSize: 13)),
              Text(method.email,
                  style:
                  GoogleFonts.poppins(color: kSubText, fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: method.isActive
                ? kSuccess.withOpacity(0.12)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(method.isActive ? 'Active' : 'Inactive',
              style: GoogleFonts.poppins(
                  color: method.isActive ? kSuccess : kSubText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ),
        IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16, color: kSubText),
            onPressed: onEdit),
        IconButton(
            icon:
            const Icon(Icons.delete_outline, size: 16, color: kError),
            onPressed: onDelete),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  WITHDRAWAL HISTORY
// ─────────────────────────────────────────────
class _WithdrawalHistorySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(dashboardProvider).withdrawalHistory;
    final statusColors = {
      WithdrawalStatus.completed: kSuccess,
      WithdrawalStatus.processing: kWarning,
      WithdrawalStatus.failed: kError,
    };
    final statusLabels = {
      WithdrawalStatus.completed: 'Completed',
      WithdrawalStatus.processing: 'Processing',
      WithdrawalStatus.failed: 'Failed',
    };
    final fmt = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Withdrawal History',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 15, color: kText)),
          const SizedBox(height: 12),
          ...history.map((w) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(w.method,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: kText)),
                  ),
                  Text(
                      '-\$${NumberFormat('#,##0.00').format(w.amount)}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: kError,
                          fontSize: 14)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Text('${w.id} · ${fmt.format(w.date)}',
                      style: GoogleFonts.poppins(
                          color: kSubText, fontSize: 10)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColors[w.status]!.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(statusLabels[w.status]!,
                        style: GoogleFonts.poppins(
                            color: statusColors[w.status]!,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 8),
                // ✅ BUTTONS CHANGED - Width reduced and centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text('Receipt downloaded!',
                                style: GoogleFonts.poppins()),
                            backgroundColor: kSuccess,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                          ));
                        },
                        icon: const Icon(Icons.download, size: 14),
                        label: Text('Download Receipt',
                            style:
                            GoogleFonts.poppins(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimary,
                          side: BorderSide(
                              color: kPrimary.withOpacity(0.4)),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8)),
                          padding:
                          const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showDetails(context, w, statusColors, statusLabels, fmt);
                        },
                        icon: const Icon(Icons.info_outline, size: 14),
                        label: Text('View Details',
                            style:
                            GoogleFonts.poppins(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8)),
                          padding:
                          const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showDetails(
      BuildContext context,
      WithdrawalRecord w,
      Map statusColors,
      Map statusLabels,
      DateFormat fmt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Withdrawal Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('ID', w.id),
            _detailRow('Date', fmt.format(w.date)),
            _detailRow('Method', w.method),
            _detailRow('Amount',
                '\$${NumberFormat('#,##0.00').format(w.amount)}'),
            _detailRow('Fee',
                '\$${NumberFormat('#,##0.00').format(w.fee)}'),
            _detailRow('Received',
                '\$${NumberFormat('#,##0.00').format(w.received)}'),
            _detailRow(
                'Status', statusLabels[w.status] ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: GoogleFonts.poppins(color: kPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: kSubText, fontSize: 12))),
        Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    color: kText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500))),
      ],
    ),
  );
}
void _showDetails(
    BuildContext context,
    WithdrawalRecord w,
    Map statusColors,
    Map statusLabels,
    DateFormat fmt) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Withdrawal Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('ID', w.id),
          _detailRow('Date', fmt.format(w.date)),
          _detailRow('Method', w.method),
          _detailRow('Amount',
              '\$${NumberFormat('#,##0.00').format(w.amount)}'),
          _detailRow('Fee',
              '\$${NumberFormat('#,##0.00').format(w.fee)}'),
          _detailRow('Received',
              '\$${NumberFormat('#,##0.00').format(w.received)}'),
          _detailRow(
              'Status', statusLabels[w.status] ?? ''),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close',
              style: GoogleFonts.poppins(color: kPrimary)),
        ),
      ],
    ),
  );
}

Widget _detailRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    children: [
      Expanded(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: kSubText, fontSize: 12))),
      Expanded(
          child: Text(value,
              style: GoogleFonts.poppins(
                  color: kText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500))),
    ],
  ),
);


// ─────────────────────────────────────────────
//  EARNINGS TAB
// ─────────────────────────────────────────────
class _EarningsTab extends ConsumerWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _EarningsSummaryCards(),
        const SizedBox(height: 16),
        _EarningsChart(),
        const SizedBox(height: 16),
        _CategoryBreakdown(),
        const SizedBox(height: 16),
        _ProjectEarningsList(),
      ],
    );
  }
}

class _EarningsSummaryCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _SummaryCard(
          title: 'Total Lifetime',
          value: '\$14,500',
          subtitle: 'All time earnings',
          icon: Icons.account_balance_wallet,
          growth: '+12.5%',
          isPositive: true,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _SummaryCard(
          title: 'This Month',
          value: '\$2,450',
          subtitle: 'vs \$2,100 last month',
          icon: Icons.trending_up,
          growth: '+16.7%',
          isPositive: true,
        ),
      ),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value, subtitle, growth;
  final IconData icon;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.growth,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  gradient: kGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const Spacer(),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isPositive
                    ? kSuccess.withOpacity(0.1)
                    : kError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: isPositive ? kSuccess : kError,
                ),
                const SizedBox(width: 2),
                Text(growth,
                    style: GoogleFonts.poppins(
                        color: isPositive ? kSuccess : kError,
                        fontSize: 9,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kText)),
          Text(title,
              style: GoogleFonts.poppins(
                  color: kText,
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
          Text(subtitle,
              style:
              GoogleFonts.poppins(color: kSubText, fontSize: 10)),
        ],
      ),
    );
  }
}

class _EarningsChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dashboardProvider).chartFilter;
    final notifier = ref.read(dashboardProvider.notifier);

    final weeklyData = [1200.0, 950.0, 1800.0, 1400.0, 2100.0, 1600.0, 1900.0];
    final monthlyData = [3200.0, 2800.0, 3500.0, 4200.0, 3800.0, 4500.0, 3900.0, 4800.0, 5200.0, 4600.0, 5500.0, 6200.0];
    final yearlyData = [12000.0, 15000.0, 18000.0, 22000.0, 19000.0];

    final dataMap = {'Weekly': weeklyData, 'Monthly': monthlyData, 'Yearly': yearlyData};
    final labels = {
      'Weekly': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'Monthly': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      'Yearly': ['2020', '2021', '2022', '2023', '2024'],
    };
    final data = dataMap[filter]!;
    final lbls = labels[filter]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Earnings Overview',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: kText)),
            const Spacer(),
            ...['Weekly', 'Monthly', 'Yearly'].map((f) {
              final isSel = filter == f;
              return GestureDetector(
                onTap: () => notifier.setChartFilter(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isSel ? kGradient : null,
                    color: isSel ? null : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(f,
                      style: GoogleFonts.poppins(
                          color: isSel ? Colors.white : kSubText,
                          fontSize: 10,
                          fontWeight: isSel
                              ? FontWeight.w600
                              : FontWeight.normal)),
                ),
              );
            }),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data.reduce(max) * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => kPrimary,
                    getTooltipItem: (group, gIdx, rod, rIdx) =>
                        BarTooltipItem(
                          '\$${NumberFormat('#,##0').format(rod.toY)}',
                          GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                        ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, meta) {
                        final idx = v.toInt();
                        if (idx >= lbls.length) return const SizedBox();
                        return Text(lbls[idx],
                            style: GoogleFonts.poppins(
                                color: kSubText, fontSize: 9));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: data.reduce(max) / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey[200]!, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  data.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i],
                        gradient: kGradient,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Web Development', 0.60, '\$8,500', kPrimary),
      ('Mobile Dev', 0.28, '\$4,000', kSecondary),
      ('UI/UX Design', 0.10, '\$1,500', kWarning),
      ('Content Writing', 0.02, '\$500', kPurple),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By Category',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: kText)),
          const SizedBox(height: 16),
          ...categories.map((c) => _CategoryRow(
              label: c.$1,
              progress: c.$2,
              value: c.$3,
              color: c.$4)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String label, value;
  final double progress;
  final Color color;

  const _CategoryRow(
      {required this.label,
        required this.progress,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: kText)),
              ]),
              Row(children: [
                Text('${(progress * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                        color: kSubText, fontSize: 11)),
                const SizedBox(width: 8),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: kText)),
              ]),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (_, val, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: val,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectEarningsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final projEarnings = [
      ('E-commerce Dev', 'Web Development', '\$5,000'),
      ('Mobile App', 'Mobile Dev', '\$3,500'),
      ('Dashboard UI', 'UI/UX Design', '\$3,200'),
      ('API Integration', 'Web Development', '\$1,800'),
      ('Logo Design', 'UI/UX Design', '\$500'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By Project',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: kText)),
          const SizedBox(height: 12),
          ...projEarnings.asMap().entries.map((e) {
            final p = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: kBg, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: kGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('${e.key + 1}',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.$1,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: kText)),
                      Text(p.$2,
                          style: GoogleFonts.poppins(
                              color: kSubText, fontSize: 11)),
                    ],
                  ),
                ),
                Text(p.$3,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: kPrimary,
                        fontSize: 14)),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REUSABLE BUTTONS
// ─────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: kPrimary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimary),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ),
      ),
    );
  }
}