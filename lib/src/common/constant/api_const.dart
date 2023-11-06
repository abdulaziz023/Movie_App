import 'config.dart';

class ApiConst {
  const ApiConst._();

  static const imageLoadEntry = 'https://image.tmdb.org/t/p/w500';

  static const popularPath = '/3/discover/movie';

  static const regionQuery = {
    'language': 'us-US',
    'region': 'US',
  };

  static const apiKeyQuery = {
    'api_key': Config.apiKey,
  };
}
