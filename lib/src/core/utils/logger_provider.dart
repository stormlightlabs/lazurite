import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'logger.dart';

part 'logger_provider.g.dart';

@Riverpod(keepAlive: true)
Logger logger(Ref ref, String name) => Logger(name);
