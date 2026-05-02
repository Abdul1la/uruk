import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

/// Central upload layer used by every screen that needs to push an image
/// (ID, accident photos, repair photos, payment proof, car image, …).
///
/// Uses the real backend multipart upload endpoint via [ApiService].
/// Cross-platform — accepts [XFile] from image_picker so the same code path
/// works on iOS, Android, and Flutter web.
class UploadService {
  static final UploadService _instance = UploadService._();
  factory UploadService() => _instance;
  UploadService._();

  final _api = ApiService();

  /// Upload a single [XFile] and return its remote URL.
  ///
  /// [folder] — logical bucket ("ids", "accidents", "repairs", "payments", "cars").
  Future<String> upload(XFile file, {required String folder}) async {
    final urls = await _api.uploadFiles([file], folder: folder);
    return urls.first;
  }

  /// Upload many [XFile]s in parallel and return their remote URLs in order.
  Future<List<String>> uploadMany(
    List<XFile> files, {
    required String folder,
  }) async {
    if (files.isEmpty) return const [];
    return _api.uploadFiles(files, folder: folder);
  }
}
