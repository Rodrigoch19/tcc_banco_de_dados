// Escolhe automaticamente a versao para celular/computador ou para web.
export 'transporte_geocodificacao_reversa_io.dart'
    if (dart.library.js_interop) 'transporte_geocodificacao_reversa_web.dart';
