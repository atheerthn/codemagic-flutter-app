import 'dart:async';
import 'package:flutter/material.dart';
import '../models/city.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _weatherService = WeatherService();
  final _storageService = StorageService();
  final _controller = TextEditingController();

  List<City> _results = [];
  List<City> _favorites = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await _storageService.getFavorites();
    setState(() => _favorites = favs);
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.trim().isEmpty) {
        setState(() => _results = []);
        return;
      }
      setState(() => _searching = true);
      try {
        final results = await _weatherService.searchCity(query);
        setState(() {
          _results = results;
          _searching = false;
        });
      } catch (_) {
        setState(() => _searching = false);
      }
    });
  }

  Future<void> _toggleFavorite(City city) async {
    final favs = List<City>.from(_favorites);
    if (favs.contains(city)) {
      favs.remove(city);
    } else {
      favs.add(city);
    }
    await _storageService.saveFavorites(favs);
    setState(() => _favorites = favs);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _weatherService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search city...',
            border: InputBorder.none,
          ),
          onChanged: _onSearch,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _results = []);
              },
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.text.isEmpty) {
      // Show favorites
      if (_favorites.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text('Search for a city',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Favorites', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (_, i) => _cityTile(_favorites[i]),
            ),
          ),
        ],
      );
    }

    if (_results.isEmpty) {
      return const Center(child: Text('No cities found'));
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (_, i) => _cityTile(_results[i]),
    );
  }

  Widget _cityTile(City city) {
    final isFav = _favorites.contains(city);
    return ListTile(
      leading: const Icon(Icons.location_city),
      title: Text(city.name),
      subtitle: Text(city.country),
      trailing: IconButton(
        icon: Icon(isFav ? Icons.star : Icons.star_border,
            color: isFav ? Colors.amber : null),
        onPressed: () => _toggleFavorite(city),
      ),
      onTap: () => Navigator.pop(context, city),
    );
  }
}
