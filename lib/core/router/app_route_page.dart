import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/fade_through_page.dart';

bool useCupertinoRoutePage(TargetPlatform platform) => platform == TargetPlatform.iOS;

Page<T> buildAppRoutePage<T>({required BuildContext context, required GoRouterState state, required Widget child}) {
  if (useCupertinoRoutePage(Theme.of(context).platform)) {
    return CupertinoPage<T>(key: state.pageKey, child: child);
  }

  return buildFadeThroughPage<T>(context: context, state: state, child: child);
}
