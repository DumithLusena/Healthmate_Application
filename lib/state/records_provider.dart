import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/stats.dart';
import '../core/validators.dart';
import '../data/health_repository.dart';
import '../models/health_record.dart';

class RecordsProvider extends ChangeNotifier {
  RecordsProvider(this._repo);
  final HealthRepository _repo;

  List<HealthRecord> records = [];
  List<HealthRecord> visible = [];
  RecordQuery query = const RecordQuery();
  bool loading = true;
  String? error;

  Future<void> load() async {
    try {
      records = await _repo.getAll();
      visible = await _repo.getAll(query);
      error = null;
    } catch (_) {
      error = 'Could not load your records. Please try again.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> setQuery(RecordQuery q) async {
    query = q;
    await load();
  }

  Future<HealthRecord?> byId(int id) => _repo.getById(id);
  Future<HealthRecord?> byDate(String date) => _repo.getByDate(date);

  Future<String?> save(HealthRecord r) async {
    try {
      r.id == null ? await _repo.insert(r) : await _repo.update(r);
      await load();
      return null;
    } on DuplicateDateException catch (e) {
      return 'A record for ${e.date} already exists.';
    } catch (_) {
      return 'Could not save the record. Your entries are kept - please try again.';
    }
  }

  Future<String?> remove(int id) async {
    try {
      await _repo.delete(id);
      await load();
      return null;
    } catch (_) {
      return 'Could not delete the record.';
    }
  }

  Future<String?> addWaterToday(int ml) async {
    try {
      final date = fmtDate(DateTime.now());
      final today = await _repo.getByDate(date);
      if (today == null) {
        await _repo.insert(HealthRecord(date: date, steps: 0, calories: 0, water: min(ml, Validators.maxWater)));
      } else {
        await _repo.update(HealthRecord(
          id: today.id,
          date: date,
          steps: today.steps,
          calories: today.calories,
          water: min(today.water + ml, Validators.maxWater),
        ));
      }
      await load();
      return null;
    } catch (_) {
      return 'Could not add water.';
    }
  }

  Future<String?> loadDemoData() async {
    try {
      await _repo.seedDemo();
      await load();
      return null;
    } catch (_) {
      return 'Could not load sample data.';
    }
  }
}
