import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../l10n/app_localizations.dart';
import 'provider_main_screen.dart';

class ProviderPendingApprovalScreen extends StatefulWidget {
  const ProviderPendingApprovalScreen({super.key});

  @override
  State<ProviderPendingApprovalScreen> createState() => _ProviderPendingApprovalScreenState();
}

class _ProviderPendingApprovalScreenState extends State<ProviderPendingApprovalScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isProfileComplete = false;
  String _status = 'pending_approval';
  List<String> _nextSteps = [];
  String _message = '';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkProfileStatus();
    
    // Set up periodic status checking every 30 seconds
    _startStatusChecking();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _startStatusChecking() {
    // Check status every 30 seconds
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (mounted) {
        _checkProfileStatus(silent: true);
      }
    });
  }

  Future<void> _checkProfileStatus({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      final apiService = ApiService();
      final response = await apiService.checkProfileStatus();

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          final data = response.data!;
          setState(() {
            _isProfileComplete = data['isProfileComplete'] ?? false;
            _status = data['status'] ?? 'pending_approval';
            _nextSteps = List<String>.from(data['nextSteps'] ?? []);
            _message = data['message'] ?? '';
            _isLoading = false;
          });

          // If approved, navigate to main screen
          if (_status == 'approved') {
            _handleApprovalSuccess();
          }
        } else {
          if (!silent) {
            setState(() {
              _isLoading = false;
              _message = response.error ?? 'Unable to check profile status';
            });
          }
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _isLoading = false;
          _message = 'Network error: ${e.toString()}';
        });
      }
    }
  }

  void _handleApprovalSuccess() {
    // Show success message and navigate to main screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Your profile has been approved! Welcome to our platform!'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ProviderMainScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Checking profile status...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildStatusIcon(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildMessage(),
              const SizedBox(height: 40),
              _buildNextStepsCard(),
              const SizedBox(height: 40),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (_status) {
      case 'approved':
        iconData = Icons.check_circle;
        iconColor = Colors.white;
        backgroundColor = const Color(0xFF10B981);
        break;
      case 'rejected':
        iconData = Icons.cancel;
        iconColor = Colors.white;
        backgroundColor = const Color(0xFFEF4444);
        break;
      default:
        iconData = Icons.hourglass_empty;
        iconColor = Colors.white;
        backgroundColor = const Color(0xFFF59E0B);
    }

    return ScaleTransition(
      scale: _status == 'pending_approval' ? _pulseAnimation : 
             const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Icon(
          iconData,
          size: 48,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    String title;
    switch (_status) {
      case 'approved':
        title = 'Profile Approved! 🎉';
        break;
      case 'rejected':
        title = 'Profile Needs Review';
        break;
      default:
        title = 'Profile Under Review';
    }

    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    String defaultMessage;
    switch (_status) {
      case 'approved':
        defaultMessage = 'Congratulations! Your provider profile has been approved. You can now start offering your services.';
        break;
      case 'rejected':
        defaultMessage = 'Your profile needs some updates. Please review the feedback and resubmit your profile.';
        break;
      default:
        defaultMessage = 'Your profile is being reviewed by our admin team. This usually takes 24-48 hours. We\'ll notify you once it\'s approved.';
    }

    return Text(
      _message.isNotEmpty ? _message : defaultMessage,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF64748B),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNextStepsCard() {
    if (_nextSteps.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.list_alt,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Next Steps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_nextSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3B82F6),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Refresh Status Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _checkProfileStatus(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Check Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Logout Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}