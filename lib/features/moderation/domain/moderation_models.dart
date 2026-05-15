import 'package:poptart_lex/com/atproto/label/defs.dart';

enum ModerationBehavior { blur, alert, inform, none }

enum ModerationBehaviorContext {
  profileList,
  profileView,
  avatar,
  banner,
  displayName,
  contentList,
  contentView,
  contentMedia;

  bool get isProfileList => this == ModerationBehaviorContext.profileList;
  bool get isProfileView => this == ModerationBehaviorContext.profileView;
  bool get isContentList => this == ModerationBehaviorContext.contentList;
}

enum LabelPreference {
  ignore,
  warn,
  hide;

  static LabelPreference? valueOf(String? value) {
    return switch (value) {
      'ignore' => LabelPreference.ignore,
      'warn' => LabelPreference.warn,
      'hide' => LabelPreference.hide,
      _ => null,
    };
  }
}

enum LabelTarget { account, profile, content }

class InterpretedLabelValueDefinition {
  const InterpretedLabelValueDefinition({
    required this.identifier,
    required this.severity,
    required this.blurs,
    required this.definedBy,
    this.defaultSetting = LabelPreference.warn,
    this.configurable = true,
    this.adultOnly = false,
    this.noOverride = false,
    this.behaviors = const {},
  });

  final String identifier;
  final String severity;
  final String blurs;
  final String definedBy;
  final LabelPreference defaultSetting;
  final bool configurable;
  final bool adultOnly;
  final bool noOverride;
  final Map<LabelTarget, Map<ModerationBehaviorContext, ModerationBehavior>> behaviors;

  InterpretedLabelValueDefinition withDefinedBy(String did) {
    return InterpretedLabelValueDefinition(
      identifier: identifier,
      severity: severity,
      blurs: blurs,
      definedBy: did,
      defaultSetting: defaultSetting,
      configurable: configurable,
      adultOnly: adultOnly,
      noOverride: noOverride,
      behaviors: behaviors,
    );
  }

  Map<ModerationBehaviorContext, ModerationBehavior> behaviorForTarget(LabelTarget target) {
    return behaviors[target] ?? const {};
  }
}

