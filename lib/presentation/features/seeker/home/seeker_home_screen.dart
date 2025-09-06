import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:house_service/l10n/app_localizations.dart';
import 'package:house_service/core/state/app_state.dart';
import 'package:house_service/presentation/features/seeker/categories/category_description_screen.dart';

class SeekerHomeScreen extends StatefulWidget {
  const SeekerHomeScreen({super.key});

  @override
  State<SeekerHomeScreen> createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends State<SeekerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _apiServices = [];
  bool _loadingServices = true;
  // Removed provider-related state variables

  // --- Updated Service Data with actual images and colors ---
  static const List<Map<String, dynamic>> _services = [
    {
      'icon': 'assets/images/babysitting.svg',
      'label': 'Babysitting',
      'color': Color(0xFFF8BBE3), // Pink
      'isSvg': true,
    },
    {
      'icon': 'assets/images/cleaning.svg',
      'label': 'Cleaning',
      'color': Color(0xFFFFE187), // Yellow
      'isSvg': true,
    },
    {
      'icon': 'assets/images/ac repair.png',
      'label': 'AC Repair',
      'color': Color(0xFFFFC8AA), // Light Orange
      'isSvg': false,
    },
    {
      'icon': 'assets/images/electronics.png',
      'label': 'Electronics',
      'color': Color(0xFFFF9E9E), // Coral
      'isSvg': false,
    },
    {
      'icon': 'assets/images/painting.svg',
      'label': 'Painting',
      'color': Color(0xFFC1F4DC), // Mint
      'isSvg': true,
    },
    {
      'icon': 'assets/images/plumbing.svg',
      'label': 'Plumbing',
      'color': Color(0xFFD8F799), // Light Green
      'isSvg': true,
    },
    {
      'icon': 'assets/images/appliance.svg',
      'label': 'Appliance',
      'color': Color(0xFFB3E4FF), // Light Blue
      'isSvg': true,
    },
    {
      'icon': 'icons/more', // Using system icon for More
      'label': 'More',
      'color': Color(0xFF9DCEFF), // Medium Blue
      'isSvg': false,
      'isSystemIcon': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Removed provider-related scroll and rating methods

  Future<void> _fetchServices() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.apiService.getServiceCategories();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        // Get current locale to determine which categories to use
        final locale = Localizations.localeOf(context);
        final isFrench = locale.languageCode == 'fr';

        final categories = response.data!['categories'] as List<dynamic>?;
        final categoriesFr = response.data!['categoriesFr'] as List<dynamic>?;

        // Choose appropriate categories based on locale
        final categoriesToUse =
            isFrench && categoriesFr != null ? categoriesFr : categories;

        if (categoriesToUse != null) {
          setState(() {
            _apiServices =
                categoriesToUse
                    .map((category) => {'name': category.toString()})
                    .toList();
            _loadingServices = false;
          });
        } else {
          setState(() {
            _loadingServices = false;
          });
        }
      } else {
        setState(() {
          _loadingServices = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingServices = false;
      });
    }
  }

