enum UserRole { admin, staff, accountant }

class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  String currentBranchId = 'default';
  UserRole currentRole = UserRole.admin;
}


