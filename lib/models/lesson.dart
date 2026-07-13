enum LessonContentType {
  heading,
  paragraph,
  keyPoint,
  example,
  tip,
  important,
  warning,
  quote,
  bulletList,
  numberedList,
  divider,
  summary,
  keyTakeaways,
  knowledgeCheck,
  image,
  video,
}

class LessonContentBlock {
  final String id;
  final LessonContentType type;
  final String title;
  final String content;
  final String? mediaUrl;
  final String? caption;
  final int sortOrder;
  final List<String> items;

  const LessonContentBlock({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.sortOrder,
    this.mediaUrl,
    this.caption,
    this.items = const [],
  });

  factory LessonContentBlock.fromJson(Map<String, dynamic> json) {
    return LessonContentBlock(
      id: json['id']?.toString().trim() ?? '',
      type: _parseContentType(json['type']),
      title: json['title']?.toString().trim() ?? '',
      content: json['content']?.toString().trim() ?? '',
      mediaUrl: _parseNullableString(json['mediaUrl']),
      caption: _parseNullableString(json['caption']),
      sortOrder: _parseInt(json['sortOrder']),
      items: _parseItems(json['items']),
    );
  }

  static LessonContentType _parseContentType(dynamic value) {
    final text = value?.toString().trim().toLowerCase();

    switch (text) {
      case 'heading':
        return LessonContentType.heading;

      case 'keypoint':
      case 'key_point':
      case 'key-point':
        return LessonContentType.keyPoint;

      case 'example':
        return LessonContentType.example;

      case 'tip':
        return LessonContentType.tip;

      case 'important':
        return LessonContentType.important;

      case 'warning':
        return LessonContentType.warning;

      case 'quote':
        return LessonContentType.quote;

      case 'bulletlist':
      case 'bullet_list':
      case 'bullet-list':
        return LessonContentType.bulletList;

      case 'numberedlist':
      case 'numbered_list':
      case 'numbered-list':
        return LessonContentType.numberedList;

      case 'divider':
        return LessonContentType.divider;

      case 'summary':
        return LessonContentType.summary;

      case 'keytakeaways':
      case 'key_takeaways':
      case 'key-takeaways':
        return LessonContentType.keyTakeaways;

      case 'knowledgecheck':
      case 'knowledge_check':
      case 'knowledge-check':
        return LessonContentType.knowledgeCheck;

      case 'image':
        return LessonContentType.image;

      case 'video':
        return LessonContentType.video;

      case 'paragraph':
      default:
        return LessonContentType.paragraph;
    }
  }

  static List<String> _parseItems(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String? _parseNullableString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }
}

class Lesson {
  final String id;

  final String branchId;
  final String programmeId;
  final String subjectId;
  final String topicId;

  final String title;
  final String summary;
  final String difficulty;

  final int estimatedMinutes;
  final int sortOrder;

  final bool isPremium;
  final bool isActive;

  final String? thumbnailAsset;
  final String? videoUrl;
  final String? questionCategory;

  final List<String> learningObjectives;
  final List<LessonContentBlock> contentBlocks;

  const Lesson({
    required this.id,
    required this.branchId,
    required this.programmeId,
    required this.subjectId,
    required this.topicId,
    required this.title,
    required this.summary,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.sortOrder,
    required this.isPremium,
    required this.isActive,
    required this.learningObjectives,
    required this.contentBlocks,
    this.thumbnailAsset,
    this.videoUrl,
    this.questionCategory,
  });

  bool get hasQuiz {
    return questionCategory != null && questionCategory!.trim().isNotEmpty;
  }

  bool get hasVideo {
    return videoUrl != null && videoUrl!.trim().isNotEmpty;
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final objectivesData = json['learningObjectives'];

    final contentData = json['contentBlocks'];

    final objectives = objectivesData is List
        ? objectivesData
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList()
        : <String>[];

    final contentBlocks = contentData is List
        ? contentData
              .whereType<Map>()
              .map(
                (item) => LessonContentBlock.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <LessonContentBlock>[];

    contentBlocks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Lesson(
      id: json['id']?.toString().trim() ?? '',
      branchId: json['branchId']?.toString().trim() ?? '',
      programmeId: json['programmeId']?.toString().trim() ?? '',
      subjectId: json['subjectId']?.toString().trim() ?? '',
      topicId: json['topicId']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? '',
      summary: json['summary']?.toString().trim() ?? '',
      difficulty: json['difficulty']?.toString().trim() ?? 'Beginner',
      estimatedMinutes: _parseInt(json['estimatedMinutes']),
      sortOrder: _parseInt(json['sortOrder']),
      isPremium: _parseBool(json['isPremium']),
      isActive: _parseBool(json['isActive'], defaultValue: true),
      thumbnailAsset: _parseNullableString(json['thumbnailAsset']),
      videoUrl: _parseNullableString(json['videoUrl']),
      questionCategory: _parseNullableString(json['questionCategory']),
      learningObjectives: objectives,
      contentBlocks: contentBlocks,
    );
  }

  static String? _parseNullableString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) {
      return defaultValue;
    }

    if (value is bool) {
      return value;
    }

    final text = value.toString().trim().toLowerCase();

    if (text == 'true' || text == '1' || text == 'yes') {
      return true;
    }

    if (text == 'false' || text == '0' || text == 'no') {
      return false;
    }

    return defaultValue;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }
}
