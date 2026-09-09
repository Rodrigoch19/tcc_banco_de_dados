// Faz a consulta de endereco quando o aplicativo roda no navegador.
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

var _requestSequence = 0;

/// Carrega o JSON por callback para contornar o bloqueio CORS do Nominatim.
Future<Map<String, dynamic>> fetchReverseGeocoding(
  Uri uri, {
  required Duration timeout,
}) {
  final completer = Completer<Map<String, dynamic>>();
  final callbackName =
      '__safeNeighborGeocode_${DateTime.now().microsecondsSinceEpoch}_${_requestSequence++}';
  final script = web.HTMLScriptElement();
  Timer? timer;

  void cleanUp() {
    timer?.cancel();
    script.remove();
    globalContext.delete(callbackName.toJS);
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (completer.isCompleted) return;
    cleanUp();
    completer.completeError(error, stackTrace ?? StackTrace.current);
  }

  final callback = ((JSAny? value) {
    if (completer.isCompleted) return;
    try {
      final decoded = jsonDecode(jsonEncode(value?.dartify()));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Resposta de geocodificação inválida.');
      }
      cleanUp();
      completer.complete(decoded);
    } catch (error, stackTrace) {
      completeError(error, stackTrace);
    }
  }).toJS;

  final errorListener = ((web.Event _) {
    completeError(StateError('Falha ao consultar o endereço.'));
  }).toJS;

  globalContext.setProperty(callbackName.toJS, callback);
  script
    ..async = true
    ..src = uri.replace(queryParameters: {
      ...uri.queryParameters,
      'json_callback': callbackName,
    }).toString()
    ..addEventListener('error', errorListener);

  timer = Timer(
    timeout,
    () => completeError(TimeoutException('Tempo limite da geocodificação.')),
  );

  final head = web.document.head;
  if (head == null) {
    completeError(StateError('Documento Web indisponível.'));
  } else {
    head.appendChild(script);
  }
  return completer.future;
}