const knownLabelDefinitions = {
  '!hide': InterpretedLabelValueDefinition(
    identifier: '!hide',
    defaultSetting: LabelPreference.hide,
    severity: 'alert',
    blurs: 'content',
    noOverride: true,
    definedBy: '',
    behaviors: {
      LabelTarget.account: {
        ModerationBehaviorContext.profileList: ModerationBehavior.blur,
        ModerationBehaviorContext.profileView: ModerationBehavior.blur,
        ModerationBehaviorContext.avatar: ModerationBehavior.blur,
        ModerationBehaviorContext.banner: ModerationBehavior.blur,
        ModerationBehaviorContext.displayName: ModerationBehavior.blur,
        ModerationBehaviorContext.contentList: ModerationBehavior.blur,
        ModerationBehaviorContext.contentView: ModerationBehavior.blur,
      },
      LabelTarget.profile: {
        ModerationBehaviorContext.avatar: ModerationBehavior.blur,
        ModerationBehaviorContext.banner: ModerationBehavior.blur,
        ModerationBehaviorContext.displayName: ModerationBehavior.blur,
      },
      LabelTarget.content: {
        ModerationBehaviorContext.contentList: ModerationBehavior.blur,
        ModerationBehaviorContext.contentView: ModerationBehavior.blur,
      },
    },
  ),
  '!warn': InterpretedLabelValueDefinition(
    identifier: '!warn',
    defaultSetting: LabelPreference.warn,
    severity: 'none',
    blurs: 'content',
    definedBy: '',
    behaviors: {
      LabelTarget.account: {
        ModerationBehaviorContext.profileList: ModerationBehavior.blur,
        ModerationBehaviorContext.profileView: ModerationBehavior.blur,
        ModerationBehaviorContext.avatar: ModerationBehavior.blur,
        ModerationBehaviorContext.banner: ModerationBehavior.blur,
        ModerationBehaviorContext.contentList: ModerationBehavior.blur,
        ModerationBehaviorContext.contentView: ModerationBehavior.blur,
      },
      LabelTarget.profile: {
        ModerationBehaviorContext.avatar: ModerationBehavior.blur,
        ModerationBehaviorContext.banner: ModerationBehavior.blur,
        ModerationBehaviorContext.displayName: ModerationBehavior.blur,
      },
      LabelTarget.content: {
        ModerationBehaviorContext.contentList: ModerationBehavior.blur,
        ModerationBehaviorContext.contentView: ModerationBehavior.blur,
      },
    },
  ),
  '!no-unauthenticated': InterpretedLabelValueDefinition(
    identifier: '!no-unauthenticated',
    defaultSetting: LabelPreference.hide,
    severity: 'none',
    blurs: 'content',
    noOverride: true,
    definedBy: '',
    behaviors: {
      LabelTarget.account: {
        ModerationBehaviorContext.profileList: ModerationBehavior.blur,
        ModerationBehaviorContext.profileView: ModerationBehavior.blur,
        ModerationBehaviorContext.avatar: ModerationBehavior.blur,
        ModerationBehaviorContext.banner: ModerationBehavior.blur,
        ModerationBehaviorContext.displayName: ModerationBehavior.blur,
        ModerationBehaviorContext.contentList: ModerationBehavior.blur,
        ModerationBehaviorContext.contentView: ModerationBehavior.blur,
      },
      LabelTarget.profile: {
        ModerationBehaviorContext.avatar: ModerationBehavior.blur,
        ModerationBehaviorContext.banner: ModerationBehavior.blur,
        ModerationBehaviorContext.displayName: ModerationBehavior.blur,
      },
      LabelTarget.content: {
        ModerationBehaviorContext.contentList: ModerationBehavior.blur,
        ModerationBehaviorContext.contentView: ModerationBehavior.blur,
      },
    },
  ),
  'porn': InterpretedLabelValueDefinition(
    identifier: 'porn',
    configurable: true,
    defaultSetting: LabelPreference.hide,
    severity: 'none',
    blurs: 'media',
    adultOnly: true,
    definedBy: '',
    behaviors: _mediaLabelBehaviors,
  ),
  'sexual': InterpretedLabelValueDefinition(
    identifier: 'sexual',
    configurable: true,
    defaultSetting: LabelPreference.warn,
    severity: 'none',
    blurs: 'media',
    adultOnly: true,
    definedBy: '',
    behaviors: _mediaLabelBehaviors,
  ),
  'nudity': InterpretedLabelValueDefinition(
    identifier: 'nudity',
    configurable: true,
    defaultSetting: LabelPreference.ignore,
    severity: 'none',
    blurs: 'media',
    definedBy: '',
    behaviors: _mediaLabelBehaviors,
  ),
  'graphic-media': InterpretedLabelValueDefinition(
    identifier: 'graphic-media',
    configurable: true,
    defaultSetting: LabelPreference.warn,
    severity: 'none',
    blurs: 'media',
    adultOnly: true,
    definedBy: '',
    behaviors: _mediaLabelBehaviors,
  ),
};

const _mediaLabelBehaviors = {
  LabelTarget.account: {
    ModerationBehaviorContext.avatar: ModerationBehavior.blur,
    ModerationBehaviorContext.banner: ModerationBehavior.blur,
  },
  LabelTarget.profile: {
    ModerationBehaviorContext.avatar: ModerationBehavior.blur,
    ModerationBehaviorContext.banner: ModerationBehavior.blur,
  },
  LabelTarget.content: {ModerationBehaviorContext.contentMedia: ModerationBehavior.blur},
};

InterpretedLabelValueDefinition getInterpretedLabelValueDefinition({
  required String identifier,
  required LabelPreference defaultSetting,
  required String severity,
  required String blurs,
  required bool adultOnly,
  required String definedBy,
}) {
  final behavior = _behaviorForDefinition(severity: severity, blurs: blurs);
  return InterpretedLabelValueDefinition(
    identifier: identifier,
    defaultSetting: defaultSetting,
    severity: severity,
    blurs: blurs,
    adultOnly: adultOnly,
    definedBy: definedBy,
    behaviors: behavior.isEmpty
        ? const {}
        : {LabelTarget.account: behavior, LabelTarget.profile: behavior, LabelTarget.content: behavior},
  );
}

