/// Light / water hints for the environmental card (wellness copy, not horticultural advice).
class PlantCareMeta {
  final String lightLabel;
  final String waterLabel;

  const PlantCareMeta(this.lightLabel, this.waterLabel);
}

class PlantSuggestionDatabase {
  PlantSuggestionDatabase._();

  static const _defaultPlantName = 'Pothos';
  static const _defaultPlantDescription =
      'Low-maintenance indoor vine that adapts to typical room light.';
  static const _defaultImageUrl =
      'https://upload.wikimedia.org/wikipedia/commons/4/4a/Epipremnum_aureum_31082012.jpg';
  static const _defaultReferenceUrl =
      'https://en.wikipedia.org/wiki/Epipremnum_aureum';
  static const _defaultAssetPath = 'assets/plants/pothos.jpg';

  static const Map<String, String> _emotionToPlant = {
    'anger': 'Snake Plant - Resilient indoor plant with upright form; easy-care and drought tolerant.',
    'disgust': 'ZZ Plant - Glossy foliage, robust in low-to-medium light, and forgiving watering needs.',
    'fear': 'Lavender - Aromatic plant often used in calm-focused spaces; prefers bright light.',
    'joy': 'Aloe Vera - Bright-space succulent with simple care and strong indoor popularity.',
    'neutral': 'Pothos - Low-maintenance indoor vine that adapts to typical room light.',
    'sadness': 'Peace Lily - Shade-tolerant flowering houseplant with soft foliage and white blooms.',
    'surprise': 'Pothos - Fast-growing vine that is beginner-friendly and adaptable indoors.',
  };

  static const Map<String, String> _emotionToImageUrl = {
    'anger': 'https://upload.wikimedia.org/wikipedia/commons/0/01/Sansevieria_trifasciata.jpg',
    'disgust': 'https://upload.wikimedia.org/wikipedia/commons/f/f1/Zamioculcas_zamiifolia.jpg',
    'fear': 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Lavandula_angustifolia_002.JPG',
    'joy': 'https://upload.wikimedia.org/wikipedia/commons/c/c2/Aloe_vera_flower_inset.png',
    'neutral': _defaultImageUrl,
    'sadness': 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Spathiphyllum_cochlearispathum_RTBG.jpg',
    'surprise': _defaultImageUrl,
  };

  static const Map<String, String> _emotionToAssetPath = {
    'anger': 'assets/plants/snake_plant.jpg',
    'disgust': 'assets/plants/zz_plant.jpg',
    'fear': 'assets/plants/lavender.jpg',
    'joy': 'assets/plants/aloe_vera.jpg',
    'neutral': 'assets/plants/pothos.jpg',
    'sadness': 'assets/plants/peace_lily.jpg',
    'surprise': 'assets/plants/pothos.jpg',
  };

  static const Map<String, String> _emotionToReferenceUrl = {
    'anger': 'https://en.wikipedia.org/wiki/Dracaena_trifasciata',
    'disgust': 'https://en.wikipedia.org/wiki/Zamioculcas',
    'fear': 'https://en.wikipedia.org/wiki/Lavandula',
    'joy': 'https://en.wikipedia.org/wiki/Aloe_vera',
    'neutral': _defaultReferenceUrl,
    'sadness': 'https://en.wikipedia.org/wiki/Spathiphyllum',
    'surprise': _defaultReferenceUrl,
  };

  static String suggestionForEmotion(String? moodLabel) {
    final mood = (moodLabel ?? '').toLowerCase();
    for (final entry in _emotionToPlant.entries) {
      if (mood.contains(entry.key)) return entry.value;
    }
    return '$_defaultPlantName - $_defaultPlantDescription';
  }

  static String imageUrlForEmotion(String? moodLabel) {
    final mood = (moodLabel ?? '').toLowerCase();
    for (final entry in _emotionToImageUrl.entries) {
      if (mood.contains(entry.key)) return entry.value;
    }
    return _defaultImageUrl;
  }

  static String referenceUrlForEmotion(String? moodLabel) {
    final mood = (moodLabel ?? '').toLowerCase();
    for (final entry in _emotionToReferenceUrl.entries) {
      if (mood.contains(entry.key)) return entry.value;
    }
    return _defaultReferenceUrl;
  }

  static String assetPathForEmotion(String? moodLabel) {
    final mood = (moodLabel ?? '').toLowerCase();
    for (final entry in _emotionToAssetPath.entries) {
      if (mood.contains(entry.key)) return entry.value;
    }
    return _defaultAssetPath;
  }

  /// Care hints from common name substrings (matches API / local suggestion names).
  static PlantCareMeta careMetaForPlantName(String plantName) {
    final n = plantName.toLowerCase();
    if (n.contains('lavender')) {
      return const PlantCareMeta('Bright indirect light', 'Moderate water');
    }
    if (n.contains('snake')) {
      return const PlantCareMeta('Low to bright indirect', 'Low — drought tolerant');
    }
    if (n.contains('zz')) {
      return const PlantCareMeta('Low to medium light', 'Low — forgiving');
    }
    if (n.contains('aloe')) {
      return const PlantCareMeta('Bright light', 'Low — let soil dry between waterings');
    }
    if (n.contains('peace')) {
      return const PlantCareMeta('Medium indirect light', 'Moderate water');
    }
    if (n.contains('pothos')) {
      return const PlantCareMeta('Low to bright indirect', 'Moderate water');
    }
    return const PlantCareMeta('Indirect light', 'Moderate water');
  }
}
