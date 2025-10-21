import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/thought_dump_service.dart';
import '../models/thought_dump.dart';

// Service provider
final thoughtDumpServiceProvider = Provider<ThoughtDumpService>((ref) {
  return ThoughtDumpService();
});

// Current week thought dumps provider
final currentWeekThoughtDumpsProvider = FutureProvider.family<List<ThoughtDump>, String>((ref, userId) async {
  final service = ref.read(thoughtDumpServiceProvider);
  return service.getCurrentWeekThoughtDumps(userId);
});

// All thought dumps provider
final allThoughtDumpsProvider = FutureProvider.family<List<ThoughtDump>, String>((ref, userId) async {
  final service = ref.read(thoughtDumpServiceProvider);
  return service.getAllThoughtDumps(userId);
});

// Thought dumps for specific week provider
final thoughtDumpsForWeekProvider = FutureProvider.family<List<ThoughtDump>, ({String userId, int weekNumber})>((ref, params) async {
  final service = ref.read(thoughtDumpServiceProvider);
  return service.getThoughtDumpsForWeek(params.userId, params.weekNumber);
});

// Thought dumps in date range provider
final thoughtDumpsInDateRangeProvider = FutureProvider.family<List<ThoughtDump>, ({String userId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(thoughtDumpServiceProvider);
  return service.getThoughtDumpsInDateRange(params.userId, params.startDate, params.endDate);
});
