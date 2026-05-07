import 'dart:convert';

import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/core/theme/color_filters.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  static const _avatarMaxWidth = 1000.0;
  static const _bannerMaxWidth = 2400.0;
  static const _bannerMaxHeight = 1200.0;

  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _websiteController = TextEditingController();
  final _picker = ImagePicker();

  ProfileImageUpload? _avatarUpload;
  ProfileImageUpload? _bannerUpload;
  bool _saving = false;
  bool _pickingAvatar = false;
  bool _pickingBanner = false;
  String? _hydratedProfileDid;

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    _pronounsController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(ProfileViewDetailed profile) {
    if (_hydratedProfileDid == profile.did) {
      return;
    }
    _hydratedProfileDid = profile.did;
    _displayNameController.text = profile.displayName ?? '';
    _descriptionController.text = profile.description ?? '';
    _pronounsController.text = profile.pronouns ?? '';
    _websiteController.text = profile.website ?? '';
  }

  Future<void> _pickProfileImage({required bool banner}) async {
    if (banner ? _pickingBanner : _pickingAvatar) {
      return;
    }
    setState(() {
      if (banner) {
        _pickingBanner = true;
      } else {
        _pickingAvatar = true;
      }
    });

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: banner ? _bannerMaxWidth : _avatarMaxWidth,
        maxHeight: banner ? _bannerMaxHeight : _avatarMaxWidth,
        imageQuality: 85,
      );
      if (image == null) {
        return;
      }

      final size = await image.length();
      if (size > ProfileImageUpload.maxBytes) {
        if (mounted) {
          showAppSnackBar(context, 'Image must be smaller than 1MB', isError: true);
        }
        return;
      }

      final mimeType = profileImageMimeTypeFor(reportedMimeType: image.mimeType, path: image.path);
      if (mimeType == null) {
        if (mounted) {
          showAppSnackBar(context, 'Use a JPEG or PNG image', isError: true);
        }
        return;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        final upload = ProfileImageUpload(bytes: bytes, mimeType: mimeType);
        if (banner) {
          _bannerUpload = upload;
        } else {
          _avatarUpload = upload;
        }
      });
    } catch (error, stackTrace) {
      log.w('ProfileEditScreen: failed to pick profile image', error: error, stackTrace: stackTrace);
      if (mounted) {
        showAppSnackBar(context, 'Unable to read selected image', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          if (banner) {
            _pickingBanner = false;
          } else {
            _pickingAvatar = false;
          }
        });
      }
    }
  }

  Future<void> _save(ProfileViewDetailed profile) async {
    if (_saving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final did = context.read<AuthBloc>().state.tokens?.did ?? profile.did;
    setState(() => _saving = true);
    try {
      await context.read<ProfileRepository>().updateProfile(
        did: did,
        draft: ProfileEditDraft(
          displayName: _optionalText(_displayNameController.text),
          description: _optionalText(_descriptionController.text),
          pronouns: _optionalText(_pronounsController.text),
          website: _normalizedWebsite(_websiteController.text),
          avatar: _avatarUpload,
          banner: _bannerUpload,
        ),
      );
      if (!mounted) {
        return;
      }
      context.read<ProfileBloc>().add(ProfileLoadRequested(actor: did));
      showAppSnackBar(context, 'Profile updated', behavior: SnackBarBehavior.floating);
      context.go('/profile/me');
    } catch (error, stackTrace) {
      log.w('ProfileEditScreen: failed to save profile', error: error, stackTrace: stackTrace);
      if (mounted) {
        showAppSnackBar(context, 'Unable to update profile', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizedWebsite(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  String? _validateTextLimit(String? value, String label, {required int maxGraphemes, required int maxUtf8Bytes}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (text.characters.length > maxGraphemes) {
      return '$label must be $maxGraphemes characters or fewer';
    }
    if (utf8.encode(text).length > maxUtf8Bytes) {
      return '$label is too long';
    }
    return null;
  }

  String? _validateWebsite(String? value) {
    final normalized = _normalizedWebsite(value ?? '');
    if (normalized == null) {
      return null;
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Enter a valid website';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileBloc>().state.profile;
    if (profile != null) {
      _hydrateFromProfile(profile);
    }

    return AppScreenEntrance(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit profile'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
            onPressed: _saving ? null : () => context.go('/profile/me'),
          ),
          actions: [
            TextButton.icon(
              key: const ValueKey('profile_edit_save_button'),
              onPressed: profile == null || _saving ? null : () => _save(profile),
              icon: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: const Text('Save'),
            ),
          ],
        ),
        body: profile == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: _animatedFormChildren(context, profile),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _animatedFormChildren(BuildContext context, ProfileViewDetailed profile) {
    final children = [_buildMediaEditor(context, profile), const SizedBox(height: 24), _buildTextFields()];
    if (!animationsAllowed(context)) {
      return children;
    }
    return [
      for (var i = 0; i < children.length; i++)
        children[i]
            .animate(delay: Anim.staggerFor(i))
            .fadeIn(duration: Anim.normal, curve: Anim.enter)
            .slideY(begin: 0.04, end: 0, duration: Anim.normal, curve: Anim.enter),
    ];
  }

  Widget _buildMediaEditor(BuildContext context, ProfileViewDetailed profile) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: 'Change banner image',
          child: Semantics(
            label: 'Change banner image',
            button: true,
            child: AspectRatio(
              aspectRatio: 3,
              child: InkWell(
                key: const ValueKey('profile_edit_banner_picker'),
                onTap: _saving ? null : () => _pickProfileImage(banner: true),
                borderRadius: BorderRadius.circular(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildBannerPreview(context, profile),
                      ColoredBox(color: Colors.black.withValues(alpha: 0.24)),
                      Center(
                        child: FilledButton.tonalIcon(
                          onPressed: _saving ? null : () => _pickProfileImage(banner: true),
                          icon: _pickingBanner
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.image_outlined),
                          label: const Text('Banner'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Tooltip(
              message: 'Change avatar image',
              child: Semantics(
                label: 'Change avatar image',
                button: true,
                child: InkWell(
                  key: const ValueKey('profile_edit_avatar_picker'),
                  onTap: _saving ? null : () => _pickProfileImage(banner: false),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.surfaceContainerLowest, width: 4),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildAvatarPreview(context, profile),
                        ColoredBox(color: Colors.black.withValues(alpha: 0.24)),
                        Center(
                          child: _pickingAvatar
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.photo_camera_outlined, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerPreview(BuildContext context, ProfileViewDetailed profile) {
    final upload = _bannerUpload;
    if (upload != null) {
      return Image.memory(Uint8List.fromList(upload.bytes), fit: BoxFit.cover);
    }
    if (profile.banner != null) {
      return ColorFiltered(
        colorFilter: AppColorFilters.greyscale,
        child: Image.network(
          profile.banner!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(color: context.colorScheme.surfaceContainerHigh),
        ),
      );
    }
    return ColoredBox(color: context.colorScheme.surfaceContainerHigh);
  }

  Widget _buildAvatarPreview(BuildContext context, ProfileViewDetailed profile) {
    final upload = _avatarUpload;
    if (upload != null) {
      return Image.memory(Uint8List.fromList(upload.bytes), fit: BoxFit.cover);
    }
    if (profile.avatar != null) {
      return Image.network(
        profile.avatar!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildAvatarFallback(context, profile),
      );
    }
    return _buildAvatarFallback(context, profile);
  }

  Widget _buildAvatarFallback(BuildContext context, ProfileViewDetailed profile) {
    return Center(
      child: Text(
        formatInitials(profile.displayName ?? profile.handle),
        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTextFields() => Column(
    children: [
      TextFormField(
        key: const ValueKey('profile_edit_display_name_field'),
        controller: _displayNameController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.badge_outlined)),
        validator: (value) => _validateTextLimit(value, 'Display name', maxGraphemes: 64, maxUtf8Bytes: 640),
      ),
      const SizedBox(height: 16),
      TextFormField(
        key: const ValueKey('profile_edit_description_field'),
        controller: _descriptionController,
        minLines: 3,
        maxLines: 6,
        textInputAction: TextInputAction.newline,
        decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes_outlined)),
        validator: (value) => _validateTextLimit(value, 'Description', maxGraphemes: 256, maxUtf8Bytes: 2560),
      ),
      const SizedBox(height: 16),
      TextFormField(
        key: const ValueKey('profile_edit_pronouns_field'),
        controller: _pronounsController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'Pronouns', prefixIcon: Icon(Icons.record_voice_over_outlined)),
        validator: (value) => _validateTextLimit(value, 'Pronouns', maxGraphemes: 20, maxUtf8Bytes: 200),
      ),
      const SizedBox(height: 16),
      TextFormField(
        key: const ValueKey('profile_edit_website_field'),
        controller: _websiteController,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Website', prefixIcon: Icon(Icons.link_outlined)),
        validator: _validateWebsite,
        onFieldSubmitted: (_) {
          final profile = context.read<ProfileBloc>().state.profile;
          if (profile != null) {
            _save(profile);
          }
        },
      ),
    ],
  );
}

@visibleForTesting
String? profileImageMimeTypeFor({required String? reportedMimeType, required String path}) {
  final normalizedMimeType = reportedMimeType?.trim().toLowerCase();
  if (normalizedMimeType != null && normalizedMimeType.isNotEmpty) {
    return ProfileImageUpload.acceptedMimeTypes.contains(normalizedMimeType) ? normalizedMimeType : null;
  }

  final normalizedPath = path.toLowerCase();
  if (normalizedPath.endsWith('.png')) {
    return 'image/png';
  }
  if (normalizedPath.endsWith('.jpg') || normalizedPath.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  return null;
}
