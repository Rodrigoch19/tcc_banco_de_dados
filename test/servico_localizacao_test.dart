// Testes da conversao de coordenadas em endereco.
import 'package:flutter_test/flutter_test.dart';
import 'package:safeneighbor/services/servico_localizacao.dart';

void main() {
  group('conversao de coordenadas para endereco', () {
    test('formata rua, numero, bairro e cidade', () {
      final address = DeviceLocationService.addressFromRemoteResponse({
        'address': {
          'road': 'Rua Santa Teresa',
          'house_number': '21',
          'suburb': 'Glicerio',
          'city': 'Sao Paulo',
        },
      });

      expect(address, 'Rua Santa Teresa, 21 - Glicerio - Sao Paulo');
    });

    test('aceita bairro e cidade quando a resposta nao possui rua', () {
      final address = DeviceLocationService.addressFromRemoteResponse({
        'address': {
          'neighbourhood': 'Jardim Paulista',
          'city': 'Sao Paulo',
        },
      });

      expect(address, 'Jardim Paulista - Sao Paulo');
    });

    test('usa display_name quando nao ha campos estruturados', () {
      final address = DeviceLocationService.addressFromRemoteResponse({
        'display_name': 'Parque Estadual, Sao Paulo, Brasil',
        'address': <String, dynamic>{},
      });

      expect(address, 'Parque Estadual, Sao Paulo, Brasil');
    });

    test('ignora campos vazios e nao repete localidade', () {
      final address = DeviceLocationService.formatAddress(
        street: '  ',
        number: null,
        district: 'Santos',
        city: 'santos',
      );

      expect(address, 'Santos');
    });

    test('retorna null apenas quando toda a resposta esta vazia', () {
      expect(
        DeviceLocationService.addressFromRemoteResponse({
          'address': <String, dynamic>{},
        }),
        isNull,
      );
    });
  });
}