Map<ModerationBehaviorContext, ModerationBehavior> _behaviorForDefinition({
  required String severity,
  required String blurs,
}) {
  final alertBehavior = switch (severity) {
    'alert' => ModerationBehavior.alert,
    'inform' => ModerationBehavior.inform,
    _ => ModerationBehavior.none,
  };
  final blurBehavior = blurs == 'content' || blurs == 'media' ? ModerationBehavior.blur : alertBehavior;

  if (blurs == 'media') {
    return {
      ModerationBehaviorContext.avatar: blurBehavior,
      ModerationBehaviorContext.banner: blurBehavior,
      ModerationBehaviorContext.contentMedia: blurBehavior,
    };
  }

  if (blurs == 'content') {
    return {
      ModerationBehaviorContext.profileList: blurBehavior,
      ModerationBehaviorContext.profileView: blurBehavior,
      ModerationBehaviorContext.avatar: blurBehavior,
      ModerationBehaviorContext.banner: blurBehavior,
      ModerationBehaviorContext.displayName: blurBehavior,
      ModerationBehaviorContext.contentList: blurBehavior,
      ModerationBehaviorContext.contentView: blurBehavior,
    };
  }

  if (alertBehavior == ModerationBehavior.none) {
    return const {};
  }

  return {
    ModerationBehaviorContext.profileList: alertBehavior,
    ModerationBehaviorContext.profileView: alertBehavior,
    ModerationBehaviorContext.contentList: alertBehavior,
    ModerationBehaviorContext.contentView: alertBehavior,
  };
}

class ModerationPrefsLabeler {
  const ModerationPrefsLabeler({required this.did, required this.labels});

  final String did;
  final Map<String, LabelPreference> labels;
}

class ModerationPrefs {
  const ModerationPrefs({
    this.adultContentEnabled = false,
    required this.labels,
    required this.labelers,
    required this.mutedWords,
    required this.hiddenPosts,
  });

  final bool adultContentEnabled;
  final Map<String, LabelPreference> labels;
  final List<ModerationPrefsLabeler> labelers;
  final List<Object> mutedWords;
  final List<String> hiddenPosts;
}

class ModerationOpts {
  const ModerationOpts({required this.prefs, required this.labelDefs, this.userDid});

  final String? userDid;
  final ModerationPrefs prefs;
  final Map<String, List<InterpretedLabelValueDefinition>> labelDefs;
}

class ModerationUI {
  const ModerationUI({
    this.noOverride = false,
    this.filters = const [],
    this.blurs = const [],
    this.alerts = const [],
    this.informs = const [],
  });

  final bool noOverride;
  final List<ModerationCause> filters;
  final List<ModerationCause> blurs;
  final List<ModerationCause> alerts;
  final List<ModerationCause> informs;

  bool get filter => filters.isNotEmpty;
  bool get blur => blurs.isNotEmpty;
  bool get alert => alerts.isNotEmpty;
  bool get inform => informs.isNotEmpty;
}

class ModerationDecision {
  const ModerationDecision({required this.causes, this.me = false});

  const ModerationDecision.empty() : causes = const [], me = false;

  static ModerationDecision merge(List<ModerationDecision> decisions) {
    return ModerationDecision(causes: decisions.expand((decision) => decision.causes).toList(growable: false));
  }

  final List<ModerationCause> causes;
  final bool me;

  ModerationUI getUI(ModerationBehaviorContext context) {
    final filters = <ModerationCause>[];
    final blurs = <ModerationCause>[];
    final alerts = <ModerationCause>[];
    final informs = <ModerationCause>[];
    var noOverride = false;

    for (final cause in causes) {
      final behavior = cause.behaviorFor(context);
      if (cause.shouldFilter(context) && !me) {
        filters.add(cause);
      }
      switch (behavior) {
        case ModerationBehavior.blur:
          blurs.add(cause);
          noOverride = noOverride || cause.noOverride;
        case ModerationBehavior.alert:
          alerts.add(cause);
        case ModerationBehavior.inform:
          informs.add(cause);
        case ModerationBehavior.none:
          break;
      }
    }

    return ModerationUI(noOverride: noOverride, filters: filters, blurs: blurs, alerts: alerts, informs: informs);
  }
}

