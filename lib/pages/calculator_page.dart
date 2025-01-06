import 'dart:math' as math; // For pow, etc.
import 'package:flutter/material.dart';
import 'package:store_responsive_dashboard/constaints.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // TWO input fields: length & width for potential area calculation
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController  = TextEditingController();

  // Drop-down selections
  String _selectedFromUnit = 'cm';
  String _selectedToUnit   = 'cm^2';

  // Conversion result to display
  String _resultText = '';

  // We keep both linear and area units, removing m^3 per your request. 
  // We add cm^2 specifically.
  final Map<String, dynamic> _unitsConfig = {
    'inch': {
      'label': 'Inch',
      'ratio': 1.0,         // 1 inch as our base
      'dimension': 1,       // dimension=1 => linear
    },
    'cm': {
      'label': 'Centimeter',
      'ratio': 2.54,        // 1 inch = 2.54 cm
      'dimension': 1,
    },
    'm': {
      'label': 'Meter',
      'ratio': 0.0254,      // 1 inch = 0.0254 m
      'dimension': 1,
    },
    'cm^2': {
      'label': 'Square Centimeter',
      'ratio': 6.4516,      // 1 in^2 = 6.4516 cm^2
      'dimension': 2,       // dimension=2 => area
    },
    'm^2': {
      'label': 'Square Meter',
      'ratio': 0.00064516,  // 1 in^2 = 0.00064516 m^2
      'dimension': 2,
    },
  };

  /// Conversion function that unifies everything in inches or inches^2, then re-applies the ratio to the target unit.
  double _convertValue(double inputValue, String fromUnit, String toUnit) {
    final fromDef = _unitsConfig[fromUnit];
    final toDef   = _unitsConfig[toUnit];
    if (fromDef == null || toDef == null) return 0.0;

    final fromRatio = fromDef['ratio']     as double;
    final toRatio   = toDef['ratio']       as double;
    final fromDim   = fromDef['dimension'] as int;  // 1 or 2
    final toDim     = toDef['dimension']   as int;  // 1 or 2

    // STEP 1: Convert inputValue from [fromUnit^dimension] → inch^dimension
    final double inInches = inputValue * (1.0 / math.pow(fromRatio, fromDim));

    // STEP 2: Convert inch^dimension → [toUnit^dimension]
    final double outValue = inInches * math.pow(toRatio, toDim);

    return outValue;
  }

  /// The "Convert" button logic
  void _handleConvert() {
    final rawLength = _lengthController.text.trim();
    final rawWidth  = _widthController.text.trim();

    // If both empty, bail
    if (rawLength.isEmpty && rawWidth.isEmpty) {
      setState(() => _resultText = 'Please enter length or width.');
      return;
    }

    // Parse length & width; default to 0 if blank
    final lengthValue = double.tryParse(rawLength) ?? 0.0;
    final widthValue  = double.tryParse(rawWidth)  ?? 0.0;

    final fromDef = _unitsConfig[_selectedFromUnit];
    final toDef   = _unitsConfig[_selectedToUnit];
    if (fromDef == null || toDef == null) {
      setState(() => _resultText = 'Invalid units selected.');
      return;
    }

    final fromDim = fromDef['dimension'] as int;
    final toDim   = toDef['dimension']   as int;

    // 1) If fromDim == toDim == 1 => linear => length only
    if (fromDim == 1 && toDim == 1) {
      if (lengthValue <= 0.0) {
        setState(() => _resultText = 'Please enter a positive length for linear conversion.');
        return;
      }
      // Standard ratio-based linear conversion
      final result = _convertValue(lengthValue, _selectedFromUnit, _selectedToUnit);
      setState(() {
        _resultText = '$lengthValue $_selectedFromUnit = '
            '${result.toStringAsFixed(5)} $_selectedToUnit';
      });
    }

    // 2) If fromDim == toDim == 2 => area => we do length * width in from-unit^2, then ratio-based
    else if (fromDim == 2 && toDim == 2) {
      // we treat length & width as from-unit linear values => area => convert that area => new area
      if (lengthValue <= 0.0 || widthValue <= 0.0) {
        setState(() => _resultText = 'For area conversions, please enter both length & width.');
        return;
      }
      final areaInFromUnit = lengthValue * widthValue; // e.g. 2 x 3 cm^2 => 6 cm^2
      final result = _convertValue(areaInFromUnit, _selectedFromUnit, _selectedToUnit);
      setState(() {
        _resultText = '${lengthValue} x $widthValue $_selectedFromUnit^2 = '
            '${result.toStringAsFixed(5)} $_selectedToUnit';
      });
    }

    // 3) If fromDim=1 & toDim=2: possibly same family => e.g. cm → cm^2
    else if (fromDim == 1 && toDim == 2) {
      // If "same name prefix" (inch->inch^2, cm->cm^2, m->m^2) => direct approach:
      final fromKey = _selectedFromUnit.replaceAll('^2',''); // e.g. 'cm'
      final toKey   = _selectedToUnit.replaceAll('^2','');   // e.g. 'cm'
      // If same prefix => multiply length * width directly in that unit
      if (fromKey == toKey) {
        if (lengthValue <= 0.0 || widthValue <= 0.0) {
          setState(() => _resultText = 'For area in $fromKey^2, please enter length & width.');
          return;
        }
        final area = lengthValue * widthValue;  // e.g. 60 x 30 => 1800 cm^2
        setState(() {
          _resultText = '${lengthValue} x $widthValue $fromKey^2 = $area $_selectedToUnit';
        });
      } else {
        // Cross-unit scenario: inch -> cm^2, etc.
        if (lengthValue <= 0.0 || widthValue <= 0.0) {
          setState(() => _resultText = 'For cross-unit area, please enter length & width.');
          return;
        }
        // Step 1: compute area in fromUnit^2
        final areaInFromUnit = lengthValue * widthValue; 
        // Step 2: ratio-based approach
        final result = _convertValue(areaInFromUnit, _selectedFromUnit, _selectedToUnit);
        setState(() {
          _resultText = '${lengthValue} x $widthValue $_selectedFromUnit^2 = '
              '${result.toStringAsFixed(5)} $_selectedToUnit';
        });
      }
    }

    // 4) If fromDim=2 & toDim=1 => user tries to convert area -> linear? 
    else if (fromDim == 2 && toDim == 1) {
      setState(() => _resultText = 'Converting area to linear is not supported here.');
    }

    else {
      setState(() => _resultText = 'Unsupported dimension scenario.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Converter Calculator'),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(componentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unit Conversion',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Input Fields for length & width
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _lengthController,
                    labelText: 'Length',
                    hintText: 'e.g. 60',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _widthController,
                    labelText: 'Width',
                    hintText: 'e.g. 30',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // From unit & to unit
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'From Unit',
                    value: _selectedFromUnit,
                    onChanged: (String? newValue) {
                      setState(() => _selectedFromUnit = newValue ?? 'inch');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'To Unit',
                    value: _selectedToUnit,
                    onChanged: (String? newValue) {
                      setState(() => _selectedToUnit = newValue ?? 'cm');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Convert Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _handleConvert,
              child: const Text(
                'Convert',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Show Result
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _resultText.isEmpty
                    ? 'Result will appear here...'
                    : _resultText,
                style: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 40),
            const Divider(thickness: 2),
            const Text(
              'Conversion Info',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• If you select linear units (e.g. cm → inch), you can fill out only Length.\n'
              '• If you want area (e.g. cm → cm^2, inch → m^2, etc.), fill both Length & Width.\n'
              '• For same-family linear → area (like cm → cm^2), we do length × width directly.\n'
              '• For cross-family (like inch → cm^2), we unify in inch^2 then convert.\n',
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable method to build a labeled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Builds a nice dropdown for the units
  Widget _buildDropdown({
    required String label,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            underline: const SizedBox(),
            items: _unitsConfig.keys.map((unitKey) {
              return DropdownMenuItem<String>(
                value: unitKey,
                child: Text(unitKey),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
