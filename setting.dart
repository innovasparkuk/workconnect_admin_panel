import 'package:flutter/material.dart';

class AdminSettingsPage extends StatefulWidget {
  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Settings state
  String _platformName = 'WorkConnect';
  double _commissionRate = 10.0;
  String _paymentGateway = 'stripe';
  String _currency = 'USD';
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _autoApproveJobs = false;
  bool _requireKYC = true;
  bool _isEditingName = false;

  // Primary color for the app
  final Color _primaryColor = Color(0xFF0066FF);

  // Company logo URL - yahan ap apna logo URL daal sakti hain
  final String _companyLogoUrl = 'https://copilot.microsoft.com/th/id/BCO.0e7a73eb-3d8c-4512-aba9-9747363f2e01.png';

  // Commission settings
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _platformNameController = TextEditingController();
  final FocusNode _platformNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _commissionController.text = _commissionRate.toString();
    _platformNameController.text = _platformName;
  }

  @override
  void dispose() {
    _commissionController.dispose();
    _platformNameController.dispose();
    _platformNameFocusNode.dispose();
    super.dispose();
  }

  void _startEditingName() {
    setState(() {
      _isEditingName = true;
    });
    // Focus automatically on the text field after a small delay
    Future.delayed(Duration(milliseconds: 100), () {
      _platformNameFocusNode.requestFocus();
    });
  }

  void _saveName() {
    setState(() {
      _isEditingName = false;
      _platformName = _platformNameController.text;
    });
    // Remove focus when done editing
    _platformNameFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Platform Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Logo and Name Section - Naya design
                    _buildCompanyIdentitySection(isMobile),

                    SizedBox(height: 20),

                    // Commission Settings Card
                    _buildCommissionCard(),

                    SizedBox(height: 20),

                    // Payment Settings Card
                    _buildPaymentCard(),

                    SizedBox(height: 20),

                    // Platform Settings Card
                    _buildSettingsCard(
                      title: 'Platform Settings',
                      icon: Icons.settings,
                      children: [
                        _buildSwitchSetting(
                          title: 'Auto Approve Jobs',
                          subtitle: 'Jobs will be automatically approved without manual review',
                          value: _autoApproveJobs,
                          onChanged: (value) => setState(() => _autoApproveJobs = value),
                          icon: Icons.work,
                        ),
                        SizedBox(height: 16),
                        _buildSwitchSetting(
                          title: 'Require KYC Verification',
                          subtitle: 'Users must complete KYC verification to withdraw funds',
                          value: _requireKYC,
                          onChanged: (value) => setState(() => _requireKYC = value),
                          icon: Icons.verified_user,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Notification Settings Card
                    _buildSettingsCard(
                      title: 'Notification Preferences',
                      icon: Icons.notifications,
                      children: [
                        _buildSwitchSetting(
                          title: 'Email Notifications',
                          subtitle: 'Receive important updates via email',
                          value: _emailNotifications,
                          onChanged: (value) => setState(() => _emailNotifications = value),
                          icon: Icons.email,
                        ),
                        SizedBox(height: 16),
                        _buildSwitchSetting(
                          title: 'Push Notifications',
                          subtitle: 'Get instant notifications on your device',
                          value: _pushNotifications,
                          onChanged: (value) => setState(() => _pushNotifications = value),
                          icon: Icons.notification_important,
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Action Buttons
                    _buildActionButtons(isMobile),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyIdentitySection(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              // Company Logo - Center main bara circle
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primaryColor.withOpacity(0.2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    _companyLogoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.business,
                          size: 50,
                          color: _primaryColor,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: _primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Company Name with Edit Functionality
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isEditingName ? _primaryColor : Colors.grey.shade300,
                        width: _isEditingName ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _isEditingName
                              ? TextFormField(
                            controller: _platformNameController,
                            focusNode: _platformNameFocusNode,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                              fontFamily: 'Roboto',
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Enter platform name',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          )
                              : Text(
                            _platformName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 12),
                        _isEditingName
                            ? GestureDetector(
                          onTap: _saveName,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        )
                            : GestureDetector(
                          onTap: _startEditingName,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: _primaryColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Platform Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Platform Active',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Additional Info
              Text(
                'Manage your platform identity and branding',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: _primaryColor,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.attach_money,
                      color: _primaryColor,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Commission & Fees',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 20),

              // Current Rate Display
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      _primaryColor.withOpacity(0.05),
                      _primaryColor.withOpacity(0.02)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryColor.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Commission Rate',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Applied to all transactions on the platform',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_commissionRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Slider and Input Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: _primaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Adjust Commission Rate',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Slider(
                                value: _commissionRate,
                                min: 0,
                                max: 30,
                                divisions: 30,
                                activeColor: _primaryColor,
                                inactiveColor: Colors.grey.shade300,
                                thumbColor: Colors.white,
                                label: '${_commissionRate.toStringAsFixed(1)}%',
                                onChanged: (value) {
                                  setState(() {
                                    _commissionRate = value;
                                    _commissionController.text = value.toStringAsFixed(1);
                                  });
                                },
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0%', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  Text('Standard', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
                                  Text('30%', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom Input',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                height: 50,
                                child: TextFormField(
                                  controller: _commissionController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    suffixText: '%',
                                    suffixStyle: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: _primaryColor, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      final rate = double.tryParse(value);
                                      if (rate != null && rate >= 0 && rate <= 30) {
                                        setState(() {
                                          _commissionRate = rate;
                                        });
                                      }
                                    }
                                  },
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
              SizedBox(height: 20),

              // Quick Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildCommissionChip('5% - Competitive', 5.0),
                      _buildCommissionChip('10% - Standard', 10.0),
                      _buildCommissionChip('15% - Premium', 15.0),
                      _buildCommissionChip('20% - Enterprise', 20.0),
                      _buildCommissionChip('25% - High Value', 25.0),
                      _buildCommissionChip('30% - Maximum', 30.0),
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

  Widget _buildCommissionChip(String label, double rate) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _commissionRate = rate;
          _commissionController.text = rate.toStringAsFixed(1);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _commissionRate == rate ? _primaryColor : _primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _commissionRate == rate ? _primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _commissionRate == rate ? Colors.white : _primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.payment,
                      color: _primaryColor,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Payment Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 20),

              // Payment Gateway Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: _primaryColor, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Payment Gateway',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose your preferred payment processor for handling transactions',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Payment Gateway Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3.5,
                    children: [
                      _buildPaymentOption(
                        'Stripe',
                        'Global payments with cards & more',
                        Icons.account_balance_wallet,
                        'stripe',
                      ),
                      _buildPaymentOption(
                        'PayPal',
                        'Digital wallet & global support',
                        Icons.payment,
                        'paypal',
                      ),
                      _buildPaymentOption(
                        'Razorpay',
                        'Leading solution for India',
                        Icons.currency_rupee,
                        'razorpay',
                      ),
                      _buildPaymentOption(
                        'Bank Transfer',
                        'Direct bank transfers',
                        Icons.account_balance,
                        'bank',
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Currency Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.currency_exchange, color: _primaryColor, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Default Currency',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Set the default currency for all platform transactions',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Currency Grid with Flags
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildCurrencyOptionWithFlag('USD', 'US Dollar', '\$', '🇺🇸'),
                      _buildCurrencyOptionWithFlag('EUR', 'Euro', '€', '🇪🇺'),
                      _buildCurrencyOptionWithFlag('GBP', 'British Pound', '£', '🇬🇧'),
                      _buildCurrencyOptionWithFlag('PKR', 'Pakistani Rupee', '₨', '🇵🇰'),
                      _buildCurrencyOptionWithFlag('INR', 'Indian Rupee', '₹', '🇮🇳'),
                      _buildCurrencyOptionWithFlag('AED', 'UAE Dirham', 'د.إ', '🇦🇪'),
                      _buildCurrencyOptionWithFlag('SAR', 'Saudi Riyal', '﷼', '🇸🇦'),
                      _buildCurrencyOptionWithFlag('CNY', 'Chinese Yuan', '¥', '🇨🇳'),
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

  Widget _buildPaymentOption(String name, String description, IconData icon, String value) {
    bool isSelected = _paymentGateway == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentGateway = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                size: 14,
                color: _primaryColor,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOptionWithFlag(String code, String name, String symbol, String flag) {
    bool isSelected = _currency == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currency = code;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag and Symbol
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  flag,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 4),
                Text(
                  symbol,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 2),
            Text(
              name,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primaryColor, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _primaryColor,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _resetToDefaults(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade400),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset to Defaults',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'Save Changes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  void _resetToDefaults() {
    setState(() {
      _platformName = 'WorkConnect';
      _platformNameController.text = _platformName;
      _commissionRate = 10.0;
      _paymentGateway = 'stripe';
      _currency = 'USD';
      _emailNotifications = true;
      _pushNotifications = true;
      _autoApproveJobs = false;
      _requireKYC = true;
      _isEditingName = false;
      _commissionController.text = _commissionRate.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings reset to defaults'),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      // Save settings logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Platform settings saved successfully!'),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Print saved settings (for demo)
      print('=== Platform Settings Saved ===');
      print('Platform Name: $_platformName');
      print('Commission Rate: $_commissionRate%');
      print('Payment Gateway: $_paymentGateway');
      print('Currency: $_currency');
      print('Auto Approve Jobs: $_autoApproveJobs');
      print('Require KYC: $_requireKYC');
    }
  }
}