import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/loading_animation/category_loading.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/category.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/quiz/category_quiz.dart';
import 'package:taga_cuyo/src/features/services/category_service.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with AutomaticKeepAliveClientMixin<CategoryScreen> {
  List<Category> categories = [];
  final CategoryService _categoryService = CategoryService();
  String? userId;
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
    fetchCategories();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> fetchCurrentUserId() async {
    userId = await _categoryService.fetchCurrentUserId();
    if (userId == null) {
      Logger.log("User is not logged in");
    }
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true; // Show loading while fetching
    });
    try {
      List<Category> fetchedCategories =
          await _categoryService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      Logger.log("Error fetching categories: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateCompletedData(Category category) async {
    setState(() {
      isLoading = true;
    });
    try {
      final updatedCategories = await _categoryService.fetchCategories();
      setState(() {
        categories = updatedCategories;
        isLoading = false;
      });
    } catch (e) {
      Logger.log("Error updating completed data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: isLoading
          ? const LoadingShimmerCategory() // Custom loading shimmer
          : _categoryContainer(categories),
    );
  }

  Widget _categoryContainer(List<Category> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _categoryCard(categories[index]);
      },
    );
  }

  Widget _categoryCard(Category category) {
    return FutureBuilder<int>(
      future: _categoryService.getCompletedSubcategoriesCount(
          userId!, category.id), // Fetch the count
      builder: (context, snapshot) {
        int completedCount = snapshot.data ?? 0; // Get the completed count
        return Container(
          height: MediaQuery.of(context).size.height * 0.277,
          decoration: const BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(width: 3, color: Color.fromARGB(255, 96, 96, 96)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      capitalizeFirstLetter(category.id),
                      style: const TextStyle(
                        fontFamily: AppFonts.fcb,
                        fontSize: 21,
                      ),
                    ),
                    Text(
                      '$completedCount/${category.subcategories.length}',
                      style: const TextStyle(
                        fontFamily: AppFonts.fcr,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _subcategoryList(category),
            ],
          ),
        );
      },
    );
  }

  Widget _subcategoryList(Category category) {
    return FutureBuilder<List<String>>(
      future: _categoryService.getCompletedSubcategories(
        userId: userId ?? '',
        categoryId: category.id,
      ),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error loading subcategories');
        } else if (snapshot.hasData) {
          List<String> completedSubcategories = snapshot.data!;

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: category.subcategories.map((subcategory) {
                    return SubcategoryCard(
                      subcategory: subcategory,
                      userId: userId ?? '',
                      category: category,
                      completedSubcategories: completedSubcategories,
                      onCompleted: () => updateCompletedData(category),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        } else {
          return const Text('No subcategories available');
        }
      },
    );
  }
}

class SubcategoryCard extends StatelessWidget {
  final Subcategory subcategory;
  final String userId;
  final Category category;
  final List<String> completedSubcategories;
  final VoidCallback onCompleted;

  const SubcategoryCard({
    super.key,
    required this.subcategory,
    required this.userId,
    required this.category,
    required this.completedSubcategories,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the subcategory is completed
    bool isCompleted = completedSubcategories.contains(subcategory.id);

    final contentWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryQuizScreen(
              subcategoryTitle: subcategory.name,
              categoryId: category.id, // Use the category's id
              currentWord: '',
              subcategoryId: subcategory.id,
              userId: userId,
            ),
          ),
        );
        onCompleted(); // Refresh data on return from CategoryQuizScreen
      },
      child: SizedBox(
        width: contentWidth * 0.33, // 33% of the screen width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    width: 6,
                    color: isCompleted ? Colors.green : AppColors.accentColor),
                borderRadius: BorderRadius.circular(20),
              ),
              width: contentWidth * 0.27, // image size
              height: contentWidth * 0.27, // 30% of the screen width for height
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: subcategory.imagePath.isNotEmpty
                    ? Image.network(
                        subcategory.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Imahe ay hindi magagamit'),
                          );
                        },
                      )
                    : const Center(child: Text('Imahe ay hindi magagamit')),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: contentWidth * 0.15,
              child: Text(
                capitalizeFirstLetter(subcategory.name),
                style: TextStyle(
                  fontFamily: AppFonts.fcr,
                  fontSize: contentWidth * 0.049,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
