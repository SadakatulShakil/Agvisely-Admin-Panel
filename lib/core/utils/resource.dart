import 'package:get/get.dart';

import '../network/api_exception.dart';

enum LoadStatus { loading, success, error }

/// Reactive holder for one async load: status + last good data + error.
///
/// Keeps the previous data while reloading (so tables don't flash empty
/// when a filter changes) and ignores responses that arrive after a newer
/// request was started.
class Resource<T> {
  final status = LoadStatus.loading.obs;
  final data = Rxn<T>();
  final error = RxnString();

  int _seq = 0;

  bool get isLoading => status.value == LoadStatus.loading;
  bool get hasData => data.value != null;

  /// Returns true when this request's result was applied.
  Future<bool> load(Future<T> Function() task) async {
    final seq = ++_seq;
    status.value = LoadStatus.loading;
    error.value = null;
    try {
      final result = await task();
      if (seq != _seq) return false;
      data.value = result;
      status.value = LoadStatus.success;
      return true;
    } catch (e) {
      if (seq != _seq) return false;
      error.value = ApiException.messageOf(e);
      status.value = LoadStatus.error;
      return false;
    }
  }

  /// Local update after a successful mutation (no reload).
  void patch(T Function(T current) update) {
    final current = data.value;
    if (current != null) data.value = update(current);
  }
}
