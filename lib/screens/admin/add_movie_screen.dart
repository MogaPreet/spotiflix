import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/movie_model.dart';
import '../../services/api/movie_service.dart';

class AddMovieScreen extends StatefulWidget {
  final Movie? movieToEdit; // Pass this if editing an existing movie

  const AddMovieScreen({Key? key, this.movieToEdit}) : super(key: key);

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final MovieService _movieService = MovieService();
  
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _ratingController;
  late TextEditingController _releaseYearController;
  late TextEditingController _durationController;
  late TextEditingController _directorController;
  late TextEditingController _trailerUrlController;
  
  // Selected values
  String _selectedContentType = 'movie';
  int? _seasons;
  List<String> _selectedGenres = [];
  List<String> _cast = [];
  
  // Images
  File? _posterImage;
  File? _backdropImage;
  
  // Loading state
  bool _isLoading = false;
  String? _errorMessage;
  
  // Available genres
  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime',
    'Documentary', 'Drama', 'Family', 'Fantasy', 'Horror',
    'Mystery', 'Romance', 'Sci-Fi', 'Thriller', 'War'
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    final movie = widget.movieToEdit;
    _titleController = TextEditingController(text: movie?.title ?? '');
    _descriptionController = TextEditingController(text: movie?.description ?? '');
    _ratingController = TextEditingController(text: movie?.rating.toString() ?? '0.0');
    _releaseYearController = TextEditingController(text: movie?.releaseYear ?? '');
    _durationController = TextEditingController(text: movie?.duration ?? '');
    _directorController = TextEditingController(text: movie?.director ?? '');
    _trailerUrlController = TextEditingController(text: movie?.trailerUrl ?? '');
    
    if (movie != null) {
      _selectedContentType = movie.contentType;
      _seasons = movie.seasons;
      _selectedGenres = List<String>.from(movie.genres);
      _cast = List<String>.from(movie.cast);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    _releaseYearController.dispose();
    _durationController.dispose();
    _directorController.dispose();
    _trailerUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isPoster) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      
      if (pickedFile != null) {
        setState(() {
          if (isPoster) {
            _posterImage = File(pickedFile.path);
          } else {
            _backdropImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _addCastMember() {
    final TextEditingController castController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cast Member'),
        content: TextField(
          controller: castController,
          decoration: const InputDecoration(
            labelText: 'Cast Member Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (castController.text.isNotEmpty) {
                setState(() {
                  _cast.add(castController.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGenres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one genre')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final movie = Movie(
          id: widget.movieToEdit?.id ?? '',
          title: _titleController.text,
          description: _descriptionController.text,
          imageUrl: widget.movieToEdit?.imageUrl ?? '',
          backdropUrl: widget.movieToEdit?.backdropUrl ?? '',
          rating: double.parse(_ratingController.text),
          genres: _selectedGenres,
          releaseYear: _releaseYearController.text,
          duration: _durationController.text,
          cast: _cast,
          director: _directorController.text,
          trailerUrl: _trailerUrlController.text,
          contentType: _selectedContentType,
          seasons: _selectedContentType == 'series' ? _seasons : null,
        );

        if (widget.movieToEdit == null) {
          // Creating new movie
          await _movieService.createMovie(
            movie,
            posterFile: _posterImage,
            backdropFile: _backdropImage,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Movie added successfully')),
            );
            // Reset form
            _formKey.currentState!.reset();
            setState(() {
              _posterImage = null;
              _backdropImage = null;
              _cast = [];
              _selectedGenres = [];
            });
          }
        } else {
          // Updating existing movie
          await _movieService.updateMovie(
            widget.movieToEdit!.id,
            movie,
            posterFile: _posterImage,
            backdropFile: _backdropImage,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Movie updated successfully')),
            );
            Navigator.pop(context, true); // Navigate back with success result
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieToEdit == null ? 'Add New Movie' : 'Edit Movie'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.red.withOpacity(0.1),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Content Type
                    Row(
                      children: [
                        const Text('Content Type: '),
                        const SizedBox(width: 16),
                        ChoiceChip(
                          label: const Text('Movie'),
                          selected: _selectedContentType == 'movie',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedContentType = 'movie';
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Series'),
                          selected: _selectedContentType == 'series',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedContentType = 'series';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Seasons (only for series)
                    if (_selectedContentType == 'series')
                      Row(
                        children: [
                          const Text('Number of Seasons: '),
                          const SizedBox(width: 16),
                          Container(
                            width: 100,
                            child: TextFormField(
                              initialValue: _seasons?.toString() ?? '',
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _seasons = int.tryParse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    
                    // Images
                    Text(
                      'Images',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Poster Image'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _pickImage(true),
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: _posterImage != null
                                      ? Image.file(_posterImage!, fit: BoxFit.cover)
                                      : widget.movieToEdit?.imageUrl != null && widget.movieToEdit!.imageUrl.isNotEmpty
                                          ? Image.network(widget.movieToEdit!.imageUrl, fit: BoxFit.cover)
                                          : const Icon(Icons.add_photo_alternate, size: 50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Backdrop Image'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _pickImage(false),
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: _backdropImage != null
                                      ? Image.file(_backdropImage!, fit: BoxFit.cover)
                                      : widget.movieToEdit?.backdropUrl != null && widget.movieToEdit!.backdropUrl.isNotEmpty
                                          ? Image.network(widget.movieToEdit!.backdropUrl, fit: BoxFit.cover)
                                          : const Icon(Icons.add_photo_alternate, size: 50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Genres
                    Text(
                      'Genres *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableGenres.map((genre) {
                        final isSelected = _selectedGenres.contains(genre);
                        return FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedGenres.add(genre);
                              } else {
                                _selectedGenres.remove(genre);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Basic info row
                    Row(
                      children: [
                        // Rating
                        Expanded(
                          child: TextFormField(
                            controller: _ratingController,
                            decoration: const InputDecoration(
                              labelText: 'Rating (0-5)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final rating = double.tryParse(value);
                              if (rating == null || rating < 0 || rating > 5) {
                                return 'Invalid rating';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Release Year
                        Expanded(
                          child: TextFormField(
                            controller: _releaseYearController,
                            decoration: const InputDecoration(
                              labelText: 'Release Year',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Duration
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Duration',
                              hintText: '2h 15m',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Director
                    TextFormField(
                      controller: _directorController,
                      decoration: const InputDecoration(
                        labelText: 'Director',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter director name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Cast
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cast',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ElevatedButton.icon(
                          onPressed: _addCastMember,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Cast'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._cast.asMap().entries.map((entry) {
                      final index = entry.key;
                      final name = entry.value;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(name),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _cast.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (_cast.isEmpty)
                      const Text(
                        'No cast members added yet',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    const SizedBox(height: 16),
                    
                    // Trailer URL
                    TextFormField(
                      controller: _trailerUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Trailer URL (YouTube)',
                        border: OutlineInputBorder(),
                        hintText: 'https://www.youtube.com/watch?v=...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.movieToEdit == null ? 'Add Movie' : 'Update Movie',
                          style: const TextStyle(fontSize: 16),
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