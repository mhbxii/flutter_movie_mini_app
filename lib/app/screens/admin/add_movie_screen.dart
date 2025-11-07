import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/services/movie_firestore_service.dart';

class AdminAddMovieScreen extends StatefulWidget {
  const AdminAddMovieScreen({super.key});

  @override
  State<AdminAddMovieScreen> createState() => _AdminAddMovieScreenState();
}

class _AdminAddMovieScreenState extends State<AdminAddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _overviewController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _releaseDateController = TextEditingController();
  final MovieFirestoreService _movieService = MovieFirestoreService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _overviewController.dispose();
    _posterUrlController.dispose();
    _releaseDateController.dispose();
    super.dispose();
  }

  Future<void> _handleAddMovie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final adminUid = authProvider.currentUser?.uid;

      if (adminUid == null) {
        throw Exception('Admin not logged in');
      }

      // Generate custom ID for Firestore movie
      final movieId = 'custom_${DateTime.now().millisecondsSinceEpoch}';

      final movie = MovieModel(
        id: movieId,
        title: _titleController.text.trim(),
        overview: _overviewController.text.trim(),
        posterUrl: _posterUrlController.text.trim(),
        releaseDate: _releaseDateController.text.trim(),
        addedBy: adminUid,
        createdAt: DateTime.now(),
      );

      await _movieService.addMovie(movie);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Movie added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _formKey.currentState!.reset();
      _titleController.clear();
      _overviewController.clear();
      _posterUrlController.clear();
      _releaseDateController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add movie: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Movie'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Movie',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter movie details to add to the database',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.movie_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter movie title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Overview field
              TextFormField(
                controller: _overviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Overview',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter movie overview';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Poster URL field
              TextFormField(
                controller: _posterUrlController,
                decoration: const InputDecoration(
                  labelText: 'Poster URL',
                  prefixIcon: Icon(Icons.image_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/poster.jpg',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter poster URL';
                  }
                  if (!value.startsWith('http')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Release Date field
              TextFormField(
                controller: _releaseDateController,
                decoration: const InputDecoration(
                  labelText: 'Release Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter release date';
                  }
                  // Basic date format validation
                  final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!dateRegex.hasMatch(value)) {
                    return 'Please use format: YYYY-MM-DD';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Preview poster if URL is valid
              if (_posterUrlController.text.startsWith('http'))
                Column(
                  children: [
                    const Text(
                      'Poster Preview:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.network(
                      _posterUrlController.text,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text('Invalid image URL'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Add Movie button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAddMovie,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Movie', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}