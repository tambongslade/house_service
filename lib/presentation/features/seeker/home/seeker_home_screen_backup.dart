import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:house_service/l10n/app_localizations.dart';
import 'package:house_service/core/state/app_state.dart';
import 'package:house_service/core/models/provider_models.dart';
import 'package:house_service/presentation/features/seeker/providers/category_providers_screen.dart';
import 'package:house_service/presentation/features/seeker/providers/all_providers_screen.dart';
import 'package:house_service/presentation/features/seeker/providers/provider_profile_screen.dart';
import 'package:house_service/presentation/features/seeker/bookings/seeker_bookings_screen.dart';

class SeekerHomeScreen extends StatefulWidget {
  const SeekerHomeScreen({super.key});

  @override
  State<SeekerHomeScreen> createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends State<SeekerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _apiServices = [];
  bool _loadingServices = true;
  List<ProviderBasic> _featuredProviders = [];
  bool _loadingProviders = true;
  bool _loadingMoreProviders = false;
  bool _hasMoreProviders = true;
  int _currentProvidersPage = 1;
  static const int _providersPerPage = 6;
  final ScrollController _providersScrollController = ScrollController();

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
    _fetchFeaturedProviders();
    _providersScrollController.addListener(_onProvidersScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _providersScrollController.dispose();
    super.dispose();
  }

  void _onProvidersScroll() {
    if (_providersScrollController.position.pixels >=
        _providersScrollController.position.maxScrollExtent - 100) {
      _fetchFeaturedProviders(isLoadMore: true);
    }
  }

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

  Future<void> _fetchFeaturedProviders({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (_loadingMoreProviders || !_hasMoreProviders) return;
      setState(() {
        _loadingMoreProviders = true;
      });
    }
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final pageToFetch = isLoadMore ? _currentProvidersPage + 1 : 1;
      final response = await appState.apiService.getAllProviders(
        page: pageToFetch,
        limit: _providersPerPage,
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final providersData = response.data!['providers'] as List<dynamic>?;
        final pagination =
            response.data!['pagination'] as Map<String, dynamic>?;

        if (providersData != null) {
          final newProviders =
              providersData
                  .map(
                    (provider) => ProviderBasic.fromJson(
                      provider as Map<String, dynamic>,
                    ),
                  )
                  .toList();

          setState(() {
            if (isLoadMore) {
              _featuredProviders.addAll(newProviders);
              _currentProvidersPage = pageToFetch;
              _loadingMoreProviders = false;
            } else {
              _featuredProviders = newProviders;
              _currentProvidersPage = 1;
              _loadingProviders = false;
            }

            // Check if there are more providers to load
            if (pagination != null) {
              final currentPage = pagination['currentPage'] ?? 1;
              final totalPages = pagination['totalPages'] ?? 1;
              _hasMoreProviders = currentPage < totalPages;
            } else {
              _hasMoreProviders = newProviders.length >= _providersPerPage;
            }
          });
        } else {
          setState(() {
            if (isLoadMore) {
              _loadingMoreProviders = false;
            } else {
              _loadingProviders = false;
            }
            _hasMoreProviders = false;
          });
        }
      } else {
        setState(() {
          if (isLoadMore) {
            _loadingMoreProviders = false;
          } else {
            _loadingProviders = false;
          }
          _hasMoreProviders = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (isLoadMore) {
          _loadingMoreProviders = false;
        } else {
          _loadingProviders = false;
        }
        _hasMoreProviders = false;
      });
    }
  }

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
        IconButton(
          icon: Icon(Icons.calendar_today, color: colors.onSurfaceVariant),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SeekerBookingsScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_none, color: colors.onSurfaceVariant),
          onPressed: () {
            /* TODO: Navigate to notifications */
          },
        ),
        IconButton(
          icon: Icon(Icons.menu, color: colors.onSurfaceVariant),
          onPressed: () {
            /* TODO: Open menu */
          },
        ),
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

            // --- Service Providers ---
            _buildSectionHeader(
              AppLocalizations.of(context)!.serviceProviders,
              () {
                _navigateToAllProviders();
              },
              context,
            ),
            const SizedBox(height: 16),
            _loadingProviders
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                : _buildProvidersGrid(textTheme),
            const SizedBox(height: 24),
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
            _navigateToCategoryProviders(englishCategory.toLowerCase());
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

  Widget _buildProvidersGrid(TextTheme textTheme) {
    final totalRows = (_featuredProviders.length / 2).ceil();
    final totalItems = _hasMoreProviders ? totalRows + 1 : totalRows;

    return ListView.builder(
      controller: _providersScrollController,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: totalItems,
      itemBuilder: (context, rowIndex) {
        // Show loading indicator at the end if there are more items
        if (_hasMoreProviders && rowIndex == totalRows) {
          return _loadingMoreProviders
              ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
              : const SizedBox.shrink();
        }
        return Row(
          children: List.generate(2, (i) {
            final index = rowIndex * 2 + i;
            if (index < _featuredProviders.length) {
              final provider = _featuredProviders[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 8.0,
                    right: i == 1 ? 0 : 8.0,
                    bottom: 16.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Provider Avatar
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            color:
                                index % 2 == 0
                                    ? const Color(0xFFCCE0F0)
                                    : const Color(0xFFE5CCEF),
                          ),
                          child: Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              // TODO: Add support for profile photos
                              // backgroundImage: provider.profileImageUrl != null
                              //     ? NetworkImage(provider.profileImageUrl!)
                              //     : null,
                              child:
                                  provider.fullName.isNotEmpty
                                      ? Text(
                                        provider.fullName[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      )
                                      : Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.blue.shade800,
                                      ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Provider Name
                              Text(
                                provider.fullName,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Provider Role
                              Text(
                                AppLocalizations.of(context)!.serviceProviders,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Rating and Reviews
                              Row(
                                children: [
                                  _buildStarRating(
                                    provider.averageRating,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${provider.averageRating.toStringAsFixed(1)} (${provider.totalReviews})',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Details Button - Full width
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _navigateToProviderProfile(
                                      provider.id,
                                      provider.fullName,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade800,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.details,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Expanded(child: SizedBox.shrink());
            }
          }),
        );
      },
    );
  }

  void _navigateToCategoryProviders(String category) {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CategoryProvidersScreen(
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

  void _navigateToAllProviders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllProvidersScreen()),
    );
  }

  void _navigateToProviderProfile(String providerId, [String? providerName]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProviderProfileScreen(
              providerId: providerId,
              providerName: providerName,
            ),
      ),
    );
  }

  Widget _buildStarRating(double rating, {double size = 16}) {
    // Ensure rating is within valid bounds
    final safeRating = rating.clamp(0.0, 5.0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < safeRating.floor()
              ? Icons.star
              : index < safeRating
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber.shade600,
          size: size,
        );
      }),
    );
  }
}
