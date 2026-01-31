import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/infrastructure/network/network.dart';

import '../../../composer/domain/klipy_gif.dart';
import '../../../composer/infrastructure/klipy_service.dart';

/// Result data returned when user selects a GIF.
class GifSelectionResult {
  const GifSelectionResult({
    required this.uri,
    required this.title,
    this.description,
    required this.thumbBlobJson,
  });

  final String uri;
  final String title;
  final String? description;
  final String thumbBlobJson;
}

/// Screen for searching and selecting GIFs from Klipy.
class GifPickerScreen extends ConsumerStatefulWidget {
  const GifPickerScreen({super.key});

  @override
  ConsumerState<GifPickerScreen> createState() => _GifPickerScreenState();
}

class _GifPickerScreenState extends ConsumerState<GifPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<KlipyGif> _gifs = [];
  int? _nextPage;
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFeaturedGifs();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedGifs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isSearching = false;
    });

    try {
      final service = ref.read(klipyServiceProvider);
      final response = await service.getTrendingGifs();

      if (mounted) {
        setState(() {
          _gifs.clear();
          _gifs.addAll(response.results);
          _nextPage = response.nextPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load GIFs: $e')));
      }
    }
  }

  Future<void> _searchGifs(String query) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _nextPage = null;
    });

    try {
      final service = ref.read(klipyServiceProvider);
      final response = await service.searchGifs(query: query);

      if (mounted) {
        setState(() {
          _gifs.clear();
          _gifs.addAll(response.results);
          _nextPage = response.nextPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to search GIFs: $e')));
      }
    }
  }

  Future<void> _loadMoreGifs() async {
    if (_isLoading || _nextPage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(klipyServiceProvider);

      final KlipySearchResponse response;
      if (_isSearching) {
        response = await service.searchGifs(query: _searchController.text, page: _nextPage!);
      } else {
        response = await service.getTrendingGifs(page: _nextPage!);
      }

      if (mounted) {
        setState(() {
          _gifs.addAll(response.results);
          _nextPage = response.nextPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreGifs();
    }
  }

  Future<void> _selectGif(KlipyGif gif) async {
    try {
      final service = ref.read(klipyServiceProvider);

      final thumbnailUrl = gif.thumbnailUrl;
      if (thumbnailUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No thumbnail available for this GIF')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final thumbFile = await service.downloadThumbnail(thumbnailUrl);

      if (!mounted) return;

      final xrpcClient = ref.read(xrpcClientProvider);
      final response = await xrpcClient.callRaw<Map<String, dynamic>>(
        'com.atproto.repo.uploadBlob',
        body: thumbFile,
      );

      final blob = response.data?['blob'] as Map<String, dynamic>?;
      if (blob == null) {
        throw Exception('Upload response missing blob');
      }

      final blobRefJson = jsonEncode(blob);

      if (!mounted) return;

      final result = GifSelectionResult(
        uri: gif.itemUrl,
        title: gif.title,
        description: gif.tags?.join(', '),
        thumbBlobJson: blobRefJson,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to select GIF: $e')));
      }
    }
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isEmpty) {
        _loadFeaturedGifs();
      } else {
        _searchGifs(value);
      }
    });
  }

  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search GIFs'),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              _loadFeaturedGifs();
            },
            child: const Text('Featured'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search GIFs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadFeaturedGifs();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _gifs.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No GIFs found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _gifs.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _gifs.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final gif = _gifs[index];
                      return GifGridItem(gif: gif, onTap: () => _selectGif(gif));
                    },
                  ),
          ),
        ],
      ),
      bottomSheet: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Powered by Klipy',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Grid item for displaying a GIF thumbnail.
class GifGridItem extends StatelessWidget {
  const GifGridItem({required this.gif, required this.onTap, super.key});

  final KlipyGif gif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: colorScheme.surfaceContainerHighest,
          child: gif.thumbnailUrl != null
              ? Stack(
                  children: [
                    Image.network(
                      gif.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.broken_image, color: colorScheme.error),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                    if (disableAnimations)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                            ),
                          ),
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 48,
                          ),
                        ),
                      ),
                  ],
                )
              : Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.broken_image, color: colorScheme.error),
                ),
        ),
      ),
    );
  }
}
