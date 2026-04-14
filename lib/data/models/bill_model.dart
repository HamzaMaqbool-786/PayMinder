import 'package:hive/hive.dart';
import '../../core/constants/app_hive_keys.dart';

part 'bill_model.g.dart';

@HiveType(typeId: HiveKeys.billTypeId)
class BillModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) double amount;
  @HiveField(3) DateTime dueDate;
  @HiveField(4) String category;
  @HiveField(5) bool isPaid;
  @HiveField(6) String remindBefore;
  @HiveField(7) String repeat;
  @HiveField(8) String? photoPath;
  @HiveField(9) DateTime createdAt;

  BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.isPaid = false,
    this.remindBefore = '1 day before',
    this.repeat = 'None',
    this.photoPath,
    required this.createdAt,
  });
}
