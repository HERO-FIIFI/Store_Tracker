import 'package:flutter/material.dart';
import 'package:store_tracker/services/services.dart';
import 'package:store_tracker/services/app_settings.dart';
import 'package:store_tracker/services/premium_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPinEnabled = false;
  bool _isLoading = true;
  bool _isPremium = false;
  final TextEditingController _newBranchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _newBranchController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await premiumService.initialize();
    final pinEnabled = await pinLockService.isPinEnabled();
    setState(() {
      _isPinEnabled = pinEnabled;
      _isPremium = premiumService.isPremium;
      _isLoading = false;
    });
  }

  Future<void> _showSetPinDialog() async {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'Enter PIN (4-6 digits)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final pin = pinController.text;
              final confirmPin = confirmPinController.text;

              if (pin.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be at least 4 digits')),
                );
                return;
              }

              if (pin != confirmPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match')),
                );
                return;
              }

              await pinLockService.setPin(pin);
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isPinEnabled = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN enabled successfully')),
        );
      }
    }
  }

  Future<bool> _showVerifyPinDialog() async {
    final pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify PIN'),
        content: TextField(
          controller: pinController,
          decoration: const InputDecoration(
            labelText: 'Enter PIN',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final isValid = await pinLockService.verifyPin(pinController.text);
              if (isValid) {
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid PIN')),
                  );
                }
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _togglePin(bool value) async {
    if (value) {
      // Enabling PIN
      final hasPin = await pinLockService.hasPin();
      if (hasPin) {
        await pinLockService.enablePin();
        setState(() {
          _isPinEnabled = true;
        });
      } else {
        await _showSetPinDialog();
      }
    } else {
      // Disabling PIN - verify first
      final verified = await _showVerifyPinDialog();
      if (verified) {
        await pinLockService.disablePin();
        setState(() {
          _isPinEnabled = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN disabled')),
          );
        }
      }
    }
  }

  Future<void> _showAddBranchDialog() async {
    _newBranchController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Branch'),
        content: TextField(
          controller: _newBranchController,
          decoration: const InputDecoration(
            labelText: 'Branch ID/Name',
            border: OutlineInputBorder(),
            hintText: 'e.g., branch-2, downtown, etc.',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final branchId = _newBranchController.text.trim();
              if (branchId.isNotEmpty) {
                branchService.addBranch(branchId);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Branch "$branchId" added')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(String type, String format) async {
    try {
      if (type == 'transactions') {
        final transactions = transactionService.list();
        await exportService.exportTransactionsToFile(
          transactions,
          format: format,
        );
      } else if (type == 'products') {
        final products = productService.list();
        await exportService.exportProductsToFile(
          products,
          format: format,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.toUpperCase()} exported as ${format.toUpperCase()}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importDataFromJson(String type) async {
    final jsonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import $type from JSON'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: jsonController,
            decoration: InputDecoration(
              labelText: 'Paste JSON here',
              border: const OutlineInputBorder(),
              hintText: 'Paste the exported JSON content',
            ),
            maxLines: 10,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final jsonString = jsonController.text.trim();
                if (jsonString.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please paste JSON content')),
                  );
                  return;
                }

                int importedCount = 0;

                if (type == 'transactions') {
                  final transactions = exportService.transactionsFromJson(jsonString);
                  for (final transaction in transactions) {
                    transactionService.upsert(transaction);
                    importedCount++;
                  }
                } else if (type == 'products') {
                  final products = exportService.productsFromJson(jsonString);
                  for (final product in products) {
                    productService.upsert(product);
                    importedCount++;
                  }
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully imported $importedCount $type')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: $e')),
                  );
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export $type'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData(type, 'json');
            },
            child: const Text('JSON'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData(type, 'csv');
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final branches = branchService.list();
    final currentBranch = appSettings.currentBranchId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Branch Settings Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Branch Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Current Branch'),
            subtitle: DropdownButton<String>(
              value: currentBranch,
              isExpanded: true,
              items: branches.map((branch) {
                return DropdownMenuItem(
                  value: branch,
                  child: Text(branch),
                );
              }).toList(),
              onChanged: (String? newBranch) {
                if (newBranch != null) {
                  setState(() {
                    appSettings.currentBranchId = newBranch;
                    branchService.switchBranch(newBranch);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Switched to branch: $newBranch')),
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_business),
            title: const Text('Add New Branch'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAddBranchDialog,
          ),
          const Divider(),

          // User Role Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'User Role',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Select Role'),
            subtitle: DropdownButton<UserRole>(
              value: appSettings.currentRole,
              isExpanded: true,
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(_getRoleName(role)),
                );
              }).toList(),
              onChanged: (UserRole? newRole) {
                if (newRole != null) {
                  setState(() {
                    appSettings.currentRole = newRole;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Role changed to: ${_getRoleName(newRole)}')),
                  );
                }
              },
            ),
          ),
          const Divider(),

          // Security Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Security',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lock),
            title: const Text('PIN Lock'),
            subtitle: Text(_isPinEnabled ? 'Enabled' : 'Disabled'),
            value: _isPinEnabled,
            onChanged: _togglePin,
          ),
          if (_isPinEnabled)
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('Change PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final verified = await _showVerifyPinDialog();
                if (verified && mounted) {
                  await _showSetPinDialog();
                }
              },
            ),
          const Divider(),

          // Backup & Export Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Backup & Export',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.green),
            title: const Text('Export Products'),
            subtitle: const Text('Save products to JSON or CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportDialog('products'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.green),
            title: const Text('Export Transactions'),
            subtitle: const Text('Save transactions to JSON or CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportDialog('transactions'),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.orange),
            title: const Text('Import Products'),
            subtitle: const Text('Load products from JSON'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _importDataFromJson('products'),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.orange),
            title: const Text('Import Transactions'),
            subtitle: const Text('Load transactions from JSON'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _importDataFromJson('transactions'),
          ),
          const Divider(),

          // App Info Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Staff';
      case UserRole.accountant:
        return 'Accountant';
    }
  }
}


