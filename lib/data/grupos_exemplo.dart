// Lista de grupos de exemplo usada pelo prototipo.
import '../models/grupo_comunitario.dart';

const seedGroups = <CommunityGroup>[
  CommunityGroup(
    id: 'centro-seguro',
    name: 'Centro Seguro',
    description: 'Avisos rápidos e apoio entre moradores do Centro.',
    category: GroupCategory.seguranca,
    lat: -23.55052,
    lng: -46.63331,
    members: 248,
    initialMessages: [
      GroupMessage(
        id: 'centro-1',
        author: 'Marina',
        text: 'Bom dia! A região da praça está tranquila agora.',
        sentAt: '08:14',
      ),
      GroupMessage(
        id: 'centro-2',
        author: 'Carlos',
        text: 'Obrigado pelo aviso, Marina.',
        sentAt: '08:19',
      ),
    ],
  ),
  CommunityGroup(
    id: 'vizinhos-liberdade',
    name: 'Vizinhos da Liberdade',
    description: 'Informações e ajuda para quem vive na Liberdade.',
    category: GroupCategory.vizinhanca,
    lat: -23.55720,
    lng: -46.63570,
    members: 186,
    initialMessages: [
      GroupMessage(
        id: 'liberdade-1',
        author: 'Akemi',
        text: 'Alguém recebeu uma encomenda para o número 84?',
        sentAt: '09:32',
      ),
    ],
  ),
  CommunityGroup(
    id: 'familias-bela-vista',
    name: 'Famílias da Bela Vista',
    description: 'Rede de apoio para famílias, escolas e atividades locais.',
    category: GroupCategory.familias,
    lat: -23.56140,
    lng: -46.65600,
    members: 121,
    initialMessages: [
      GroupMessage(
        id: 'bela-vista-1',
        author: 'Renata',
        text: 'Hoje tem atividade infantil no centro cultural às 15h.',
        sentAt: '10:05',
      ),
    ],
  ),
  CommunityGroup(
    id: 'pets-santa-cecilia',
    name: 'Pets de Santa Cecília',
    description: 'Cuidados, encontros e alertas sobre animais perdidos.',
    category: GroupCategory.animais,
    lat: -23.53740,
    lng: -46.65790,
    members: 94,
    initialMessages: [
      GroupMessage(
        id: 'santa-cecilia-1',
        author: 'Beto',
        text: 'Encontrei uma coleira azul perto da praça.',
        sentAt: '11:21',
      ),
    ],
  ),
  CommunityGroup(
    id: 'ronda-santana',
    name: 'Ronda Comunitária Santana',
    description: 'Organização de horários e pontos seguros no bairro.',
    category: GroupCategory.seguranca,
    lat: -23.50540,
    lng: -46.62470,
    members: 163,
    initialMessages: [
      GroupMessage(
        id: 'santana-1',
        author: 'João',
        text: 'A iluminação da Rua Voluntários voltou a funcionar.',
        sentAt: '12:03',
      ),
    ],
  ),
  CommunityGroup(
    id: 'caminhos-tatuape',
    name: 'Caminhos Seguros Tatuapé',
    description: 'Rotas recomendadas para escolas, parques e metrô.',
    category: GroupCategory.mobilidade,
    lat: -23.54020,
    lng: -46.57670,
    members: 139,
    initialMessages: [
      GroupMessage(
        id: 'tatuape-1',
        author: 'Paula',
        text: 'A passagem ao lado do metrô está aberta normalmente.',
        sentAt: '12:46',
      ),
    ],
  ),
  CommunityGroup(
    id: 'pedal-pinheiros',
    name: 'Pedal em Pinheiros',
    description: 'Companhia, rotas e segurança para ciclistas da região.',
    category: GroupCategory.mobilidade,
    lat: -23.56730,
    lng: -46.69100,
    members: 77,
    initialMessages: [
      GroupMessage(
        id: 'pinheiros-1',
        author: 'Diego',
        text: 'Saída para a ciclovia amanhã às 7h. Quem participa?',
        sentAt: '13:17',
      ),
    ],
  ),
  CommunityGroup(
    id: 'parques-moema',
    name: 'Parques e Lazer Moema',
    description: 'Encontros e atividades ao ar livre para a vizinhança.',
    category: GroupCategory.lazer,
    lat: -23.60080,
    lng: -46.66590,
    members: 112,
    initialMessages: [
      GroupMessage(
        id: 'moema-1',
        author: 'Luciana',
        text: 'O treino coletivo começa às 18h no parque.',
        sentAt: '14:08',
      ),
    ],
  ),
  CommunityGroup(
    id: 'rede-campinas',
    name: 'Rede Comunitária Campinas',
    description: 'Comunicação colaborativa entre moradores de Campinas.',
    category: GroupCategory.vizinhanca,
    lat: -22.90560,
    lng: -47.06080,
    members: 304,
    initialMessages: [
      GroupMessage(
        id: 'campinas-1',
        author: 'Fernanda',
        text: 'Bem-vindos à rede comunitária de Campinas!',
        sentAt: '15:30',
      ),
    ],
  ),
];
