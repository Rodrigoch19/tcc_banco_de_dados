// Lista de alertas de exemplo usada enquanto o app nao possui um banco de dados.
import 'package:latlong2/latlong.dart';
import '../models/alerta.dart';

const cityCenter = LatLng(-23.5613, -46.6565);

const seedAlerts = <CommunityAlert>[
  CommunityAlert(
    id: 'a1',
    category: AlertCategory.assalto,
    risk: RiskLevel.critico,
    title: 'Assalto a pedestre',
    description: 'Dupla em moto abordou pedestre na esquina. Policia acionada.',
    street: 'Rua Augusta - Cerqueira César',
    lat: -23.5603320,
    lng: -46.6625270,
    minutesAgo: 12,
    author: 'Marina S.',
    confirmations: 8,
  ),
  CommunityAlert(
    id: 'a2',
    category: AlertCategory.acidente,
    risk: RiskLevel.medio,
    title: 'Acidente de transito',
    description: 'Colisao entre dois carros. Transito lento no local.',
    street: 'Rua Haddock Lobo - Jardim América',
    lat: -23.5620377,
    lng: -46.6659896,
    minutesAgo: 47,
    author: 'Anonimo',
    confirmations: 3,
  ),
  CommunityAlert(
    id: 'a3',
    category: AlertCategory.incendio,
    risk: RiskLevel.critico,
    title: 'Principio de incendio',
    description: 'Fumaca saindo de um estabelecimento. Bombeiros acionados.',
    street: 'Rua Bela Cintra - Consolação',
    lat: -23.5527377,
    lng: -46.6560256,
    minutesAgo: 180,
    author: 'Carlos M.',
    confirmations: 12,
  ),
];
