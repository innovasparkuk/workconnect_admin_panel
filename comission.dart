import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumCommissionSettings extends StatefulWidget {
  @override
  _PremiumCommissionSettingsState createState() => _PremiumCommissionSettingsState();
}

class _PremiumCommissionSettingsState extends State<PremiumCommissionSettings> {
  CommissionModel _selectedModel = CommissionModel.percentage;
  double _commissionRate = 10.0;
  double _fixedAmount = 5.0;
  double _tier1Limit = 1000.0;
  double _tier1Rate = 5.0;
  double _tier2Rate = 7.0;
  bool _isEnabled = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Color(0xFF0066FF),
        body: Column(
          children: [
            // Fixed Header - Won't scroll
            _buildHeader(),
            // Scrollable Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _buildScrollableContent(), // ✅ updated scroll view below
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              radius: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commission Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Configure your commission structure',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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

  // ✅ FIXED SCROLLABLE CONTENT
  Widget _buildScrollableContent() {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            SizedBox(height: 12),
            _buildCommissionModelSelector(),
            SizedBox(height: 12),
            _buildCommissionSettings(),
            SizedBox(height: 16),
            _buildActionButtons(),
            SizedBox(height: 24), // ✅ added bottom space to prevent overflow
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0066FF).withOpacity(0.08),
            Color(0xFF00C853).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0066FF).withOpacity(0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isEnabled ? Color(0xFF00C853) : Color(0xFF1A1A1A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isEnabled ? Icons.rocket_launch : Icons.pause,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commission System',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    _isEnabled ? 'System is live & active' : 'System paused',
                    style: TextStyle(
                      color: _isEnabled ? Color(0xFF00C853) : Color(0xFF1A1A1A),
                      fontSize: 11,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
                activeColor: Color(0xFF00C853),
                activeTrackColor: Color(0xFF00C853).withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED HEIGHT AND SHRINKWRAP HERE
  Widget _buildCommissionModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Commission Model',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              fontFamily: 'Poppins',
            ),
          ),
        ),
        SizedBox(
          height: 80, // increased from 65 to 80
          child: ListView(
            shrinkWrap: true, // ✅ added shrinkWrap
            scrollDirection: Axis.horizontal,
            children: CommissionModel.values.map((model) {
              return _buildModelCard(model);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModelCard(CommissionModel model) {
    final isSelected = _selectedModel == model;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModel = model;
        });
      },
      child: Container(
        width: 95,
        margin: EdgeInsets.only(right: 6),
        child: Card(
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? Color(0xFF0066FF) : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Color(0xFF0066FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getModelIcon(model),
                    color: Color(0xFF0066FF),
                    size: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _getShortName(model),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Color(0xFF0066FF),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Configuration',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildModelSpecificSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSpecificSettings() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUltraCompactSlider(
          label: _getMainSliderLabel(),
          value: _getMainSliderValue(),
          min: _getMainSliderMin(),
          max: _getMainSliderMax(),
          unit: _getMainSliderUnit(),
          onChanged: _handleMainSliderChange,
        ),
        if (_selectedModel == CommissionModel.tiered) ..._buildTieredSettings(),
        if (_selectedModel == CommissionModel.hybrid) ..._buildHybridSettings(),
        SizedBox(height: 10),
        _buildUltraCompactPreview(),
      ],
    );
  }

  List<Widget> _buildTieredSettings() {
    return [
      SizedBox(height: 10),
      _buildUltraCompactSlider(
        label: 'Tier 1 Limit',
        value: _tier1Limit,
        min: 100,
        max: 5000,
        unit: '\$',
        onChanged: (value) => setState(() => _tier1Limit = value),
      ),
      SizedBox(height: 10),
      _buildUltraCompactSlider(
        label: 'Tier 2 Rate',
        value: _tier2Rate,
        min: 0,
        max: 20,
        unit: '%',
        onChanged: (value) => setState(() => _tier2Rate = value),
      ),
    ];
  }

  List<Widget> _buildHybridSettings() {
    return [
      SizedBox(height: 10),
      _buildUltraCompactSlider(
        label: 'Fixed Fee',
        value: _fixedAmount,
        min: 0,
        max: 10,
        unit: '\$',
        onChanged: (value) => setState(() => _fixedAmount = value),
      ),
    ];
  }

  Widget _buildUltraCompactSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                  fontSize: 11,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Color(0xFF0066FF),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}$unit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2.5,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
            activeTrackColor: Color(0xFF0066FF),
            inactiveTrackColor: Color(0xFF0066FF).withOpacity(0.15),
            thumbColor: Color(0xFF0066FF),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildUltraCompactPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF0066FF).withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF0066FF).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            color: Color(0xFF0066FF),
            size: 12,
          ),
          SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  _getShortPreviewText(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066FF),
                  ),
                  maxLines: 2,
                ),
              ],
            ),

        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

           OutlinedButton(
            onPressed: _resetSettings,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(150, 40),
              padding: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Color(0xFF0066FF)),
            ),
            child: Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFF0066FF),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),

        SizedBox(width: 10),

          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(150, 40),
              backgroundColor: Color(0xFF0066FF),
              padding: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 1,
            ),
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),

      ],
    );
  }

  // Helper Methods
  IconData _getModelIcon(CommissionModel model) {
    switch (model) {
      case CommissionModel.percentage:
        return Icons.percent;
      case CommissionModel.fixed:
        return Icons.attach_money;
      case CommissionModel.tiered:
        return Icons.trending_up;
      case CommissionModel.hybrid:
        return Icons.blur_circular;
    }
  }

  String _getShortName(CommissionModel model) {
    switch (model) {
      case CommissionModel.percentage:
        return '% Rate';
      case CommissionModel.fixed:
        return 'Fixed';
      case CommissionModel.tiered:
        return 'Tiered';
      case CommissionModel.hybrid:
        return 'Hybrid';
    }
  }

  String _getShortPreviewText() {
    switch (_selectedModel) {
      case CommissionModel.percentage:
        return '\$100 → \$${(100 * _commissionRate / 100).toStringAsFixed(1)}';
      case CommissionModel.fixed:
        return 'Sale → \$$_fixedAmount';
      case CommissionModel.tiered:
        return '\$1500 → \$${(_tier1Limit * _tier1Rate / 100 + 500 * _tier2Rate / 100).toStringAsFixed(1)}';
      case CommissionModel.hybrid:
        return '\$100 → \$${(100 * _commissionRate / 100 + _fixedAmount).toStringAsFixed(1)}';
    }
  }

  String _getMainSliderLabel() {
    switch (_selectedModel) {
      case CommissionModel.percentage:
        return 'Rate %';
      case CommissionModel.fixed:
        return 'Amount \$';
      case CommissionModel.tiered:
        return 'Tier 1 %';
      case CommissionModel.hybrid:
        return 'Rate %';
    }
  }

  double _getMainSliderValue() {
    switch (_selectedModel) {
      case CommissionModel.percentage:
        return _commissionRate;
      case CommissionModel.fixed:
        return _fixedAmount;
      case CommissionModel.tiered:
        return _tier1Rate;
      case CommissionModel.hybrid:
        return _commissionRate;
    }
  }

  double _getMainSliderMin() => 0;

  double _getMainSliderMax() {
    switch (_selectedModel) {
      case CommissionModel.percentage:
        return 50;
      case CommissionModel.fixed:
        return 50;
      case CommissionModel.tiered:
        return 20;
      case CommissionModel.hybrid:
        return 20;
    }
  }

  String _getMainSliderUnit() {
    switch (_selectedModel) {
      case CommissionModel.percentage:
        return '%';
      case CommissionModel.fixed:
        return '\$';
      case CommissionModel.tiered:
        return '%';
      case CommissionModel.hybrid:
        return '%';
    }
  }

  void _handleMainSliderChange(double value) {
    setState(() {
      switch (_selectedModel) {
        case CommissionModel.percentage:
          _commissionRate = value;
          break;
        case CommissionModel.fixed:
          _fixedAmount = value;
          break;
        case CommissionModel.tiered:
          _tier1Rate = value;
          break;
        case CommissionModel.hybrid:
          _commissionRate = value;
          break;
      }
    });
  }

  void _resetSettings() {
    setState(() {
      _commissionRate = 10.0;
      _fixedAmount = 5.0;
      _tier1Limit = 1000.0;
      _tier1Rate = 5.0;
      _tier2Rate = 7.0;
    });
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

enum CommissionModel {
  percentage,
  fixed,
  tiered,
  hybrid,
}
