// Le a localizacao do aparelho e transforma coordenadas em endereco.
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'transporte_geocodificacao_reversa.dart';

class DeviceCoordinates {
  const DeviceCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class DeviceLocation extends DeviceCoordinates {
  const DeviceLocation({
    required super.latitude,
    required super.longitude,
    required this.address,
    this.attribution,
  });

  final String address;
  final String? attribution;
}

class DeviceLocationService {
  DeviceLocationService._();

  static final _geocoding = Geocoding();
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );
  static String? _cachedRemotePosition;
  static String? _cachedRemoteAddress;
  static DateTime? _lastRemoteRequest;
  static Uri? _webReverseEndpoint;
  static String? _webAttribution;

  /// Atualiza apenas as coordenadas usadas para calcular as distancias.
  static Stream<DeviceCoordinates> watchCoordinates() async* {
    await _requestAccess();
    await for (final position in Geolocator.getPositionStream(
      locationSettings: _settings,
    )) {
      yield DeviceCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
  }

  /// Obtem a posicao atual e converte as coordenadas para um endereco.
  static Future<DeviceLocation> locate() async {
    await _requestAccess();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: _settings,
    );
    return _toLocation(position);
  }

  static double distanceInKm(
    DeviceCoordinates origin,
    double latitude,
    double longitude,
  ) {
    return Geolocator.distanceBetween(
          origin.latitude,
          origin.longitude,
          latitude,
          longitude,
        ) /
        1000;
  }

