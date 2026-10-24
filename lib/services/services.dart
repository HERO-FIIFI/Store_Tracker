import 'package:store_tracker/services/product_service.dart';
import 'package:store_tracker/services/transaction_service.dart';
import 'package:store_tracker/services/branch_service.dart';
import 'package:store_tracker/services/app_settings.dart';
import 'package:store_tracker/services/export_service.dart';
import 'package:store_tracker/services/pin_lock_service.dart';
import 'package:store_tracker/services/premium_service.dart';
import 'package:store_tracker/services/storage_service.dart';

// Simple global singletons for in-memory services
final StorageService storageService = StorageService();
final BranchService branchService = BranchService();
final ProductService productService = ProductService();
final TransactionService transactionService = TransactionService();
final AppSettings appSettings = AppSettings.instance;
final ExportService exportService = ExportService();
final PinLockService pinLockService = PinLockService();
final PremiumService premiumService = PremiumService();


