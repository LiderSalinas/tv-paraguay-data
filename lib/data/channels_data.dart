import '../models/channel.dart';

const String demoMp4Url =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

const String testHlsUrl =
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';

const Map<String, String> defaultStreamHeaders = {
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
};

const List<Channel> paraguayChannelsFallback = [
  Channel(
    id: 0,
    name: 'PRUEBA HLS',
    shortName: 'TEST',
    category: 'Prueba',
    streamUrl: testHlsUrl,
    httpHeaders: defaultStreamHeaders,
  ),
  Channel(
    id: 1,
    name: 'TELEFUTURO',
    shortName: 'TF',
    category: 'Nacional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 2,
    name: 'SNT',
    shortName: 'SNT',
    category: 'Nacional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 3,
    name: 'TRECE',
    shortName: '13',
    category: 'Nacional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 4,
    name: 'PARAVISIÓN',
    shortName: 'PV',
    category: 'Nacional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 5,
    name: 'UNICANAL',
    shortName: 'UNI',
    category: 'Nacional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 6,
    name: 'LA TELE',
    shortName: 'LT',
    category: 'Nacional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 7,
    name: 'PARAGUAY TV',
    shortName: 'PYTV',
    category: 'Nacional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 8,
    name: 'TV2',
    shortName: 'TV2',
    category: 'Nacional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 9,
    name: 'NPY',
    shortName: 'NPY',
    category: 'Noticias',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 10,
    name: 'C9N',
    shortName: 'C9N',
    category: 'Noticias',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 11,
    name: 'GEN',
    shortName: 'GEN',
    category: 'Noticias',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 12,
    name: 'ABC TV',
    shortName: 'ABC',
    category: 'Noticias',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 13,
    name: 'E40 TV',
    shortName: 'E40',
    category: 'Entretenimiento',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 14,
    name: 'PALMA TV',
    shortName: 'PALMA',
    category: 'Entretenimiento',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 15,
    name: 'RQP TV',
    shortName: 'RQP',
    category: 'Entretenimiento',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 16,
    name: 'RCC',
    shortName: 'RCC',
    category: 'Regional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 17,
    name: 'A24 PARAGUAY',
    shortName: 'A24',
    category: 'Regional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 18,
    name: 'AMÉRICA PARAGUAY',
    shortName: 'AM',
    category: 'Regional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 19,
    name: 'SUR TV',
    shortName: 'SUR',
    category: 'Regional',
    streamUrl: demoMp4Url,
  ),
  Channel(
    id: 20,
    name: 'SOMOS DEL ESTE',
    shortName: 'SOMOS',
    category: 'Regional',
    streamUrl: demoMp4Url,
  ),
];