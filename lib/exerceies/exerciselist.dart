import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/exercise.dart';
import '../userscreens/exercise_api.dart';
import '../userscreens/exercise_detail_screen.dart';
import '../model/apidata.dart';
import '../model/exercise.dart';
import 'exercise_detail.dart';

class ExerciseListScreen extends StatefulWidget {
  final String bodyPart;

  const ExerciseListScreen({super.key, required this.bodyPart});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late Future<List<Exercise>> _exercisesFuture;
  int _tappedIndex = -1;

  @override
  void initState() {
    super.initState();
    _exercisesFuture =
        ExerciseApi.fetchByBodyPart(widget.bodyPart, offset: 0, limit: 100);
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 600) return 3;
    return 2;
  }

  double _getAvatarRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 50.0;
    if (width > 600) return 45.0;
    return 35.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ simple white background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.bodyPart.replaceAll('%20', ' ').toUpperCase()} EXERCISES',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 1.2,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerGrid(context);
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No exercises found.',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            );
          }

          final exercises = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.8,
            ),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final isTapped = _tappedIndex == index;

              return GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _tappedIndex = index;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _tappedIndex = -1;
                  });
                },
                onTap: () {
                  setState(() {
                    _tappedIndex = -1;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExerciseDetailScreen(exercise: exercise),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()
                    ..scale(isTapped ? 0.94 : 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: _getAvatarRadius(context),
                          backgroundColor: Colors.grey.shade100,
                          child: exercise.gifUrl.isNotEmpty
                              ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: exercise.gifUrl,
                              fit: BoxFit.cover,
                              width: _getAvatarRadius(context) * 2,
                              height: _getAvatarRadius(context) * 2,
                              placeholder: (context, url) =>
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                              errorWidget: (context, url, error) =>
                              const Icon(
                                Icons.fitness_center,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          )
                              : const Icon(
                            Icons.fitness_center,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            exercise.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.6,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: _getAvatarRadius(context),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                Container(
                  height: 16,
                  width: 100,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
