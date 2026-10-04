import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Ağ durumu izleyicisi.
///
/// Çevrimdışı durumda uygulama önbellek ve yerel hesaplamaya düşer.
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged.map(_hasConnection);

  static bool _hasConnection(List<ConnectivityResult> results) => results.any(
        (ConnectivityResult r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet ||
            r == ConnectivityResult.vpn,
      );

  /// İlk durumu okur ve akışa abone olur.
  Future<void> start(void Function(bool online) onChanged) async {
    try {
      _isOnline = _hasConnection(await _connectivity.checkConnectivity());
      onChanged(_isOnline);
    } catch (_) {
      _isOnline = true;
    }
  }

  StreamSubscription<bool> watch(void Function(bool online) onChanged) =>
      onStatusChange.listen((bool online) {
        _isOnline = online;
        onChanged(online);
      });
}
