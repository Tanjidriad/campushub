import 'package:book_user_app/core/network/api_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get('/categories');
    final data = response.data;

    // Handle both List and Map responses
    if (data is List) {
      return CategoryModel.fromJsonList(data);
    } else if (data is Map<String, dynamic>) {
      // Backend returns { success: true, data: [...] }
      if (data['data'] != null && data['data'] is List) {
        return CategoryModel.fromJsonList(data['data'] as List);
      }
      // Fallback: if response has categories key
      if (data['categories'] != null) {
        return CategoryModel.fromJsonList(data['categories'] as List);
      }
      // If response is a single category wrapped in object
      if (data['_id'] != null) {
        return [CategoryModel.fromJson(data)];
      }
    }

    return [];
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    final response = await _apiClient.get('/categories/$id');
    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data['category'] != null) {
        return CategoryModel.fromJson(data['category'] as Map<String, dynamic>);
      }
      return CategoryModel.fromJson(data);
    }

    throw Exception('Invalid response format');
  }
}
