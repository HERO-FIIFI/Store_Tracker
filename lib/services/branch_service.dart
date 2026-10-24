import 'package:store_tracker/services/services.dart';

class BranchService {
  final Set<String> _branches = {};
  String _currentBranchId = 'default';
  bool _initialized = false;

  /// Load branches from Hive storage into memory
  void _loadFromStorage() {
    if (_initialized) return;
    final branches = storageService.getAllBranches();
    if (branches.isEmpty) {
      // Ensure default branch exists
      _branches.add('default');
      storageService.saveBranch('default');
    } else {
      _branches.addAll(branches);
    }
    _initialized = true;
  }

  String get currentBranchId {
    _loadFromStorage();
    return _currentBranchId;
  }

  List<String> list() {
    _loadFromStorage();
    return _branches.toList(growable: false)..sort();
  }

  void addBranch(String id) {
    _loadFromStorage();
    if (id.trim().isEmpty) return;
    _branches.add(id.trim());
    // Persist to Hive
    storageService.saveBranch(id.trim());
  }

  bool switchBranch(String id) {
    _loadFromStorage();
    if (_branches.contains(id)) {
      _currentBranchId = id;
      return true;
    }
    return false;
  }
}


