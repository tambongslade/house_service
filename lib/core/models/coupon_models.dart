class CouponValidationRequest {
  final String code;
  final double orderAmount;

  const CouponValidationRequest({
    required this.code,
    required this.orderAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'orderAmount': orderAmount,
    };
  }
}

class CouponValidationResponse {
  final bool isValid;
  final double discountAmount;
  final double finalAmount;
  final String couponCode;
  final String? errorMessage;

  const CouponValidationResponse({
    required this.isValid,
    required this.discountAmount,
    required this.finalAmount,
    required this.couponCode,
    this.errorMessage,
  });

  factory CouponValidationResponse.fromJson(Map<String, dynamic> json) {
    return CouponValidationResponse(
      isValid: json['isValid'] as bool? ?? false,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['couponCode'] as String? ?? '',
      errorMessage: json['errorMessage'] as String? ?? json['message'] as String?,
    );
  }

  factory CouponValidationResponse.error(String message) {
    return CouponValidationResponse(
      isValid: false,
      discountAmount: 0.0,
      finalAmount: 0.0,
      couponCode: '',
      errorMessage: message,
    );
  }

  bool get hasDiscount => isValid && discountAmount > 0;

  double get discountPercentage {
    if (!hasDiscount || finalAmount == 0) return 0.0;
    final originalAmount = finalAmount + discountAmount;
    return (discountAmount / originalAmount) * 100;
  }
}

class CouponInfo {
  final String? couponCode;
  final double? discountAmount;
  final double? finalAmount;
  final bool isApplied;

  const CouponInfo({
    this.couponCode,
    this.discountAmount,
    this.finalAmount,
    this.isApplied = false,
  });

  factory CouponInfo.empty() {
    return const CouponInfo();
  }

  factory CouponInfo.applied({
    required String couponCode,
    required double discountAmount,
    required double finalAmount,
  }) {
    return CouponInfo(
      couponCode: couponCode,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      isApplied: true,
    );
  }

  CouponInfo copyWith({
    String? couponCode,
    double? discountAmount,
    double? finalAmount,
    bool? isApplied,
  }) {
    return CouponInfo(
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (couponCode != null) 'couponCode': couponCode,
      if (discountAmount != null) 'discountAmount': discountAmount,
      if (finalAmount != null) 'finalAmount': finalAmount,
      'isApplied': isApplied,
    };
  }
}