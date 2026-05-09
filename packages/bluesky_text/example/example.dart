// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'package:bluesky_text/bluesky_text.dart';

Future<void> main() async {
  //! You just need to pass text to parse.
  const text = BlueskyText(
    'I speak 日本語 and English 🚀 @shinyakato.dev and @shinyakato.bsky.social. '
    'Visit 🚀 https://shinyakato.dev.',
  );

  if (text.isLengthLimitExceeded) {
    //! Let's split.
    final texts = text.split();

    for (final text in texts) {
      print(text.handles);
      print(text.links);
      print(text.entities);
    }
  } else {
    // [{type: handle, value: @shinyakato.dev, indices: {start: 35, end: 50}},
    // {type: handle, value: @shinyakato.bsky.social, indices: {start: 55, end: 78}}]
    print(text.handles);

    // [{type: link, value: https://shinyakato.dev, indices: {start: 91, end: 113}}]
    print(text.links);

    // [{type: handle, value: @shinyakato.dev, indices: {start: 35, end: 50}},
    // {type: handle, value: @shinyakato.bsky.social, indices: {start: 55, end: 78}},
    // {type: link, value: https://shinyakato.dev, indices: {start: 91, end: 113}}]
    print(text.entities);

    //! And you can use these facets as app.bsky.richtext.facet JSON.
    final facets = await text.entities.toFacets();

    print(facets);
  }
}
