enum FileType {
  image,
  pdf,
  video,
  other,
}

class FileTypeHelper {
  
  static FileType getFileType(String url) {
    if (isPdf(url)) {
      return FileType.pdf;
    } else if (isVideo(url)) {
      return FileType.video;
    } else if (isImage(url)) {
      return FileType.image;
    } else {
      return FileType.other;
    }
  }

  static bool isImage(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.endsWith(ext) || lowerUrl.contains('$ext?'));
  }

  static bool isPdf(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.pdf') || lowerUrl.contains('.pdf?');
  }

  static bool isVideo(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv', '.wmv', '.m4v', '.3gp'];
    final lowerUrl = url.toLowerCase();
    return videoExtensions.any((ext) => lowerUrl.endsWith(ext) || lowerUrl.contains('$ext?'));
  }

  static String getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
      return 'File';
    } catch (e) {
      return 'File';
    }
  }

  static String getFileExtension(String url) {
    try {
      final fileName = getFileName(url);
      final lastDotIndex = fileName.lastIndexOf('.');
      if (lastDotIndex != -1 && lastDotIndex < fileName.length - 1) {
        return fileName.substring(lastDotIndex + 1).toUpperCase();
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