sealed class ModerationCause {
  const ModerationCause();

  const factory ModerationCause.blocking({required ModerationCauseBlocking data}) = UModerationCauseBlocking;
  const factory ModerationCause.blockedBy({required ModerationCauseBlockedBy data}) = UModerationCauseBlockedBy;
  const factory ModerationCause.blockOther({required ModerationCauseBlockOther data}) = UModerationCauseBlockOther;
  const factory ModerationCause.label({required ModerationCauseLabel data}) = UModerationCauseLabel;
  const factory ModerationCause.muted({required ModerationCauseMuted data}) = UModerationCauseMuted;
  const factory ModerationCause.muteWord({required ModerationCauseMuteWord data}) = UModerationCauseMuteWord;
  const factory ModerationCause.hidden({required ModerationCauseHidden data}) = UModerationCauseHidden;

  T maybeWhen<T>({
    T Function(ModerationCauseBlocking data)? blocking,
    T Function(ModerationCauseBlockedBy data)? blockedBy,
    T Function(ModerationCauseBlockOther data)? blockOther,
    T Function(ModerationCauseLabel data)? label,
    T Function(ModerationCauseMuted data)? muted,
    T Function(ModerationCauseMuteWord data)? muteWord,
    T Function(ModerationCauseHidden data)? hidden,
    required T Function() orElse,
  }) {
    return switch (this) {
      UModerationCauseBlocking(:final data) => blocking?.call(data) ?? orElse(),
      UModerationCauseBlockedBy(:final data) => blockedBy?.call(data) ?? orElse(),
      UModerationCauseBlockOther(:final data) => blockOther?.call(data) ?? orElse(),
      UModerationCauseLabel(:final data) => label?.call(data) ?? orElse(),
      UModerationCauseMuted(:final data) => muted?.call(data) ?? orElse(),
      UModerationCauseMuteWord(:final data) => muteWord?.call(data) ?? orElse(),
      UModerationCauseHidden(:final data) => hidden?.call(data) ?? orElse(),
    };
  }

  bool get noOverride => switch (this) {
    UModerationCauseLabel(:final data) => data.noOverride,
    UModerationCauseBlocking() || UModerationCauseBlockedBy() || UModerationCauseBlockOther() => true,
    _ => false,
  };

  bool shouldFilter(ModerationBehaviorContext context) {
    return switch (this) {
      UModerationCauseLabel(:final data) =>
        data.setting == LabelPreference.hide &&
            (context.isContentList || (context.isProfileList && data.target == LabelTarget.account)),
      UModerationCauseBlocking() ||
      UModerationCauseBlockedBy() ||
      UModerationCauseBlockOther() ||
      UModerationCauseMuted() ||
      UModerationCauseHidden() => context.isProfileList || context.isContentList,
      UModerationCauseMuteWord() => context.isContentList,
    };
  }

  ModerationBehavior behaviorFor(ModerationBehaviorContext context) {
    return switch (this) {
      UModerationCauseLabel(:final data) => data.behavior[context] ?? ModerationBehavior.none,
      UModerationCauseBlocking() ||
      UModerationCauseBlockedBy() ||
      UModerationCauseBlockOther() => _blockBehavior[context] ?? ModerationBehavior.none,
      UModerationCauseMuted() => _muteBehavior[context] ?? ModerationBehavior.none,
      UModerationCauseMuteWord() => _muteWordBehavior[context] ?? ModerationBehavior.none,
      UModerationCauseHidden() => _hideBehavior[context] ?? ModerationBehavior.none,
    };
  }
}

class UModerationCauseBlocking extends ModerationCause {
  const UModerationCauseBlocking({required this.data});
  final ModerationCauseBlocking data;
}

class UModerationCauseBlockedBy extends ModerationCause {
  const UModerationCauseBlockedBy({required this.data});
  final ModerationCauseBlockedBy data;
}

