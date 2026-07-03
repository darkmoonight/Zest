import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] in an external browser or app.
Future<void> launchExternalUrl(String uri) async {
  final url = Uri.parse(uri);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
