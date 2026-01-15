import 'package:core/core.dart';
import 'package:flutter_riverpod/legacy.dart';

final sessionProvider = StateProvider<AppUser?>((ref) => null);
final branchProvider = StateProvider<Branch?>((ref) => null);
