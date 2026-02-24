import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/inquadra_app.dart';
import 'shared/logging/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('Avvio app InQuadra V1');
  runApp(const ProviderScope(child: InQuadraApp()));
}