  static Future<void> _requestAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationAccessException('Ative a localizacao do aparelho.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationAccessException('Permissao de localizacao negada.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationAccessException(
        'Permissao bloqueada. Ative-a nas configuracoes do aparelho.',
      );
    }
  }

  static Future<DeviceLocation> _toLocation(Position position) async {
    String? address;
    var usedRemoteGeocoder = false;

    if (!kIsWeb) {
      try {
        address = await _nativeAddress(position);
      } catch (_) {
        // Alguns aparelhos nao oferecem um geocoder nativo funcional.
      }
    }

    if (address == null || address.isEmpty) {
      try {
        address = await _remoteAddress(position);
        usedRemoteGeocoder = address != null && address.isNotEmpty;
      } catch (_) {
        // A mensagem amigavel abaixo cobre falhas de rede e do provedor.
      }
    }

    if (address != null && address.isNotEmpty) {
      return DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        attribution: usedRemoteGeocoder ? _webAttribution : null,
      );
    }

    throw const LocationAccessException(
      'Não foi possível identificar o endereço. Verifique sua conexão e tente novamente.',
    );
  }

  static Future<String?> _nativeAddress(Position position) async {
    final places = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
      locale: const Locale('pt', 'BR'),
    );
    if (places.isEmpty) return null;

    final place = places.first;
    return formatAddress(
      street: _first([place.thoroughfare, place.street, place.name]),
      number: place.subThoroughfare,
      district: _first([place.subLocality, place.subAdministrativeArea]),
      city: _first([place.locality, place.administrativeArea]),
    );
  }

  static Future<String?> _remoteAddress(Position position) async {
    final positionKey = '${position.latitude.toStringAsFixed(4)},'
        '${position.longitude.toStringAsFixed(4)}';
    if (_cachedRemotePosition == positionKey && _cachedRemoteAddress != null) {
      return _cachedRemoteAddress;
    }

    final lastRequest = _lastRemoteRequest;
    if (lastRequest != null) {
      final remaining =
          const Duration(seconds: 1) - DateTime.now().difference(lastRequest);
      if (!remaining.isNegative) await Future<void>.delayed(remaining);
    }

    _lastRemoteRequest = DateTime.now();
    final endpoint = await _loadWebGeocodingConfig();
    final uri = endpoint.replace(queryParameters: {
      ...endpoint.queryParameters,
      'format': 'jsonv2',
      'lat': position.latitude.toString(),
      'lon': position.longitude.toString(),
      'accept-language': 'pt-BR',
      'addressdetails': '1',
      'layer': 'address',
      'zoom': '18',
    });
    final result = await fetchReverseGeocoding(
      uri,
      timeout: const Duration(seconds: 8),
    );
    final address = addressFromRemoteResponse(result);

    // Uma resposta vazia nao deve impedir que o usuario tente novamente.
    if (address != null) {
      _cachedRemotePosition = positionKey;
      _cachedRemoteAddress = address;
    }
    return address;
  }

  static Future<Uri> _loadWebGeocodingConfig() async {
    final configuredEndpoint = _webReverseEndpoint;
    if (configuredEndpoint != null) return configuredEndpoint;

    const fallback = 'https://nominatim.openstreetmap.org/reverse';
    if (!kIsWeb) {
      _webAttribution = '© colaboradores do OpenStreetMap';
      return _webReverseEndpoint = Uri.parse(fallback);
    }
    _webAttribution = '© colaboradores do OpenStreetMap';
    try {
      final response = await http
          .get(Uri.base.resolve('geocoding_config.json'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final config = jsonDecode(response.body);
        if (config is Map<String, dynamic>) {
          _webAttribution = _first([config['attribution']]) ?? _webAttribution;
          final reverseUrl = _first([config['reverseUrl']]);
          final endpoint = reverseUrl == null ? null : Uri.tryParse(reverseUrl);
          if (endpoint != null && endpoint.hasScheme) {
            _webReverseEndpoint = endpoint;
          }
        }
      }
    } catch (_) {
      // O endpoint padrao mantem o prototipo funcional sem configuracao extra.
    }
    return _webReverseEndpoint ??= Uri.parse(fallback);
  }

  /// Converte a resposta Nominatim em um endereco util mesmo sem rua/numero.
  @visibleForTesting
  static String? addressFromRemoteResponse(Map<String, dynamic> result) {
    final details = _stringMap(result['address']);
    return formatAddress(
          street: _value(details, [
            'road',
            'pedestrian',
            'residential',
            'footway',
            'path',
            'cycleway',
            'square',
            'place',
          ]),
          number: _value(details, ['house_number']),
          district: _value(details, [
            'neighbourhood',
            'suburb',
            'quarter',
            'city_district',
            'borough',
            'village',
            'hamlet',
          ]),
          city: _value(details, [
            'city',
            'town',
            'municipality',
            'village',
            'county',
          ]),
        ) ??
        _first([result['display_name'], result['name']]);
  }

  @visibleForTesting
  static String? formatAddress({
    required String? street,
    required String? number,
    required String? district,
    required String? city,
  }) {
    final cleanStreet = _first([street]);
    final cleanNumber = _first([number]);
    final cleanDistrict = _first([district]);
    final cleanCity = _first([city]);
    final hasNumber = cleanStreet != null &&
        cleanNumber != null &&
        !cleanStreet.toLowerCase().contains(cleanNumber.toLowerCase());
    final streetAndNumber =
        hasNumber ? '$cleanStreet, $cleanNumber' : cleanStreet;
    return _joinUnique([streetAndNumber, cleanDistrict, cleanCity], ' - ');
  }

  static Map<String, dynamic> _stringMap(Object? value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: entry.value,
    };
  }

  static String? _value(Map<String, dynamic> values, List<String> keys) {
    return _first(keys.map((key) => values[key]));
  }

  static String? _first(Iterable<Object?> values) {
    for (final value in values.whereType<String>()) {
      final text = value.trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _joinUnique(List<String?> parts, String separator) {
    final seen = <String>{};
    final unique = <String>[];
    for (final part in parts.whereType<String>()) {
      final key = part.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (key.isNotEmpty && seen.add(key)) unique.add(part);
    }
    return unique.isEmpty ? null : unique.join(separator);
  }
}

class LocationAccessException implements Exception {
  const LocationAccessException(this.message);

  final String message;

  @override
  String toString() => message;
}
