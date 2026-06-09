import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/app_route_paths.dart';

String labelerProfileLocation(String did) => AppRoutePath.labelerProfileLocation(did: did);

void openLabelerProfile(BuildContext context, String did) {
  context.push(labelerProfileLocation(did));
}
