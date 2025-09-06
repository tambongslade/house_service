import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:house_service/presentation/features/seeker/service_request/service_request_form_screen.dart';

class CategoryDescriptionScreen extends StatelessWidget {
  final String category;
  final String categoryDisplayName;

  const CategoryDescriptionScreen({
    super.key,
    required this.category,
    required this.categoryDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryData = _getCategoryData(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryDisplayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon and Header
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: categoryData['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _buildCategoryIcon(categoryData),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Title
            Center(
              child: Text(
                categoryDisplayName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About $categoryDisplayName',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    categoryData['description'] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // What's Included Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.blue.shade800,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'What\'s Typically Included',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...((categoryData['included'] as List<String>).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pricing Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pricing Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    categoryData['pricing'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Request Service Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _navigateToServiceRequest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Request $categoryDisplayName Service',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(Map<String, dynamic> categoryData) {
    if (categoryData['isSystemIcon'] == true) {
      final iconStr = categoryData['icon'] as String;
      IconData iconData;

      switch (iconStr) {
        case 'icons/more_horiz':
          iconData = Icons.more_horiz;
          break;
        case 'icons/local_florist':
          iconData = Icons.local_florist;
          break;
        case 'icons/build':
          iconData = Icons.build;
          break;
        case 'icons/restaurant':
          iconData = Icons.restaurant;
          break;
        case 'icons/school':
          iconData = Icons.school;
          break;
        case 'icons/miscellaneous_services':
          iconData = Icons.miscellaneous_services;
          break;
        default:
          iconData = Icons.help_outline;
      }

      return Icon(iconData, color: Colors.white, size: 48);
    } else if (categoryData['isSvg'] == true) {
      return SvgPicture.asset(
        categoryData['icon'] as String,
        width: 48,
        height: 48,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    } else {
      return Image.asset(
        categoryData['icon'] as String,
        width: 48,
        height: 48,
        color: Colors.white,
      );
    }
  }

  void _navigateToServiceRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceRequestFormScreen(
          category: category,
          categoryDisplayName: categoryDisplayName,
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return {
          'icon': 'assets/images/cleaning.svg',
          'color': const Color(0xFFFFE187),
          'isSvg': true,
          'description': 'Professional cleaning services for your home or office. Our certified cleaners use eco-friendly products and modern equipment to ensure your space is spotless and hygienic.',
          'included': [
            'Deep cleaning of all rooms',
            'Kitchen and bathroom sanitization',
            'Floor mopping and vacuuming',
            'Dust removal from surfaces',
            'Window cleaning (interior)',
            'Trash removal',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Pricing may vary based on space size and specific requirements.',
        };
      case 'plumbing':
        return {
          'icon': 'assets/images/plumbing.svg',
          'color': const Color(0xFFD8F799),
          'isSvg': true,
          'description': 'Expert plumbing services for repairs, installations, and maintenance. Our licensed plumbers handle everything from leaky faucets to complete pipe installations.',
          'included': [
            'Leak detection and repair',
            'Pipe installation and replacement',
            'Toilet and sink repairs',
            'Drain cleaning and unclogging',
            'Water heater maintenance',
            'Emergency plumbing services',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Additional charges may apply for parts and materials.',
        };
      case 'electrical':
        return {
          'icon': 'assets/images/electronics.png',
          'color': const Color(0xFFFF9E9E),
          'isSvg': false,
          'description': 'Certified electrical services for safe and reliable installations, repairs, and maintenance. Our electricians are trained to handle residential and commercial electrical work.',
          'included': [
            'Wiring installation and repair',
            'Light fixture installation',
            'Socket and switch replacement',
            'Circuit breaker maintenance',
            'Electrical safety inspections',
            'Emergency electrical services',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Costs for electrical components are additional.',
        };
      case 'painting':
        return {
          'icon': 'assets/images/painting.svg',
          'color': const Color(0xFFC1F4DC),
          'isSvg': true,
          'description': 'Professional painting services to transform your space. Our painters use premium paints and techniques to deliver beautiful, long-lasting results.',
          'included': [
            'Surface preparation and priming',
            'Interior and exterior painting',
            'Wall texture repair',
            'Paint color consultation',
            'Clean-up after completion',
            'Quality paint and materials',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Paint and materials are included in the base price.',
        };
      case 'gardening':
        return {
          'icon': 'icons/local_florist',
          'color': const Color(0xFF38B2AC),
          'isSvg': false,
          'isSystemIcon': true,
          'description': 'Comprehensive gardening and landscaping services to maintain and beautify your outdoor spaces. Our gardeners are experienced with local plants and climate.',
          'included': [
            'Lawn mowing and trimming',
            'Plant care and maintenance',
            'Garden design and layout',
            'Pest control for plants',
            'Seasonal planting',
            'Garden cleanup and maintenance',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Seeds and plants are additional costs.',
        };
      case 'carpentry':
        return {
          'icon': 'icons/build',
          'color': const Color(0xFFD2B48C),
          'isSvg': false,
          'isSystemIcon': true,
          'description': 'Skilled carpentry services for furniture making, repairs, and custom woodwork. Our carpenters use quality materials and traditional techniques.',
          'included': [
            'Custom furniture creation',
            'Furniture repair and restoration',
            'Cabinet installation',
            'Door and window frame work',
            'Shelving and storage solutions',
            'Wood finishing and staining',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Wood materials and hardware are additional.',
        };
      case 'cooking':
        return {
          'icon': 'icons/restaurant',
          'color': const Color(0xFFFFB347),
          'isSvg': false,
          'isSystemIcon': true,
          'description': 'Professional cooking services for events, daily meals, or special occasions. Our chefs specialize in local and international cuisines.',
          'included': [
            'Meal planning and preparation',
            'Grocery shopping for ingredients',
            'Cooking and presentation',
            'Kitchen cleanup after service',
            'Special dietary accommodations',
            'Recipe consultation',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Ingredients and groceries are additional costs.',
        };
      case 'tutoring':
        return {
          'icon': 'icons/school',
          'color': const Color(0xFFADD8E6),
          'isSvg': false,
          'isSystemIcon': true,
          'description': 'Quality tutoring services for students of all ages. Our tutors are qualified in various subjects and teaching methods.',
          'included': [
            'Personalized lesson planning',
            'Subject-specific instruction',
            'Homework and assignment help',
            'Exam preparation',
            'Progress tracking and reports',
            'Study materials and resources',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. All materials and resources included.',
        };
      case 'beauty':
        return {
          'icon': 'assets/images/babysitting.svg',
          'color': const Color(0xFFF8BBE3),
          'isSvg': true,
          'description': 'Professional beauty and personal care services in the comfort of your home. Our certified beauticians provide a range of treatments.',
          'included': [
            'Hair cutting and styling',
            'Makeup application',
            'Manicure and pedicure',
            'Facial treatments',
            'Eyebrow shaping',
            'Beauty consultation',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Premium products available at additional cost.',
        };
      case 'maintenance':
        return {
          'icon': 'assets/images/appliance.svg',
          'color': const Color(0xFFB3E4FF),
          'isSvg': true,
          'description': 'General maintenance and repair services for your home or office. Our technicians handle various types of equipment and systems.',
          'included': [
            'Appliance repair and maintenance',
            'HVAC system servicing',
            'General handyman services',
            'Preventive maintenance checks',
            'Equipment troubleshooting',
            'Minor repairs and fixes',
          ],
          'pricing': 'Starting from 3,000 FCFA for a 4-hour session. Replacement parts charged separately.',
        };
      default:
        return {
          'icon': 'icons/miscellaneous_services',
          'color': const Color(0xFFE0E0E0),
          'isSvg': false,
          'isSystemIcon': true,
          'description': 'Miscellaneous services tailored to your specific needs. Contact us to discuss your requirements.',
          'included': [
            'Custom service planning',
            'Consultation and assessment',
            'Flexible service delivery',
            'Quality assurance',
          ],
          'pricing': 'Pricing varies based on specific service requirements. Contact for detailed quote.',
        };
    }
  }
}