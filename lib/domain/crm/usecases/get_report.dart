import '../repositories/crm_repository.dart';

class GetCrmReport {
  GetCrmReport(this._repository);

  final CrmRepository _repository;

  Future<Map<String, dynamic>> call({
    String? start,
    String? end,
    String? startTime,
    String? endTime,
  }) {
    return _repository.getReport(
      start: start,
      end: end,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
