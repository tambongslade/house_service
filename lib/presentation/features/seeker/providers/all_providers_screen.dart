import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_service/core/state/app_state.dart';
import 'package:house_service/core/models/provider_models.dart';
import 'provider_profile_screen.dart';

class AllProvidersScreen extends StatefulWidget {
  const AllProvidersScreen({super.key});

  @override
  State<AllProvidersScreen> createState() => _AllProvidersScreenState();
}

class _AllProvidersScreenState extends State<AllProvidersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProviderBasic> _providers = [];
  bool _loading = true;
  String _error = '';
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _loadingMore = false;
  PaginationInfo? _paginationInfo;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProviders({bool loadMore = false, String? search}) async {
    if (loadMore) {
      setState(() => _loadingMore = true);
    } else {
      setState(() => _loading = true);
    }

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.apiService.getAllProviders(
        search: search?.isNotEmpty == true ? search : null,
        page: loadMore ? _currentPage + 1 : 1,
        limit: 10,
      );

      if (response.isSuccess && response.data != null) {
        final providersResponse = ProvidersResponse.fromJson(response.data!);
        
        setState(() {
          if (loadMore) {
            _providers.addAll(providersResponse.providers);
            _currentPage++;
          } else {
            _providers = providersResponse.providers;
            _currentPage = 1;
          }
          
          _paginationInfo = providersResponse.pagination;
          _hasMoreData = providersResponse.pagination.page < providersResponse.pagination.totalPages;
          _error = '';
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load providers';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _performSearch(String query) {
    _fetchProviders(search: query);
  }

  void _loadMoreProviders() {
    if (_hasMoreData && !_loadingMore) {
      _fetchProviders(loadMore: true, search: _searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Service Providers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _performSearch(_searchController.text),
                    ),
                  ],
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          
          // Results Summary
          if (_paginationInfo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  Text(
                    '${_paginationInfo!.total} providers found',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Page ${_paginationInfo!.page} of ${_paginationInfo!.totalPages}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _buildContent(textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load providers',
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
              onPressed: () => _fetchProviders(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No providers found',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Check back later for new providers',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            _hasMoreData && !_loadingMore) {
          _loadMoreProviders();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _providers.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _providers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final provider = _providers[index];
          return _buildProviderCard(provider, textTheme);
        },
      ),
    );
  }

  Widget _buildProviderCard(ProviderBasic provider, TextTheme textTheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToProviderProfile(provider.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Provider Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  provider.fullName.isNotEmpty 
                      ? provider.fullName[0].toUpperCase() 
                      : 'P',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Provider Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.fullName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.phoneNumber,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            provider.email,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // View Profile Button
              ElevatedButton(
                onPressed: () => _navigateToProviderProfile(provider.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProviderProfile(String providerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderProfileScreen(
          providerId: providerId,
        ),
      ),
    );
  }
}