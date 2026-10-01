// Testes do calculo e da exibicao de distancias.
import 'package:flutter_test/flutter_test.dart';
import 'package:safeneighbor/data/alertas_exemplo.dart';
import 'package:safeneighbor/services/servico_localizacao.dart';

void main() {
  test('calcula distancia geografica em quilometros', () {
    const origin = DeviceCoordinates(latitude: 0, longitude: 0);

    final distance = DeviceLocationService.distanceInKm(origin, 0, 1);

    expect(distance, closeTo(111.3, 0.2));
  });

  test('formata distancia em metros e quilometros', () {
    expect(seedAlerts.first.withDistance(0.42).distanceLabel, '420 m');
    expect(seedAlerts.first.withDistance(1.25).distanceLabel, '1,3 km');
  });
}
