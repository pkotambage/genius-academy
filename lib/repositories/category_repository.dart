import '../models/quiz_category.dart';
import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService _categoryService;

  CategoryRepository({CategoryService? categoryService})
    : _categoryService = categoryService ?? CategoryService();

  Future<List<QuizCategory>> getCategories() {
    return _categoryService.loadCategories();
  }

  Future<QuizCategory?> getCategoryById(String id) {
    return _categoryService.getCategoryById(id);
  }

  Future<List<QuizCategory>> getFreeCategories() {
    return _categoryService.loadFreeCategories();
  }

  Future<List<QuizCategory>> getPremiumCategories() {
    return _categoryService.loadPremiumCategories();
  }
}
