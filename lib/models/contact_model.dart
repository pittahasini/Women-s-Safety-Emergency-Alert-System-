import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 0)
class ContactModel extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  ContactModel({
    required this.name,
    required this.phone,
  });
}