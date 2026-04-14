part of 'compose_bloc.dart';

abstract class ComposeEvent extends Equatable {
  const ComposeEvent();

  @override
  List<Object?> get props => [];
}

class TextChanged extends ComposeEvent {
  const TextChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

class MediaAttached extends ComposeEvent {
  const MediaAttached(this.path, {this.width, this.height});

  final String path;
  final int? width;
  final int? height;

  @override
  List<Object?> get props => [path, width, height];
}

class MediaRemoved extends ComposeEvent {
  const MediaRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class AltTextUpdated extends ComposeEvent {
  const AltTextUpdated({required this.index, required this.altText});

  final int index;
  final String altText;

  @override
  List<Object?> get props => [index, altText];
}

class DraftSaved extends ComposeEvent {
  const DraftSaved();
}

class DraftLoaded extends ComposeEvent {
  const DraftLoaded(this.draftId);

  final int draftId;

  @override
  List<Object?> get props => [draftId];
}

class DraftsRequested extends ComposeEvent {
  const DraftsRequested();
}

class DraftDeleted extends ComposeEvent {
  const DraftDeleted(this.draftId);

  final int draftId;

  @override
  List<Object?> get props => [draftId];
}

class PostScheduled extends ComposeEvent {
  const PostScheduled(this.scheduledAt);

  final DateTime scheduledAt;

  @override
  List<Object?> get props => [scheduledAt];
}

class ScheduleCleared extends ComposeEvent {
  const ScheduleCleared();
}

class VideoAttached extends ComposeEvent {
  const VideoAttached(this.path);

  final String path;

  @override
  List<Object?> get props => [path];
}

class VideoRemoved extends ComposeEvent {
  const VideoRemoved();
}

class VideoAltTextUpdated extends ComposeEvent {
  const VideoAltTextUpdated(this.altText);

  final String altText;

  @override
  List<Object?> get props => [altText];
}

class PostSubmitted extends ComposeEvent {
  const PostSubmitted();
}

class ReplyContextSet extends ComposeEvent {
  const ReplyContextSet({
    required this.parentUri,
    required this.parentCid,
    required this.rootUri,
    required this.rootCid,
  });

  final String parentUri;
  final String parentCid;
  final String rootUri;
  final String rootCid;

  @override
  List<Object?> get props => [parentUri, parentCid, rootUri, rootCid];
}

class ReplyContextCleared extends ComposeEvent {
  const ReplyContextCleared();
}

class QuoteContextSet extends ComposeEvent {
  const QuoteContextSet({required this.quoteUri, required this.quoteCid});

  final String quoteUri;
  final String quoteCid;

  @override
  List<Object?> get props => [quoteUri, quoteCid];
}

class QuoteContextCleared extends ComposeEvent {
  const QuoteContextCleared();
}

class EditContextSet extends ComposeEvent {
  const EditContextSet({required this.postUri, required this.postCid, required this.record, this.initialText});

  final String postUri;
  final String postCid;
  final Map<String, dynamic> record;
  final String? initialText;

  @override
  List<Object?> get props => [postUri, postCid, record, initialText];
}
