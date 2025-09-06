import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_service/l10n/app_localizations.dart';
import 'package:house_service/core/state/app_state.dart';
import 'package:house_service/core/models/provider_models.dart';
import 'package:house_service/core/models/api_response.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;
  final String? providerName;

  const ProviderProfileScreen({
    super.key,
    required this.providerId,
    this.providerName,
  });

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  ProviderProfile? _profile;
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = false;
  bool _hasMoreReviews = true;
  int _currentReviewPage = 1;
  static const int _reviewsPerPage = 10;
  Map<String, dynamic>? _reviewStatistics;

  @override
  void initState() {
    super.initState();
    _fetchProviderProfile();
    _fetchProviderReviews();
  }

  Future<void> _fetchProviderProfile() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.apiService.getProviderProfile(
        widget.providerId,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _profile = ProviderProfile.fromJson(response.data!);
          _error = '';
        });
      } else {
        setState(() {
          _error =
              response.error ??
              AppLocalizations.of(context)!.failedToLoadProfile;
        });
      }
    } catch (e) {
      setState(() {
        _error =
            '${AppLocalizations.of(context)!.networkError}: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchProviderReviews({bool isLoadMore = false}) async {
    if (isLoadMore && (_loadingReviews || !_hasMoreReviews)) return;

    setState(() {
      _loadingReviews = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final pageToFetch = isLoadMore ? _currentReviewPage + 1 : 1;
      final response = await appState.apiService.getProviderReviews(
        widget.providerId,
        page: pageToFetch,
        limit: _reviewsPerPage,
      );

      if (response.isSuccess && response.data != null) {
        final reviewsData = response.data!['reviews'] as List<dynamic>?;
        final pagination =
            response.data!['pagination'] as Map<String, dynamic>?;
        final statistics =
            response.data!['statistics'] as Map<String, dynamic>?;

        if (reviewsData != null) {
          final newReviews = reviewsData.cast<Map<String, dynamic>>();
          setState(() {
            if (isLoadMore) {
              _reviews.addAll(newReviews);
              _currentReviewPage = pageToFetch;
            } else {
              _reviews = newReviews;
              _currentReviewPage = 1;
              // Only update statistics on first load
              if (statistics != null) {
                _reviewStatistics = statistics;
              }
            }

            // Check if there are more reviews to load
            if (pagination != null) {
              final currentPage = pagination['currentPage'] ?? 1;
              final totalPages = pagination['totalPages'] ?? 1;
              _hasMoreReviews = currentPage < totalPages;
            } else {
              _hasMoreReviews = newReviews.length >= _reviewsPerPage;
            }
          });
        }
      }
    } catch (e) {
      // Handle error silently for reviews as it's not critical
      // Debug: Error fetching reviews: $e
    } finally {
      setState(() {
        _loadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.providerName ?? AppLocalizations.of(context)!.providerProfile,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.shareComingSoon,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _buildContent(textTheme),
      floatingActionButton: _buildBookingFAB(),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.failedToLoadProfileMsg,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProviderProfile,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.providerNotFound,
              style: textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.3, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProviderHeader(textTheme),
            _buildProviderStats(textTheme),
            _buildServicesSection(textTheme),
            _buildAvailabilitySection(textTheme),
            _buildReviewsSection(textTheme),
            _buildBookingSection(),
            const SizedBox(height: 100), // Space for floating action button
          ],
        ),
      ),
    );
  }

  Widget _buildProviderHeader(TextTheme textTheme) {
    final provider = _profile!.provider;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              // Provider Avatar with Hero Animation
              Hero(
                tag: 'provider_avatar_${provider.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      provider.fullName.isNotEmpty
                          ? provider.fullName[0].toUpperCase()
                          : 'P',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Provider Name
              Text(
                provider.fullName,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.availableNow,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Contact Information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContactItem(
                    Icons.phone_rounded,
                    provider.phoneNumber,
                    textTheme,
                    () => _makePhoneCall(provider.phoneNumber),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  _buildContactItem(
                    Icons.email_rounded,
                    AppLocalizations.of(context)!.email,
                    textTheme,
                    () => _sendEmail(provider.email),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    TextTheme textTheme,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // TODO: Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppLocalizations.of(context)!.calling} $phoneNumber'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _sendEmail(String email) {
    // TODO: Implement email functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppLocalizations.of(context)!.openingEmail} $email'),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildProviderStats(TextTheme textTheme) {
    // Use review statistics if available, otherwise fall back to profile data
    final averageRating =
        _reviewStatistics != null
            ? (_reviewStatistics!['averageRating'] ?? 0.0).toDouble()
            : _profile!.averageRating;
    final totalReviews =
        _reviewStatistics != null
            ? (_reviewStatistics!['totalReviews'] ?? 0)
            : _profile!.totalReviews;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.work_rounded,
              '${_profile!.totalServices}',
              AppLocalizations.of(context)!.services,
              Colors.blue,
              textTheme,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              Icons.star_rounded,
              averageRating.toStringAsFixed(1),
              AppLocalizations.of(context)!.rating,
              Colors.amber,
              textTheme,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              Icons.reviews_rounded,
              '$totalReviews',
              AppLocalizations.of(context)!.reviews,
              Colors.green,
              textTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    MaterialColor color,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color.shade600, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(TextTheme textTheme) {
    if (_profile!.services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.work_rounded,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.services,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_profile!.services.length}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Services Grid
          ...(_profile!.services.map(
            (service) => _buildServiceCard(service, textTheme),
          )),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceBasic service, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getServiceIcon(service.category),
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.category.toUpperCase(),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade100, Colors.green.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '3,000',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.fcfaBase,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Service Description
            if (service.description != null) ...[
              const SizedBox(height: 16),
              Text(
                service.description!,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],

            // Service Stats
            if (service.totalReviews > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade100, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.averageRating.toStringAsFixed(1),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'rating',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.reviews_rounded,
                      size: 16,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${service.totalReviews} reviews',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500,
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

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'painting':
        return Icons.format_paint_rounded;
      case 'gardening':
        return Icons.grass_rounded;
      case 'carpentry':
        return Icons.carpenter_rounded;
      case 'cooking':
        return Icons.restaurant_rounded;
      case 'tutoring':
        return Icons.school_rounded;
      case 'beauty':
        return Icons.face_rounded;
      case 'maintenance':
        return Icons.build_rounded;
      default:
        return Icons.work_rounded;
    }
  }

  Widget _buildAvailabilitySection(TextTheme textTheme) {
    if (_profile!.availability.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.availability,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noAvailabilitySchedule,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.availability,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...(_profile!.availability.map(
            (availability) => _buildAvailabilityCard(availability, textTheme),
          )),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(
    ProviderAvailability availability,
    TextTheme textTheme,
  ) {
    final dayName =
        availability.dayOfWeek.substring(0, 1).toUpperCase() +
        availability.dayOfWeek.substring(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  dayName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        availability.timeSlots.any((slot) => slot.isAvailable)
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          availability.timeSlots.any((slot) => slot.isAvailable)
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    availability.timeSlots.any((slot) => slot.isAvailable)
                        ? AppLocalizations.of(context)!.available
                        : AppLocalizations.of(context)!.unavailable,
                    style: textTheme.bodySmall?.copyWith(
                      color:
                          availability.timeSlots.any((slot) => slot.isAvailable)
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (availability.timeSlots.isNotEmpty)
              _buildTimeGrid(availability.timeSlots, textTheme)
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.noTimeSlotsAvailable,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            if (availability.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        availability.notes!,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                          fontStyle: FontStyle.italic,
                        ),
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

  Widget _buildTimeGrid(List<TimeSlot> timeSlots, TextTheme textTheme) {
    return Column(
      children:
          timeSlots.map((slot) {
            final hourlySlots = _generateHourlySlots(slot);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    slot.isAvailable
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      slot.isAvailable
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        slot.isAvailable ? Icons.check_circle : Icons.cancel,
                        color:
                            slot.isAvailable
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${slot.startTime} - ${slot.endTime}',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              slot.isAvailable
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                        ),
                      ),
                      const Spacer(),
                      if (slot.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${hourlySlots.length}h available',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (slot.isAvailable && hourlySlots.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          hourlySlots.map((hourSlot) {
                            return Container(
                              width: 45,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  hourSlot,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }

  List<String> _generateHourlySlots(TimeSlot slot) {
    if (!slot.isAvailable) return [];

    final startHour = int.tryParse(slot.startTime.split(':')[0]) ?? 0;
    final endHour = int.tryParse(slot.endTime.split(':')[0]) ?? 0;

    List<String> hourlySlots = [];
    for (int hour = startHour; hour < endHour; hour++) {
      hourlySlots.add('${hour.toString().padLeft(2, '0')}:00');
    }

    return hourlySlots;
  }

  Widget _buildReviewsSection(TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.reviewsAndRatings,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                // Add Review Button
                ElevatedButton.icon(
                  onPressed: _showAddReviewDialog,
                  icon: const Icon(Icons.add_comment, size: 18),
                  label: Text(AppLocalizations.of(context)!.addReview),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reviews List
          if (_loadingReviews && _reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noReviewsYet,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.beFirstToReview,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ...(_reviews.map(
                  (review) => _buildReviewCard(review, textTheme),
                )),
                if (_hasMoreReviews)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: TextButton(
                      onPressed:
                          _loadingReviews
                              ? null
                              : () => _fetchProviderReviews(isLoadMore: true),
                      child:
                          _loadingReviews
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                AppLocalizations.of(context)!.loadMoreReviews,
                              ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, TextTheme textTheme) {
    final rating = (review['rating'] ?? 0).toDouble();
    final comment = review['comment'] ?? '';
    final serviceCategory = review['serviceCategory'] ?? '';
    final createdAt = review['createdAt'] ?? '';

    // Handle both nested reviewer object and reviewerId object
    final reviewer =
        review['reviewerId'] as Map<String, dynamic>? ??
        review['reviewer'] as Map<String, dynamic>? ??
        {};

    // Get current user info to check if this review belongs to them
    final appState = Provider.of<AppState>(context, listen: false);
    final currentUser = appState.user;

    // Determine reviewer name - use current user if this is their review
    String reviewerName = AppLocalizations.of(context)!.anonymous;
    String reviewerId = '';

    if (reviewer.isNotEmpty) {
      reviewerName = reviewer['fullName'] ?? AppLocalizations.of(context)!.anonymous;
      reviewerId = reviewer['_id'] ?? reviewer['id'] ?? '';
    }

    // Check if we can match by the review's direct reviewerId field
    final directReviewerId =
        review['reviewerId'] is String ? review['reviewerId'] : null;

    // If we have current user data and this appears to be their review
    if (currentUser != null) {
      // Try multiple ways to identify if this is the current user's review
      final isCurrentUserReview =
          reviewerId == currentUser.id ||
          directReviewerId == currentUser.id ||
          (reviewerName == AppLocalizations.of(context)!.anonymous && reviewer.isEmpty);

      if (isCurrentUserReview) {
        reviewerName =
            currentUser.fullName.isNotEmpty ? currentUser.fullName : AppLocalizations.of(context)!.you;
      }
    }

    // Debug logging to help troubleshoot
    // Review data: reviewerId=$reviewerId, directReviewerId=$directReviewerId, currentUserId=${currentUser?.id}, reviewerName=$reviewerName

    final providerResponse =
        review['providerResponse'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviewer Info & Rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    reviewerName.isNotEmpty
                        ? reviewerName[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerName,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStarRating(rating, size: 16),
                          const SizedBox(width: 8),
                          if (serviceCategory.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                serviceCategory.toUpperCase(),
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(createdAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Review Comment
            if (comment.isNotEmpty)
              Text(
                comment,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),

            // Provider Response
            if (providerResponse != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.providerResponse,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(providerResponse['createdAt'] ?? ''),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      providerResponse['response'] ?? '',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
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

  Widget _buildStarRating(double rating, {double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber.shade600,
          size: size,
        );
      }),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return AppLocalizations.of(context)!.justNow;
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _showAddReviewDialog() {
    if (_profile == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AddReviewDialog(
            providerId: widget.providerId,
            providerName: _profile!.provider.fullName,
            onReviewAdded: () {
              // Refresh reviews after adding a new one (this will update statistics)
              _fetchProviderReviews();
              // No need to refresh provider profile since we're using review statistics
            },
          ),
    );
  }

  Widget _buildBookingSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.readyToBook,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.selectServiceAndAvailability,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget? _buildBookingFAB() {
    if (_profile == null || _profile!.services.isEmpty) {
      return null;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showBookingDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          label: Text(
            AppLocalizations.of(context)!.bookService,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => BookingBottomSheet(
            key: ValueKey('booking_${Localizations.localeOf(context).languageCode}'),
            provider: _profile!.provider,
            services: _profile!.services,
            availability: _profile!.availability,
          ),
    );
  }
}

class BookingBottomSheet extends StatefulWidget {
  final ProviderBasic provider;
  final List<ServiceBasic> services;
  final List<ProviderAvailability> availability;

  const BookingBottomSheet({
    super.key,
    required this.provider,
    required this.services,
    required this.availability,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  ServiceBasic? _selectedService;
  ProviderAvailability? _selectedDay;
  TimeSlot? _selectedTimeSlot;
  String? _selectedStartTime;
  String? _selectedEndTime;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              '${AppLocalizations.of(context)!.bookWith} ${widget.provider.fullName}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Service Selection
            _buildSectionHeader(
              AppLocalizations.of(context)!.selectService,
              textTheme,
            ),
            const SizedBox(height: 12),
            ...widget.services.map(
              (service) => _buildServiceOption(service, textTheme),
            ),

            if (_selectedService != null) ...[
              const SizedBox(height: 24),

              // Day Selection
              _buildSectionHeader(
                AppLocalizations.of(context)!.selectDay,
                textTheme,
              ),
              const SizedBox(height: 12),
              ...widget.availability.map(
                (day) => _buildDayOption(day, textTheme),
              ),
            ],

            if (_selectedDay != null) ...[
              const SizedBox(height: 24),

              // Time Slot Selection
              _buildSectionHeader(
                AppLocalizations.of(context)!.selectAvailableTimeSlot,
                textTheme,
              ),
              const SizedBox(height: 12),
              ..._selectedDay!.timeSlots
                  .where((slot) => slot.isAvailable)
                  .map((slot) => _buildTimeSlotOption(slot, textTheme)),
            ],

            if (_selectedTimeSlot != null) ...[
              const SizedBox(height: 24),

              // Custom Time Range Selection
              _buildSectionHeader(
                AppLocalizations.of(context)!.chooseYourTimeRange,
                textTheme,
              ),
              const SizedBox(height: 12),
              _buildTimeRangeSelector(textTheme),
            ],

            if (_selectedStartTime != null && _selectedEndTime != null) ...[
              const SizedBox(height: 24),
              _buildBookingSummary(textTheme),
            ],

            const SizedBox(height: 30),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBook() ? _proceedToBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canBook() ? Colors.blue.shade600 : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _canBook()
                      ? AppLocalizations.of(context)!.confirmBooking
                      : AppLocalizations.of(context)!.selectTimeRange,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceOption(ServiceBasic service, TextTheme textTheme) {
    final isSelected = _selectedService == service;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<ServiceBasic>(
        value: service,
        groupValue: _selectedService,
        onChanged:
            (value) => setState(() {
              _selectedService = value;
              _selectedDay = null;
              _selectedTimeSlot = null;
              _selectedStartTime = null;
              _selectedEndTime = null;
            }),
        title: Text(
          service.title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.blue.shade800 : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.uniformPricing,
          style: textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        dense: true,
        activeColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildDayOption(ProviderAvailability day, TextTheme textTheme) {
    final isSelected = _selectedDay == day;
    final dayName =
        day.dayOfWeek.substring(0, 1).toUpperCase() +
        day.dayOfWeek.substring(1);
    final availableSlots =
        day.timeSlots.where((slot) => slot.isAvailable).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.green.shade300 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<ProviderAvailability>(
        value: day,
        groupValue: _selectedDay,
        onChanged:
            (value) => setState(() {
              _selectedDay = value;
              _selectedTimeSlot = null;
              _selectedStartTime = null;
              _selectedEndTime = null;
            }),
        title: Text(
          dayName,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.green.shade800 : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          '$availableSlots ${AppLocalizations.of(context)!.timeSlotsAvailable}',
          style: textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.green.shade600 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        dense: true,
        activeColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildTimeSlotOption(TimeSlot slot, TextTheme textTheme) {
    final isSelected = _selectedTimeSlot == slot;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.amber.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.amber.shade300 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<TimeSlot>(
        value: slot,
        groupValue: _selectedTimeSlot,
        onChanged:
            (value) => setState(() {
              _selectedTimeSlot = value;
              _selectedStartTime = null;
              _selectedEndTime = null;
            }),
        title: Text(
          '${slot.startTime} - ${slot.endTime}',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.amber.shade800 : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.availableForBooking,
          style: textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.amber.shade600 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        dense: true,
        activeColor: Colors.amber.shade600,
      ),
    );
  }

  Widget _buildTimeRangeSelector(TextTheme textTheme) {
    if (_selectedTimeSlot == null) return const SizedBox.shrink();

    final availableHours = _generateAvailableHours(_selectedTimeSlot!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.availableFromTo(
              _selectedTimeSlot!.startTime,
              _selectedTimeSlot!.endTime,
            ),
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Start Time Selection
          Text(
            AppLocalizations.of(context)!.startTime,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                availableHours.map((hour) {
                  final isSelected = _selectedStartTime == hour;
                  return GestureDetector(
                    onTap:
                        () => setState(() {
                          _selectedStartTime = hour;
                          _selectedEndTime = null; // Reset end time
                        }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade600 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        hour,
                        style: textTheme.bodySmall?.copyWith(
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          if (_selectedStartTime != null) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.endTime,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _generateEndTimeOptions().map((hour) {
                    final isSelected = _selectedEndTime == hour;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEndTime = hour),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.green.shade600 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.green.shade600
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          hour,
                          style: textTheme.bodySmall?.copyWith(
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingSummary(TextTheme textTheme) {
    final duration = _calculateDuration();

    // Calculate session pricing (uniform system)
    final basePrice = 3000; // Base price for 4 hours
    final baseDuration = 4.0;
    final overtimeRate = 375; // Per 30-minute block

    int totalCost = basePrice;
    int overtimeCost = 0;
    String pricingBreakdown = 'Base (4h): $basePrice FCFA';

    if (duration > baseDuration) {
      final overtimeHours = duration - baseDuration;
      final overtimeBlocks = (overtimeHours * 2).ceil(); // 30-minute blocks
      overtimeCost = overtimeBlocks * overtimeRate;
      totalCost = basePrice + overtimeCost;
      pricingBreakdown +=
          '\nOvertime (${overtimeHours.toStringAsFixed(1)}h): $overtimeCost FCFA';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.bookingSummary,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            AppLocalizations.of(context)!.service,
            _selectedService!.title,
            textTheme,
          ),
          _buildSummaryRow(
            AppLocalizations.of(context)!.day,
            _selectedDay!.dayOfWeek.substring(0, 1).toUpperCase() +
                _selectedDay!.dayOfWeek.substring(1),
            textTheme,
          ),
          _buildSummaryRow(
            AppLocalizations.of(context)!.time,
            '$_selectedStartTime - $_selectedEndTime',
            textTheme,
          ),
          _buildSummaryRow(
            AppLocalizations.of(context)!.duration,
            '${duration}h',
            textTheme,
          ),
          const Divider(color: Colors.blue),

          // Pricing breakdown
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.sessionPricing,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pricingBreakdown,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          _buildSummaryRow(
            AppLocalizations.of(context)!.totalCost,
            '$totalCost FCFA',
            textTheme,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    TextTheme textTheme, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateAvailableHours(TimeSlot slot) {
    final startHour = int.tryParse(slot.startTime.split(':')[0]) ?? 0;
    final endHour = int.tryParse(slot.endTime.split(':')[0]) ?? 0;

    List<String> hours = [];
    for (int hour = startHour; hour < endHour; hour++) {
      hours.add('${hour.toString().padLeft(2, '0')}:00');
    }

    return hours;
  }

  List<String> _generateEndTimeOptions() {
    if (_selectedStartTime == null || _selectedTimeSlot == null) return [];

    final startHour = int.tryParse(_selectedStartTime!.split(':')[0]) ?? 0;
    final maxEndHour =
        int.tryParse(_selectedTimeSlot!.endTime.split(':')[0]) ?? 0;

    List<String> endTimes = [];
    for (int hour = startHour + 1; hour <= maxEndHour; hour++) {
      endTimes.add('${hour.toString().padLeft(2, '0')}:00');
    }

    return endTimes;
  }

  int _calculateDuration() {
    if (_selectedStartTime == null || _selectedEndTime == null) return 0;

    final startHour = int.tryParse(_selectedStartTime!.split(':')[0]) ?? 0;
    final endHour = int.tryParse(_selectedEndTime!.split(':')[0]) ?? 0;

    return endHour - startHour;
  }

  bool _canBook() {
    return _selectedService != null &&
        _selectedDay != null &&
        _selectedTimeSlot != null &&
        _selectedStartTime != null &&
        _selectedEndTime != null;
  }

  DateTime _getNextDateForDayOfWeek(String dayOfWeek) {
    final now = DateTime.now();
    final targetWeekday = _getDayOfWeekNumber(dayOfWeek.toLowerCase());
    final currentWeekday = now.weekday;
    
    // Calculate days to add to get to the next occurrence of the target day
    int daysToAdd = targetWeekday - currentWeekday;
    if (daysToAdd <= 0) {
      daysToAdd += 7; // Next week
    }
    
    final targetDate = now.add(Duration(days: daysToAdd));
    return DateTime(targetDate.year, targetDate.month, targetDate.day);
  }

  int _getDayOfWeekNumber(String dayOfWeek) {
    switch (dayOfWeek) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday; // Default fallback
    }
  }

  Future<void> _proceedToBooking() async {
    Navigator.pop(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.loading,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.processingBooking,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final duration = _calculateDuration();
      
      // Convert selected day of week to next occurrence of that day
      final sessionDate = _getNextDateForDayOfWeek(_selectedDay!.dayOfWeek);
      
      // DEBUG: Booking data:
      // Provider ID: ${widget.provider.id}
      // Service ID: ${_selectedService!.id} 
      // Service Category: ${_selectedService!.category}
      // Selected Day: ${_selectedDay!.dayOfWeek}
      // Session Date: ${sessionDate.toIso8601String()}
      // Start Time: $_selectedStartTime
      // End Time: $_selectedEndTime
      // Duration: ${duration}h

      // Step 1: Check availability
      final appState = Provider.of<AppState>(context, listen: false);
      final availabilityResponse = await appState.apiService
          .validateSessionAvailability(
            providerId: widget.provider.id,
            sessionDate: sessionDate,
            startTime: _selectedStartTime!,
            durationHours: duration.toDouble(),
          );

      // DEBUG: Availability response: ${availabilityResponse.data}

      if (!availabilityResponse.isSuccess ||
          availabilityResponse.data != true) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          // DEBUG: Availability check failed: ${availabilityResponse.error}
          // DEBUG: Availability response data: ${availabilityResponse.data}
          
          // More specific error message based on the response
          String errorMessage = AppLocalizations.of(context)!.providerNotAvailable;
          if (availabilityResponse.error?.contains('already booked') == true) {
            errorMessage = 'This time slot is already booked. Please choose another time.';
          } else if (availabilityResponse.error?.contains('outside working hours') == true) {
            errorMessage = 'Selected time is outside provider\'s working hours.';
          } else if (availabilityResponse.error != null) {
            errorMessage = '${AppLocalizations.of(context)!.providerNotAvailable}\n\nDetails: ${availabilityResponse.error}';
          }
          
          _showErrorDialog(errorMessage);
        }
        return;
      }

      // Step 2: Calculate pricing
      final pricingResponse = await appState.apiService.calculateSessionPrice(
        _selectedService!.category,
        duration.toDouble(),
      );

      // DEBUG: Pricing response: ${pricingResponse.data}

      Map<String, dynamic> pricing;
      int totalAmount;
      int basePrice;
      int overtimePrice;

      if (!pricingResponse.isSuccess || pricingResponse.data == null) {
        // Fallback to uniform pricing calculation
        // DEBUG: Using fallback pricing due to API error: ${pricingResponse.error}
        
        const int basePriceValue = 3000; // Base price for 4 hours
        const double baseDuration = 4.0;
        const int overtimeRate = 750; // Per hour overtime
        
        if (duration <= baseDuration) {
          totalAmount = basePriceValue;
          basePrice = basePriceValue;
          overtimePrice = 0;
        } else {
          final overtimeHours = (duration - baseDuration).ceil();
          overtimePrice = overtimeHours * overtimeRate;
          totalAmount = basePriceValue + overtimePrice;
          basePrice = basePriceValue;
        }
        
        pricing = {
          'totalPrice': totalAmount,
          'basePrice': basePrice,
          'overtimePrice': overtimePrice,
        };
      } else {
        pricing = pricingResponse.data!;
        totalAmount = pricing['totalPrice'] as int;
        basePrice = pricing['basePrice'] as int;
        overtimePrice = pricing['overtimePrice'] as int? ?? 0;
      }

      // Step 3: Create session
      final sessionData = {
        'serviceId': _selectedService!.id,
        'sessionDate': '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}',
        'startTime': _selectedStartTime!,
        'duration': duration,
        'notes': 'Session booked through mobile app',
      };

      print('DEBUG: Session data being sent: $sessionData');

      final sessionResponse = await appState.apiService.createSession(
        sessionData,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('DEBUG: Session creation timed out');
          return ApiResponse.error('Request timed out. Please try again.');
        },
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (mounted && sessionResponse.isSuccess && sessionResponse.data != null) {
        _showSuccessDialog(
          sessionResponse.data!,
          basePrice,
          overtimePrice,
          totalAmount,
          duration.toDouble(),
        );
      } else if (mounted) {
        print('DEBUG: Session creation failed: ${sessionResponse.error}');
        print('DEBUG: Session response data: ${sessionResponse.data}');
        
        // More specific error message based on the response
        String errorMessage = sessionResponse.error ?? 'Failed to create session. Please try again.';
        if (sessionResponse.error?.contains('validation') == true) {
          errorMessage = 'Booking validation failed. Please check your selection and try again.';
        } else if (sessionResponse.error?.contains('conflict') == true) {
          errorMessage = 'Time slot conflict detected. Please choose a different time.';
        }
        
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog('Network error: ${e.toString()}');
      }
    }
  }

  void _showSuccessDialog(
    Map<String, dynamic> session,
    int basePrice,
    int overtimePrice,
    int totalAmount,
    double duration,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: Colors.green.shade500,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                AppLocalizations.of(context)!.sessionBookedSuccess,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Booking Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      AppLocalizations.of(context)!.service,
                      _selectedService!.title,
                    ),
                    _buildDetailRow('Provider', widget.provider.fullName),
                    _buildDetailRow(
                      AppLocalizations.of(context)!.day,
                      _selectedDay!.dayOfWeek,
                    ),
                    _buildDetailRow(
                      AppLocalizations.of(context)!.time,
                      '$_selectedStartTime - $_selectedEndTime',
                    ),
                    _buildDetailRow(
                      AppLocalizations.of(context)!.duration,
                      '${duration}h',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Pricing Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade100,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sessionPricing,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Base (4h)', '$basePrice FCFA'),
                    if (overtimePrice > 0)
                      _buildDetailRow('Overtime', '$overtimePrice FCFA'),
                    const Divider(),
                    _buildDetailRow(
                      AppLocalizations.of(context)!.totalCost,
                      '$totalAmount FCFA',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Session Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.shade100,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      AppLocalizations.of(context)!.sessionId,
                      session['id']?.toString() ?? 'N/A',
                      isSmall: true,
                    ),
                    _buildDetailRow(
                      AppLocalizations.of(context)!.status,
                      session['status']?.toString() ?? 'N/A',
                      isSmall: true,
                    ),
                    _buildDetailRow(
                      AppLocalizations.of(context)!.payment,
                      session['paymentStatus']?.toString() ?? 'N/A',
                      isSmall: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.ok,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false, bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isSmall ? 12 : 14,
              color: isTotal ? Colors.blue.shade800 : Colors.grey.shade700,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                fontSize: isSmall ? 12 : 14,
                color: isTotal ? Colors.blue.shade800 : Colors.grey.shade900,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon with Animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red.shade500,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                AppLocalizations.of(context)!.bookingFailed,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Error Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.shade100,
                    width: 1,
                  ),
                ),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade800,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.ok,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddReviewDialog extends StatefulWidget {
  final String providerId;
  final String providerName;
  final VoidCallback onReviewAdded;

  const AddReviewDialog({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _rating = 5.0;
  String _selectedCategory = 'cleaning';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'cleaning',
    'plumbing',
    'electrical',
    'painting',
    'gardening',
    'carpentry',
    'cooking',
    'tutoring',
    'beauty',
    'maintenance',
    'other',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.addReview,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.addReviewFor(widget.providerName),
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Rating Section
                Text(
                  AppLocalizations.of(context)!.rating,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = index + 1.0),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber.shade600,
                            size: 32,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Text(
                        '${_rating.toInt()}/5',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Service Category
                Text(
                  AppLocalizations.of(context)!.serviceCategory,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category.substring(0, 1).toUpperCase() +
                                  category.substring(1),
                              style: textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Comment Section
                Text(
                  AppLocalizations.of(context)!.comment,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.shareExperience,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.amber.shade600),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterComment;
                    }
                    if (value.trim().length < 10) {
                      return AppLocalizations.of(context)!.commentTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              AppLocalizations.of(context)!.submitReview,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final reviewData = {
        'rating': _rating.toInt(),
        'comment': _commentController.text.trim(),
        'serviceCategory': _selectedCategory,
      };

      final response = await appState.apiService.createProviderReview(
        widget.providerId,
        reviewData,
      );

      if (response.isSuccess && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reviewSubmittedSuccess),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Call the callback to refresh reviews
        widget.onReviewAdded();

        // Also add a small delay to ensure the API has processed the review
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onReviewAdded(); // Refresh again to get the complete data
      } else if (mounted) {
        _showErrorSnackBar(
          response.error ?? AppLocalizations.of(context)!.failedToSubmitReview,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Network error: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
