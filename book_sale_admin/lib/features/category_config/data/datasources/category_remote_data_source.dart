import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../../core/api_client.dart';
import '../../../../core/constants.dart';
import '../models/category_model.dart';
import '../models/education_config_model.dart';

abstract class CategoryRemoteDataSource {
  Future<EducationConfigModel> getConfig();
  Future<void> saveConfig(EducationConfigModel config);

  // Listing Categories
  Future<List<CategoryModel>> getCategories({bool includeInactive = true});
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? icon,
    int? displayOrder,
    Uint8List? imageBytes,
    bool hasEducationConfig = false,
  });
  Future<CategoryModel> updateCategory({
    required String id,
    String? name,
    String? description,
    String? icon,
    int? displayOrder,
    Uint8List? imageBytes,
    bool hasEducationConfig = false,
  });
  Future<void> deleteCategory(String id);
  Future<void> toggleCategoryStatus(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;
  CategoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<EducationConfigModel> getConfig() async {
    final response = await apiClient.dio.get(ApiConstants.educationConfig);
    if (response.data['success'] != true) {
      throw Exception('Failed to load config');
    }
    return EducationConfigModel.fromJson(response.data['data'] ?? {});
  }

  @override
  Future<void> saveConfig(EducationConfigModel config) async {
    await apiClient.dio.put(
      ApiConstants.adminEducationConfig,
      data: config.toJson(),
    );
  }

  @override
  Future<List<CategoryModel>> getCategories({
    bool includeInactive = true,
  }) async {
    final response = await apiClient.dio.get(
      ApiConstants.categories,
      queryParameters: {'includeInactive': includeInactive},
    );
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load categories');
  }

  @override
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? icon,
    int? displayOrder,
    Uint8List? imageBytes,
    bool hasEducationConfig = false,
  }) async {
    final Map<String, dynamic> map = {
      'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (displayOrder != null) 'displayOrder': displayOrder,
      'hasEducationConfig': hasEducationConfig.toString(),
    };

    if (imageBytes != null) {
      map['image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: 'category.jpg',
      );
    }

    final formData = FormData.fromMap(map);

    final response = await apiClient.dio.post(
      ApiConstants.adminCategories,
      data: formData,
    );

    if (response.data['success'] == true) {
      return CategoryModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create category');
  }

  @override
  Future<CategoryModel> updateCategory({
    required String id,
    String? name,
    String? description,
    String? icon,
    int? displayOrder,
    Uint8List? imageBytes,
    bool hasEducationConfig = false,
  }) async {
    final Map<String, dynamic> map = {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (displayOrder != null) 'displayOrder': displayOrder,
      'hasEducationConfig': hasEducationConfig.toString(),
    };

    if (imageBytes != null) {
      map['image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: 'category.jpg',
      );
    }

    final formData = FormData.fromMap(map);

    final response = await apiClient.dio.put(
      '${ApiConstants.adminCategories}/$id',
      data: formData,
    );

    if (response.data['success'] == true) {
      return CategoryModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update category');
  }

  @override
  Future<void> deleteCategory(String id) async {
    final response = await apiClient.dio.delete(
      '${ApiConstants.adminCategories}/$id',
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete category');
    }
  }

  @override
  Future<void> toggleCategoryStatus(String id) async {
    final response = await apiClient.dio.patch(
      '${ApiConstants.adminCategories}/$id/toggle',
    );
    if (response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Failed to toggle category status',
      );
    }
  }
}
