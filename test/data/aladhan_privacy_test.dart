import 'package:ezanai/data/models/city.dart';
import 'package:ezanai/data/prayer/aladhan_api_source.dart';
import 'package:ezanai/data/prayer/prayer_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// KVKK veri minimizasyonu: yedek vakit servisine tam koordinat gönderilmez.
void main() {
  test('AlAdhan isteğinde koordinat 2 ondalığa yuvarlanır', () async {
    Uri? captured;
    final MockClient client = MockClient((http.Request request) async {
      captured = request.url;
      // Ağ hatasını taklit et; asıl ölçtüğümüz istek adresidir.
      return http.Response('{}', 500);
    });

    final AladhanApiSource source = AladhanApiSource(client: client);
    const UserLocation location = UserLocation(
      mode: LocationMode.gps,
      latitude: 41.00823456,
      longitude: 28.9784321,
    );

    try {
      await source.fetchDay(
        location: location,
        date: DateTime(2026, 11, 12),
        method: CalculationMethod.diyanet,
      );
    } catch (_) {
      // Beklenen: 500 yanıtı istisna üretir.
    }

    expect(captured, isNotNull);
    expect(captured!.queryParameters['latitude'], '41.01');
    expect(captured!.queryParameters['longitude'], '28.98');
  });

  test('AlAdhan aralık isteğinde de koordinat yuvarlanır', () async {
    Uri? captured;
    final MockClient client = MockClient((http.Request request) async {
      captured = request.url;
      return http.Response('{}', 500);
    });

    final AladhanApiSource source = AladhanApiSource(client: client);
    const UserLocation location = UserLocation(
      mode: LocationMode.manual,
      latitude: 39.9334567,
      longitude: 32.8597412,
    );

    try {
      await source.fetchRange(
        location: location,
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 30),
        method: CalculationMethod.diyanet,
      );
    } catch (_) {
      // Beklenen.
    }

    expect(captured, isNotNull);
    expect(captured!.queryParameters['latitude'], '39.93');
    expect(captured!.queryParameters['longitude'], '32.86');
  });
}