class UModerationCauseBlockOther extends ModerationCause {
  const UModerationCauseBlockOther({required this.data});
  final ModerationCauseBlockOther data;
}

class UModerationCauseLabel extends ModerationCause {
  const UModerationCauseLabel({required this.data});
  final ModerationCauseLabel data;
}

class UModerationCauseMuted extends ModerationCause {
  const UModerationCauseMuted({required this.data});
  final ModerationCauseMuted data;
}

class UModerationCauseMuteWord extends ModerationCause {
  const UModerationCauseMuteWord({required this.data});
  final ModerationCauseMuteWord data;
}

class UModerationCauseHidden extends ModerationCause {
  const UModerationCauseHidden({required this.data});
  final ModerationCauseHidden data;
}

class ModerationCauseBlocking {
  const ModerationCauseBlocking({required this.source});
  final ModerationCauseSource source;
}

class ModerationCauseBlockedBy {
  const ModerationCauseBlockedBy({required this.source});
  final ModerationCauseSource source;
}

class ModerationCauseBlockOther {
  const ModerationCauseBlockOther({required this.source});
  final ModerationCauseSource source;
}

class ModerationCauseMuted {
  const ModerationCauseMuted({required this.source});
  final ModerationCauseSource source;
}

class ModerationCauseMuteWord {
  const ModerationCauseMuteWord({required this.source});
  final ModerationCauseSource source;
}

class ModerationCauseHidden {
  const ModerationCauseHidden({required this.source});
  final ModerationCauseSource source;
}

class ModerationCauseLabel {
  const ModerationCauseLabel({
    required this.source,
    required this.label,
    required this.labelDef,
    required this.target,
    required this.setting,
    required this.behavior,
    this.noOverride = false,
  });

  final ModerationCauseSource source;
  final Label label;
  final InterpretedLabelValueDefinition labelDef;
  final LabelTarget target;
  final LabelPreference setting;
  final Map<ModerationBehaviorContext, ModerationBehavior> behavior;
  final bool noOverride;
}

sealed class ModerationCauseSource {
  const ModerationCauseSource();

  const factory ModerationCauseSource.user({required ModerationCauseSourceUser data}) = UModerationCauseSourceUser;
  const factory ModerationCauseSource.labeler({required ModerationCauseSourceLabeler data}) =
      UModerationCauseSourceLabeler;
}

class UModerationCauseSourceUser extends ModerationCauseSource {
  const UModerationCauseSourceUser({required this.data});
  final ModerationCauseSourceUser data;
}

class UModerationCauseSourceLabeler extends ModerationCauseSource {
  const UModerationCauseSourceLabeler({required this.data});
  final ModerationCauseSourceLabeler data;
}

class ModerationCauseSourceUser {
  const ModerationCauseSourceUser();
}

class ModerationCauseSourceLabeler {
  const ModerationCauseSourceLabeler({required this.did});
  final String did;
}

const _blockBehavior = {
  ModerationBehaviorContext.profileList: ModerationBehavior.blur,
  ModerationBehaviorContext.profileView: ModerationBehavior.alert,
  ModerationBehaviorContext.avatar: ModerationBehavior.blur,
  ModerationBehaviorContext.banner: ModerationBehavior.blur,
  ModerationBehaviorContext.contentList: ModerationBehavior.blur,
  ModerationBehaviorContext.contentView: ModerationBehavior.blur,
};

const _muteBehavior = {
  ModerationBehaviorContext.profileList: ModerationBehavior.inform,
  ModerationBehaviorContext.profileView: ModerationBehavior.alert,
  ModerationBehaviorContext.contentList: ModerationBehavior.blur,
  ModerationBehaviorContext.contentView: ModerationBehavior.inform,
};

const _muteWordBehavior = {
  ModerationBehaviorContext.contentList: ModerationBehavior.blur,
  ModerationBehaviorContext.contentView: ModerationBehavior.blur,
};

const _hideBehavior = {
  ModerationBehaviorContext.contentList: ModerationBehavior.blur,
  ModerationBehaviorContext.contentView: ModerationBehavior.blur,
};
