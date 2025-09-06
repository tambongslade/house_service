class ProviderBasic {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double averageRating;
  final int totalReviews;

  ProviderBasic({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.role = 'provider',
    this.createdAt,
    this.updatedAt,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  factory ProviderBasic.fromJson(Map<String, dynamic> json) {
    // Debug: Print the JSON structure to see what we're getting
    print('ProviderBasic JSON: $json');
    
    // Handle both direct rating fields and nested statistics
    final statistics = json['statistics'] as Map<String, dynamic>?;
    final reviewStats = json['reviewStats'] as Map<String, dynamic>?;
    final reviews = json['reviews'] as Map<String, dynamic>?;
    
    double averageRating = 0.0;
    int totalReviews = 0;

    try {
      // Check multiple possible locations for rating data
      if (statistics != null) {
        final ratingValue = statistics['averageRating'];
        averageRating = ratingValue != null ? ratingValue.toDouble() : 0.0;
        totalReviews = statistics['totalReviews'] ?? 0;
        print('Found statistics: rating=$averageRating, reviews=$totalReviews');
      } else if (reviewStats != null) {
        final ratingValue = reviewStats['averageRating'];
        averageRating = ratingValue != null ? ratingValue.toDouble() : 0.0;
        totalReviews = reviewStats['totalReviews'] ?? 0;
        print('Found reviewStats: rating=$averageRating, reviews=$totalReviews');
      } else if (reviews != null) {
        final ratingValue = reviews['averageRating'];
        averageRating = ratingValue != null ? ratingValue.toDouble() : 0.0;
        totalReviews = reviews['totalReviews'] ?? 0;
        print('Found reviews: rating=$averageRating, reviews=$totalReviews');
      } else {
        // Fallback to direct fields if available
        final ratingValue = json['averageRating'];
        averageRating = ratingValue != null ? ratingValue.toDouble() : 0.0;
        totalReviews = json['totalReviews'] ?? 0;
        print('Using direct fields: rating=$averageRating, reviews=$totalReviews');
      }
    } catch (e) {
      // If there's any error parsing rating data, default to 0
      print('Error parsing rating data: $e');
      averageRating = 0.0;
      totalReviews = 0;
    }

    return ProviderBasic(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      role: json['role']?.toString() ?? 'provider',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      averageRating: averageRating,
      totalReviews: totalReviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}

class ServiceBasic {
  final String id;
  final String title;
  final String? description;
  final String category;
  final int pricePerHour;
  final double averageRating;
  final int totalReviews;
  final List<String>? images;

  ServiceBasic({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.pricePerHour,
    required this.averageRating,
    required this.totalReviews,
    this.images,
  });

  factory ServiceBasic.fromJson(Map<String, dynamic> json) {
    return ServiceBasic(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Service',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'other',
      pricePerHour: int.tryParse(json['pricePerHour']?.toString() ?? '0') ?? 0,
      averageRating: double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      totalReviews: int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0,
      images: (json['images'] as List<dynamic>?)?.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'category': category,
      'pricePerHour': pricePerHour,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'images': images,
    };
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }
}

class ProviderAvailability {
  final String id;
  final String dayOfWeek;
  final List<TimeSlot> timeSlots;
  final String? notes;

  ProviderAvailability({
    required this.id,
    required this.dayOfWeek,
    required this.timeSlots,
    this.notes,
  });

  factory ProviderAvailability.fromJson(Map<String, dynamic> json) {
    return ProviderAvailability(
      id: json['_id'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      timeSlots: (json['timeSlots'] as List<dynamic>)
          .map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'dayOfWeek': dayOfWeek,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'notes': notes,
    };
  }
}

class ProviderWithServices {
  final ProviderBasic provider;
  final List<ServiceBasic> services;

  ProviderWithServices({
    required this.provider,
    required this.services,
  });

  factory ProviderWithServices.fromJson(Map<String, dynamic> json) {
    return ProviderWithServices(
      provider: ProviderBasic.fromJson(json['provider'] as Map<String, dynamic>),
      services: (json['services'] as List<dynamic>)
          .map((service) => ServiceBasic.fromJson(service as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.toJson(),
      'services': services.map((service) => service.toJson()).toList(),
    };
  }
}

class ProviderProfile {
  final ProviderBasic provider;
  final List<ServiceBasic> services;
  final List<ProviderAvailability> availability;
  final int totalServices;
  final double averageRating;
  final int totalReviews;

  ProviderProfile({
    required this.provider,
    required this.services,
    required this.availability,
    required this.totalServices,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      provider: ProviderBasic.fromJson(json['provider'] as Map<String, dynamic>),
      services: (json['services'] as List<dynamic>)
          .map((service) => ServiceBasic.fromJson(service as Map<String, dynamic>))
          .toList(),
      availability: (json['availability'] as List<dynamic>)
          .map((avail) => ProviderAvailability.fromJson(avail as Map<String, dynamic>))
          .toList(),
      totalServices: json['totalServices'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.toJson(),
      'services': services.map((service) => service.toJson()).toList(),
      'availability': availability.map((avail) => avail.toJson()).toList(),
      'totalServices': totalServices,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

class ProvidersResponse {
  final List<ProviderBasic> providers;
  final PaginationInfo pagination;

  ProvidersResponse({
    required this.providers,
    required this.pagination,
  });

  factory ProvidersResponse.fromJson(Map<String, dynamic> json) {
    return ProvidersResponse(
      providers: (json['providers'] as List<dynamic>)
          .map((provider) => ProviderBasic.fromJson(provider as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providers': providers.map((provider) => provider.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class CategoryProvidersResponse {
  final List<ProviderWithServices> providers;
  final String category;
  final PaginationInfo pagination;

  CategoryProvidersResponse({
    required this.providers,
    required this.category,
    required this.pagination,
  });

  factory CategoryProvidersResponse.fromJson(Map<String, dynamic> json) {
    return CategoryProvidersResponse(
      providers: (json['providers'] as List<dynamic>)
          .map((provider) => ProviderWithServices.fromJson(provider as Map<String, dynamic>))
          .toList(),
      category: json['category'] as String,
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providers': providers.map((provider) => provider.toJson()).toList(),
      'category': category,
      'pagination': pagination.toJson(),
    };
  }
}

// Dashboard Models
class ProviderInfo {
  final String id;
  final String fullName;
  final int totalEarnings;
  final int availableBalance;
  final int pendingBalance;
  final int totalWithdrawn;
  final double averageRating;
  final int totalReviews;
  final DateTime joinedDate;

  ProviderInfo({
    required this.id,
    required this.fullName,
    required this.totalEarnings,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalWithdrawn,
    required this.averageRating,
    required this.totalReviews,
    required this.joinedDate,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      totalEarnings: int.tryParse(json['totalEarnings']?.toString() ?? '0') ?? 0,
      availableBalance: int.tryParse(json['availableBalance']?.toString() ?? '0') ?? 0,
      pendingBalance: int.tryParse(json['pendingBalance']?.toString() ?? '0') ?? 0,
      totalWithdrawn: int.tryParse(json['totalWithdrawn']?.toString() ?? '0') ?? 0,
      averageRating: double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      totalReviews: int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0,
      joinedDate: DateTime.tryParse(json['joinedDate']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class DashboardStatistics {
  final int activeServices;
  final int totalBookings;
  final int thisWeekBookings;
  final int thisMonthBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int pendingBookings;
  final double monthlyEarningsGrowth;
  final double weeklyBookingsGrowth;

  DashboardStatistics({
    required this.activeServices,
    required this.totalBookings,
    required this.thisWeekBookings,
    required this.thisMonthBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.pendingBookings,
    required this.monthlyEarningsGrowth,
    required this.weeklyBookingsGrowth,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      activeServices: int.tryParse(json['activeServices']?.toString() ?? '0') ?? 0,
      totalBookings: int.tryParse(json['totalBookings']?.toString() ?? '0') ?? 0,
      thisWeekBookings: int.tryParse(json['thisWeekBookings']?.toString() ?? '0') ?? 0,
      thisMonthBookings: int.tryParse(json['thisMonthBookings']?.toString() ?? '0') ?? 0,
      completedBookings: int.tryParse(json['completedBookings']?.toString() ?? '0') ?? 0,
      cancelledBookings: int.tryParse(json['cancelledBookings']?.toString() ?? '0') ?? 0,
      pendingBookings: int.tryParse(json['pendingBookings']?.toString() ?? '0') ?? 0,
      monthlyEarningsGrowth: double.tryParse(json['monthlyEarningsGrowth']?.toString() ?? '0') ?? 0.0,
      weeklyBookingsGrowth: double.tryParse(json['weeklyBookingsGrowth']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class NextBooking {
  final String id;
  final String serviceTitle;
  final String seekerName;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int totalAmount;
  final String status;
  final String serviceLocation;

  NextBooking({
    required this.id,
    required this.serviceTitle,
    required this.seekerName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.status,
    required this.serviceLocation,
  });

  factory NextBooking.fromJson(Map<String, dynamic> json) {
    return NextBooking(
      id: json['_id']?.toString() ?? '',
      serviceTitle: json['serviceTitle']?.toString() ?? '',
      seekerName: json['seekerName']?.toString() ?? '',
      bookingDate: DateTime.tryParse(json['bookingDate']?.toString() ?? '') ?? DateTime.now(),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      totalAmount: int.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      serviceLocation: json['serviceLocation']?.toString() ?? '',
    );
  }
}

class RecentActivity {
  final String type;
  final String title;
  final String description;
  final int? amount;
  final int? rating;
  final DateTime timestamp;

  RecentActivity({
    required this.type,
    required this.title,
    required this.description,
    this.amount,
    this.rating,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: int.tryParse(json['amount']?.toString() ?? ''),
      rating: int.tryParse(json['rating']?.toString() ?? ''),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class DashboardSummary {
  final ProviderInfo provider;
  final DashboardStatistics statistics;
  final NextBooking? nextBooking;
  final List<RecentActivity> recentActivities;

  DashboardSummary({
    required this.provider,
    required this.statistics,
    this.nextBooking,
    required this.recentActivities,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      provider: ProviderInfo.fromJson(json['provider'] ?? {}),
      statistics: DashboardStatistics.fromJson(json['statistics'] ?? {}),
      nextBooking: json['nextBooking'] != null 
          ? NextBooking.fromJson(json['nextBooking']) 
          : null,
      recentActivities: (json['recentActivities'] as List<dynamic>? ?? [])
          .map((activity) => RecentActivity.fromJson(activity as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WalletBalance {
  final int available;
  final int pending;
  final int total;
  final String currency;

  WalletBalance({
    required this.available,
    required this.pending,
    required this.total,
    required this.currency,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      available: int.tryParse(json['available']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? 'FCFA',
    );
  }
}

class WalletTransaction {
  final String id;
  final String type;
  final int amount;
  final String description;
  final String? bookingId;
  final String status;
  final DateTime timestamp;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.bookingId,
    required this.status,
    required this.timestamp,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      bookingId: json['bookingId']?.toString(),
      status: json['status']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class WalletInfo {
  final WalletBalance balance;
  final List<WalletTransaction> recentTransactions;

  WalletInfo({
    required this.balance,
    required this.recentTransactions,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      balance: WalletBalance.fromJson(json['balance'] ?? {}),
      recentTransactions: (json['recentTransactions'] as List<dynamic>? ?? [])
          .map((transaction) => WalletTransaction.fromJson(transaction as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UpcomingBooking {
  final String id;
  final ServiceInfo service;
  final SeekerInfo seeker;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int duration;
  final int totalAmount;
  final String status;
  final String serviceLocation;
  final String? specialInstructions;
  final String timeUntilBooking;

  UpcomingBooking({
    required this.id,
    required this.service,
    required this.seeker,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalAmount,
    required this.status,
    required this.serviceLocation,
    this.specialInstructions,
    required this.timeUntilBooking,
  });

  factory UpcomingBooking.fromJson(Map<String, dynamic> json) {
    return UpcomingBooking(
      id: json['_id']?.toString() ?? '',
      service: ServiceInfo.fromJson(json['service'] ?? {}),
      seeker: SeekerInfo.fromJson(json['seeker'] ?? {}),
      bookingDate: DateTime.tryParse(json['bookingDate']?.toString() ?? '') ?? DateTime.now(),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      duration: int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      totalAmount: int.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      serviceLocation: json['serviceLocation']?.toString() ?? '',
      specialInstructions: json['specialInstructions']?.toString(),
      timeUntilBooking: json['timeUntilBooking']?.toString() ?? '',
    );
  }
}

class ServiceInfo {
  final String title;
  final String category;

  ServiceInfo({
    required this.title,
    required this.category,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }
}

class SeekerInfo {
  final String fullName;
  final String phoneNumber;

  SeekerInfo({
    required this.fullName,
    required this.phoneNumber,
  });

  factory SeekerInfo.fromJson(Map<String, dynamic> json) {
    return SeekerInfo(
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
    );
  }
}

class UpcomingBookingsSummary {
  final DateTime? nextBooking;
  final int totalUpcoming;
  final int totalEarningsExpected;

  UpcomingBookingsSummary({
    this.nextBooking,
    required this.totalUpcoming,
    required this.totalEarningsExpected,
  });

  factory UpcomingBookingsSummary.fromJson(Map<String, dynamic> json) {
    return UpcomingBookingsSummary(
      nextBooking: json['nextBooking'] != null 
          ? DateTime.tryParse(json['nextBooking'].toString()) 
          : null,
      totalUpcoming: int.tryParse(json['totalUpcoming']?.toString() ?? '0') ?? 0,
      totalEarningsExpected: int.tryParse(json['totalEarningsExpected']?.toString() ?? '0') ?? 0,
    );
  }
}

class UpcomingBookingsResponse {
  final List<UpcomingBooking> upcomingBookings;
  final UpcomingBookingsSummary summary;

  UpcomingBookingsResponse({
    required this.upcomingBookings,
    required this.summary,
  });

  factory UpcomingBookingsResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingBookingsResponse(
      upcomingBookings: (json['upcomingBookings'] as List<dynamic>? ?? [])
          .map((booking) => UpcomingBooking.fromJson(booking as Map<String, dynamic>))
          .toList(),
      summary: UpcomingBookingsSummary.fromJson(json['summary'] ?? {}),
    );
  }
}