  // Removed _fetchFeaturedProviders method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHomeAppBar(context),
      body: _buildHomeTabContent(context),
    );
  }

  PreferredSizeWidget _buildHomeAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Get current time to show appropriate greeting
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 12 && hour < 17) {
      greeting = AppLocalizations.of(context)!.goodAfternoon;
    } else if (hour >= 17) {
      greeting = AppLocalizations.of(context)!.goodEvening;
    } else {
      greeting = AppLocalizations.of(context)!.goodMorning;
    }

    return AppBar(
      leading: Consumer<AppState>(
        builder: (context, appState, _) {
          final user = appState.user;
          final userName = user?.fullName ?? 'Guest';

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: colors.secondaryContainer,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                style: TextStyle(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      title: Consumer<AppState>(
        builder: (context, appState, _) {
          final user = appState.user;
          final userName = user?.fullName ?? 'Guest';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    greeting,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.waving_hand, color: Colors.amber, size: 16),
                ],
              ),
              Text(
                userName,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // IconButton(
        //   icon: Icon(Icons.notifications_none, color: colors.onSurfaceVariant),
        //   onPressed: () {
        //     /* TODO: Navigate to notifications */
        //   },
        // ),
        // IconButton(
        //   icon: Icon(Icons.menu, color: colors.onSurfaceVariant),
        //   onPressed: () {
        //     /* TODO: Open menu */
        //   },
        // ),
        const SizedBox(width: 8),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildServiceIcon(Map<String, dynamic> service) {
    if (service['isSystemIcon'] == true) {
      // System icon - map from string to IconData
      final iconStr = service['icon'] as String;
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

      return Icon(iconData, color: Colors.indigo.shade800, size: 28);
    } else if (service['isSvg'] == true) {
      // SVG icon
      return SvgPicture.asset(
        service['icon'] as String,
        width: 30,
        height: 30,
        colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
      );
    } else {
      // PNG or other image formats
      return Image.asset(service['icon'] as String, width: 28, height: 28);
    }
  }

  // Add the missing _buildSectionHeader method
  Widget _buildSectionHeader(
    String title,
    VoidCallback onSeeAllPressed,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // TextButton(onPressed: onSeeAllPressed, child: const Text('See All')),
      ],
    );
  }

  Widget _buildHomeTabContent(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Special Offers Section ---
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildSectionHeader(
                AppLocalizations.of(context)!.specialOffers,
                () {
                  /* TODO: Navigate to all offers */
                },
                context,
              ),
            ),
            const SizedBox(height: 12),

            // Special Offer Card
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Color(0xFFF9933E), // More accurate orange color
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    width: 200,
                    child: Image.asset(
                      'assets/images/image 87.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image fails to load
                        return Container(color: Colors.orange.shade300);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "30%",
                          style: textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Today's Special!",
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Get discount for every order",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 3; i++)
                          Container(
                            width: i == 0 ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color:
                                  i == 0
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Search Bar ---
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchForServices,
                prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              onSubmitted: (value) {
                /* TODO: Handle search */
              },
            ),
            const SizedBox(height: 24),

            // --- Services Grid ---
            _buildSectionHeader(AppLocalizations.of(context)!.services, () {
              /* TODO: Navigate to all services */
            }, context),
            const SizedBox(height: 16),
            _loadingServices
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                : _buildServicesGrid(textTheme),
            const SizedBox(height: 24),

            // --- End of Home Content ---
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _mapCategoryToService(String category) {
    // Map French categories to English equivalents for navigation
    String normalizedCategory = _getFrenchToEnglishMapping(
      category.toLowerCase(),
    );

    switch (normalizedCategory) {
      case 'cleaning':
        return {
          'label': category, // Keep original display name
          'englishCategory': 'cleaning', // For navigation
          'icon': 'assets/images/cleaning.svg',
          'color': const Color(0xFFFFE187),
          'isSvg': true,
        };
      case 'plumbing':
        return {
          'label': category,
          'englishCategory': 'plumbing',
          'icon': 'assets/images/plumbing.svg',
          'color': const Color(0xFFD8F799),
          'isSvg': true,
        };
      case 'electrical':
        return {
          'label': category,
          'englishCategory': 'electrical',
          'icon': 'assets/images/electronics.png',
          'color': const Color(0xFFFF9E9E),
          'isSvg': false,
        };
      case 'painting':
        return {
          'label': category,
          'englishCategory': 'painting',
          'icon': 'assets/images/painting.svg',
          'color': const Color(0xFFC1F4DC),
          'isSvg': true,
        };
      case 'gardening':
        return {
          'label': category,
          'englishCategory': 'gardening',
          'icon': 'icons/local_florist',
          'color': const Color(0xFF38B2AC),
          'isSvg': false,
          'isSystemIcon': true,
        };
      case 'carpentry':
        return {
          'label': category,
          'englishCategory': 'carpentry',
          'icon': 'icons/build',
          'color': const Color(0xFFD2B48C),
          'isSvg': false,
          'isSystemIcon': true,
        };
      case 'cooking':
        return {
          'label': category,
          'englishCategory': 'cooking',
          'icon': 'icons/restaurant',
          'color': const Color(0xFFFFB347),
          'isSvg': false,
          'isSystemIcon': true,
        };
      case 'tutoring':
        return {
          'label': category,
          'englishCategory': 'tutoring',
          'icon': 'icons/school',
          'color': const Color(0xFFADD8E6),
          'isSvg': false,
          'isSystemIcon': true,
        };
      case 'beauty':
        return {
          'label': category,
          'englishCategory': 'beauty',
          'icon': 'assets/images/babysitting.svg',
          'color': const Color(0xFFF8BBE3),
          'isSvg': true,
        };
      case 'maintenance':
        return {
          'label': category,
          'englishCategory': 'maintenance',
          'icon': 'assets/images/appliance.svg',
          'color': const Color(0xFFB3E4FF),
          'isSvg': true,
        };
      case 'other':
        return {
          'label': category,
          'englishCategory': 'other',
          'icon': 'icons/more_horiz',
          'color': const Color(0xFF9DCEFF),
          'isSvg': false,
          'isSystemIcon': true,
        };
      default:
        return {
          'label': category,
          'englishCategory': category,
          'icon': 'icons/miscellaneous_services',
          'color': const Color(0xFFE0E0E0),
          'isSvg': false,
          'isSystemIcon': true,
        };
    }
  }

  String _getFrenchToEnglishMapping(String frenchCategory) {
    switch (frenchCategory) {
      case 'nettoyage':
        return 'cleaning';
      case 'plomberie':
        return 'plumbing';
      case 'électricité':
      case 'électrique':
        return 'electrical';
      case 'peinture':
        return 'painting';
      case 'jardinage':
        return 'gardening';
      case 'menuiserie':
        return 'carpentry';
      case 'cuisine':
        return 'cooking';
      case 'tutorat':
        return 'tutoring';
      case 'beauté':
        return 'beauty';
      case 'maintenance':
        return 'maintenance';
      case 'autre':
        return 'other';
      default:
        return frenchCategory; // Return as-is if no mapping found
    }
  }

  Widget _buildServicesGrid(TextTheme textTheme) {
    final displayServices = <Map<String, dynamic>>[];

    // Add API services if available, mapped to existing icons
    if (_apiServices.isNotEmpty) {
      for (var apiService in _apiServices) {
        final categoryName = apiService['name'] as String;
        displayServices.add(_mapCategoryToService(categoryName));
      }
    } else {
      // Fallback to static services
      displayServices.addAll(_services.take(8));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayServices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final service = displayServices[index];
        return GestureDetector(
          onTap: () {
            // Use English category for navigation, display name for UI
            final englishCategory =
                service['englishCategory'] as String? ??
                service['label'] as String;
            _navigateToCategoryDescription(englishCategory.toLowerCase());
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: service['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Center(child: _buildServiceIcon(service)),
              ),
              const SizedBox(height: 8),
              Text(
                service['label'] as String,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Removed _buildProvidersGrid method

  void _navigateToCategoryDescription(String category) {
    // Find the localized display name from current services
    String displayName = _getCategoryDisplayName(category);

    // If we have API services, try to find the matching localized name
    if (_apiServices.isNotEmpty) {
      final matchingService = _apiServices.firstWhere(
        (service) =>
            _getFrenchToEnglishMapping(
              service['name'].toString().toLowerCase(),
            ) ==
            category,
        orElse: () => <String, String>{'name': displayName},
      );
      displayName = matchingService['name'].toString();
    }

    // TODO: Navigate to category description screen instead of providers
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDescriptionScreen(
          category: category,
          categoryDisplayName: displayName,
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return 'Cleaning';
      case 'plumbing':
        return 'Plumbing';
      case 'electrical':
        return 'Electrical';
      case 'painting':
        return 'Painting';
      case 'gardening':
        return 'Gardening';
      case 'carpentry':
        return 'Carpentry';
      case 'cooking':
        return 'Cooking';
      case 'tutoring':
        return 'Tutoring';
      case 'beauty':
        return 'Beauty';
      case 'maintenance':
        return 'Maintenance';
      case 'other':
        return 'Other';
      default:
        return category
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  // Removed all provider navigation and rating methods
}
