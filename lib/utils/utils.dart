import 'package:url_launcher/url_launcher.dart';


Uri generateGoogleSearchUrl(String query) {
  final baseUrl = 'https://www.google.com/search?q=';
  final encodedQuery = Uri.encodeQueryComponent(query);
  return Uri.parse('$baseUrl$encodedQuery');
}

Future<void> launchUrl_(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}