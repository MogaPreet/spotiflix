import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Sections extends StatefulWidget {
  final String title;
  final int sectionCount;
  const Sections({super.key, required this.title, required this.sectionCount});

  @override
  State<Sections> createState() => _SectionsState();
}

class _SectionsState extends State<Sections> {
  final List<String> imageUrls = [
    'https://www.indiewire.com/wp-content/uploads/2017/09/imperial-dreams-2014.jpg?w=426',
    'https://www.indiewire.com/wp-content/uploads/2017/09/barry-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/crouching-tiger-hidden-dragon-sword-of-destiny-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/the-fundamentals-of-caring-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/pee-wees-big-holiday-2016.jpg?w=674',
    'https://www.indiewire.com/wp-content/uploads/2017/09/imperial-dreams-2014.jpg?w=426',
    'https://www.indiewire.com/wp-content/uploads/2017/09/barry-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/crouching-tiger-hidden-dragon-sword-of-destiny-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/the-fundamentals-of-caring-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/pee-wees-big-holiday-2016.jpg?w=674',
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
        
          ),
          child: Text(
            widget.title,
            style:Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
          ),
          )
        ),
        SizedBox(
  height: 180,
  child: GridView.builder(
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 200,
      childAspectRatio: 3 / 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 5,
      mainAxisExtent: 120, 
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    scrollDirection: Axis.horizontal,
    itemCount: imageUrls.length,
    itemBuilder: (context, index) {
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 37, 35, 35),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.only(left: 10),
        child: Image.network(
          imageUrls[index],
          fit: BoxFit.cover, // Ensures the image covers the container properly
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: Container(
                width: double.infinity,
                height: double.infinity, // Matches container height
                color: Colors.grey[800],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image,
            color: Colors.grey,
          ),
        ),
      );
    },
  ),
)
      ],
    );
  }
}
