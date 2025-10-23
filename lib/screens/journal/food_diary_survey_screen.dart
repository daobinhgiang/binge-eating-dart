import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_diary_provider.dart';
import '../../providers/todo_provider.dart';
import '../../models/food_diary.dart';
import '../../models/todo_item.dart';
import '../../core/services/openai_service.dart';
import '../../widgets/quest_completion_dialog.dart';
import '../../data/food_database.dart';

class FoodDiarySurveyScreen extends ConsumerStatefulWidget {
  const FoodDiarySurveyScreen({super.key});

  @override
  ConsumerState<FoodDiarySurveyScreen> createState() => _FoodDiarySurveyScreenState();
}

class _FoodDiarySurveyScreenState extends ConsumerState<FoodDiarySurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Form controllers and values
  final TextEditingController _foodController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  String _selectedLocation = FoodDiary.locationOptions.first;
  final TextEditingController _customLocationController = TextEditingController();
  bool _isBinge = false;
  String _purgeMethod = FoodDiary.purgeMethodOptions.first;
  final TextEditingController _contextController = TextEditingController();
  
  // Image capture and analysis
  final ImagePicker _imagePicker = ImagePicker();
  bool _isAnalyzingImage = false;
  final OpenAIService _openAIService = OpenAIService();
  
  // Food selection
  final TextEditingController _foodSearchController = TextEditingController();
  List<String> _searchResults = [];
  bool _showFoodSearch = false;

  @override
  void dispose() {
    _pageController.dispose();
    _foodController.dispose();
    _customLocationController.dispose();
    _contextController.dispose();
    _foodSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),
            
            // Content Section
            Expanded(
              child: _buildContent(context),
            ),
            
            // Footer Section
            _buildFooter(context),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with back button and title
          Row(
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black87,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    'Food Diary',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          LinearProgressIndicator(
            value: (_currentPage + 1) / 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildFoodAndDrinksQuestion(),
          _buildMealTimeQuestion(),
          _buildLocationQuestion(),
          _buildBingeQuestion(),
          _buildPurgeQuestion(),
          _buildContextQuestion(),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          
          if (_currentPage > 0) const SizedBox(width: 16),
          
          // Next/Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : (_currentPage < 5 ? _nextPage : _submitSurvey),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentPage < 5 ? 'Next' : 'Submit',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodAndDrinksQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'What food and drinks did you have?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please describe what you ate and drank during this meal or snack. Be as detailed as possible.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons row
          Row(
            children: [
              // Photo button for AI analysis
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isAnalyzingImage ? null : _showImageSourceDialog,
                  icon: _isAnalyzingImage
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(
                    _isAnalyzingImage ? 'Analyzing...' : 'Take Photo',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    side: BorderSide(
                      color: _isAnalyzingImage ? Colors.grey[400]! : Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Food search button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleFoodSearch,
                  icon: const Icon(Icons.search),
                  label: const Text(
                    'Search Foods',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(40.0),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _foodController,
              maxLines: 6,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'e.g., Chicken salad with lettuce, tomatoes, and ranch dressing. Glass of water.',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'SF Pro Text',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
          if (_isAnalyzingImage)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'AI is analyzing your food photo...',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  fontFamily: 'SF Pro Text',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Food search section
          if (_showFoodSearch) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(40.0),
                border: Border.all(
                  color: Colors.blue[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.search, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Search and Add Foods',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _toggleFoodSearch,
                        icon: Icon(Icons.close, color: Colors.blue[700]),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _foodSearchController,
                    onChanged: _onFoodSearchChanged,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for foods (e.g., "chicken", "apple")',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'SF Pro Text',
                      ),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        borderSide: BorderSide(color: Colors.blue[500]!, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_searchResults.isNotEmpty)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40.0),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final food = _searchResults[index];
                          return ListTile(
                            title: Text(
                              food,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                            trailing: const Icon(Icons.add, size: 20),
                            onTap: () => _selectFood(food),
                            dense: true,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildMealTimeQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What time did you have this meal?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select the time when you started eating this meal or snack.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(40.0),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Selected Time',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatDisplayTime(_selectedTime),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _selectTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.access_time, size: 18),
                  label: const Text(
                    'Change Time',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where did you have this meal?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'SF Pro Text',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select the location where you ate this meal.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'SF Pro Text',
              ),
            ),
            const SizedBox(height: 24),
            ...FoodDiary.locationOptions.map((location) {
              final isSelected = _selectedLocation == location;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    location,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: Colors.black87,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  value: location,
                  groupValue: _selectedLocation,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value!;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              );
            }),
            if (_selectedLocation == 'Other') ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _customLocationController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: 'Please specify location',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'SF Pro Text',
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBingeQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Was this a binge?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A binge is characterized by eating a large amount of food in a short period while feeling out of control.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBingeOption(true, 'Yes', 'This was a binge episode'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBingeOption(false, 'No', 'This was normal eating'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBingeOption(bool value, String title, String subtitle) {
    final isSelected = _isBinge == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isBinge = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(40.0),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                fontFamily: 'SF Pro Text',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'SF Pro Text',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurgeQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Did you vomit or use laxatives?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'SF Pro Text',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please select if you used any compensatory behaviors after this meal.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'SF Pro Text',
              ),
            ),
            const SizedBox(height: 24),
            ...FoodDiary.purgeMethodOptions.map((method) {
              final isSelected = _purgeMethod == method;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    _getPurgeMethodTitle(method),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: Colors.black87,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  subtitle: Text(
                    _getPurgeMethodSubtitle(method),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  value: method,
                  groupValue: _purgeMethod,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _purgeMethod = value!;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getPurgeMethodTitle(String method) {
    switch (method) {
      case 'none': return 'None';
      case 'vomit': return 'Vomiting';
      case 'laxatives': return 'Laxatives';
      case 'both': return 'Both';
      default: return method;
    }
  }

  String _getPurgeMethodSubtitle(String method) {
    switch (method) {
      case 'none': return 'No compensatory behaviors';
      case 'vomit': return 'I vomited after this meal';
      case 'laxatives': return 'I used laxatives after this meal';
      case 'both': return 'I vomited and used laxatives';
      default: return '';
    }
  }

  Widget _buildContextQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Context and comments',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please share any additional context about this meal - how you were feeling, what triggered it, or any other relevant details.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(40.0),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _contextController,
              maxLines: 6,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'e.g., I was feeling stressed after work. Ate quickly while watching TV. Felt guilty afterwards.',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'SF Pro Text',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      // Validate current page before proceeding
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // Food and drinks
        if (_foodController.text.trim().isEmpty) {
          _showValidationError('Please describe what food and drinks you had.');
          return false;
        }
        break;
      case 2: // Location
        if (_selectedLocation == 'Other' && _customLocationController.text.trim().isEmpty) {
          _showValidationError('Please specify the location.');
          return false;
        }
        break;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _formatDisplayTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _captureAndAnalyzeFood(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _captureAndAnalyzeFood(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureAndAnalyzeFood(ImageSource source) async {
    try {
      // Pick image from camera or gallery
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isAnalyzingImage = true;
      });

      String result;
      if (kIsWeb) {
        // For web, use bytes
        final bytes = await image.readAsBytes();
        result = await _openAIService.analyzeFoodImage(imageBytes: bytes);
      } else {
        // For mobile, use file
        final file = File(image.path);
        result = await _openAIService.analyzeFoodImage(imageFile: file);
      }

      if (mounted) {
        setState(() {
          _foodController.text = result;
          _isAnalyzingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food image analyzed successfully! You can edit the text if needed.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _onFoodSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = FoodDatabase.getPopularFoods();
      } else {
        _searchResults = FoodDatabase.searchFoods(query);
      }
    });
  }

  void _toggleFoodSearch() {
    setState(() {
      _showFoodSearch = !_showFoodSearch;
      if (_showFoodSearch) {
        _searchResults = FoodDatabase.getPopularFoods();
        _foodSearchController.clear();
      }
    });
  }

  void _selectFood(String food) {
    final currentText = _foodController.text.trim();
    if (currentText.isEmpty) {
      _foodController.text = food;
    } else {
      _foodController.text = '$currentText, $food';
    }
    
    // Close the search
    setState(() {
      _showFoodSearch = false;
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$food" to your food list'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle quest completion for food diary activity
  Future<void> _handleActivityCompletion() async {
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) return;
      
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleActivityCompletion(
        userId: user.id,
        activityId: 'food_diary',
        type: TodoType.journal,
        ref: ref,
      );
      
      if (result.questCompleted && mounted) {
        showQuestCompletionDialog(context, result);
      }
    } catch (e) {
      print('Error checking quest completion: $e');
    }
  }

  Future<void> _submitSurvey() async {
    if (!_validateCurrentPage()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      final entry = await ref.read(currentWeekFoodDiariesProvider(user.id).notifier).createEntry(
        foodAndDrinks: _foodController.text.trim(),
        mealTime: _selectedTime,
        location: _selectedLocation,
        customLocation: _selectedLocation == 'Other' ? _customLocationController.text.trim() : null,
        isBinge: _isBinge,
        purgeMethod: _purgeMethod,
        contextAndComments: _contextController.text.trim(),
      );

      if (entry != null && mounted) {
        // Check for quest completion
        await _handleActivityCompletion();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food diary entry saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to the journal tab after successful submission
        context.go('/journal');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
