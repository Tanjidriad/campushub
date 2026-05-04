import 'dart:io';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../listings/data/models/listing_model.dart';

/// Abstract datasource for creating listings
abstract class CreateListingRemoteDataSource {
  Future<ListingModel> createListing({
    required String title,
    required String description,
    required String category,
    required String priceType,
    double? price,
    String? condition,
    String? locationName,
    String? meetupPreferences,
    required List<String> imagePaths,
    String? educationLevel,
    String? stream,
    String? department,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  });
}

/// Implementation of CreateListingRemoteDataSource
class CreateListingRemoteDataSourceImpl
    implements CreateListingRemoteDataSource {
  final ApiClient apiClient;

  CreateListingRemoteDataSourceImpl({required this.apiClient});

  /// Silently try to get GPS coordinates. Returns null on any failure.
  Future<Position?> _tryGetPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ListingModel> createListing({
    required String title,
    required String description,
    required String category,
    required String priceType,
    double? price,
    String? condition,
    String? locationName,
    String? meetupPreferences,
    required List<String> imagePaths,
    String? educationLevel,
    String? stream,
    String? department,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData();

      // Add text fields
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('category', category),
        MapEntry('priceType', priceType),
      ]);

      if (price != null) {
        formData.fields.add(MapEntry('price', price.toString()));
      }
      if (condition != null) {
        formData.fields.add(MapEntry('condition', condition));
      }
      if (locationName != null) {
        formData.fields.add(MapEntry('location[name]', locationName));
      }

      // Auto-capture GPS coordinates (silent — won't block if permission denied)
      final position = await _tryGetPosition();
      if (position != null) {
        formData.fields.add(MapEntry('location[type]', 'Point'));
        formData.fields.add(
          MapEntry('location[coordinates][0]', position.longitude.toString()),
        );
        formData.fields.add(
          MapEntry('location[coordinates][1]', position.latitude.toString()),
        );
      }

      if (meetupPreferences != null) {
        formData.fields.add(MapEntry('meetupPreferences', meetupPreferences));
      }
      if (educationLevel != null) {
        formData.fields.add(MapEntry('educationLevel', educationLevel));
      }
      if (stream != null) {
        formData.fields.add(MapEntry('stream', stream));
      }
      if (department != null) {
        formData.fields.add(MapEntry('department', department));
      }
      if (classOrSemester != null) {
        formData.fields.add(MapEntry('classOrSemester', classOrSemester));
      }
      if (subject != null) {
        formData.fields.add(MapEntry('subject', subject));
      }
      if (bookType != null) {
        formData.fields.add(MapEntry('bookType', bookType));
      }
      if (division != null) {
        formData.fields.add(MapEntry('division', division));
      }
      if (district != null) {
        formData.fields.add(MapEntry('district', district));
      }
      if (upazila != null) {
        formData.fields.add(MapEntry('upazila', upazila));
      }

      // Add images
      for (final imagePath in imagePaths) {
        final file = File(imagePath);
        if (await file.exists()) {
          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                imagePath,
                filename: imagePath.split('/').last,
              ),
            ),
          );
        }
      }

      final response = await apiClient.post(
        ApiConstants.listing,
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ListingModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to create listing',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
