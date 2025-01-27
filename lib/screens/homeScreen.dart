import 'package:carousel_slider/carousel_slider.dart';
import 'package:expproj/components/section_builder.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> imageUrls = [
    'https://www.indiewire.com/wp-content/uploads/2017/09/imperial-dreams-2014.jpg?w=426',
    'https://www.indiewire.com/wp-content/uploads/2017/09/barry-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/crouching-tiger-hidden-dragon-sword-of-destiny-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/the-fundamentals-of-caring-2016.jpg?w=675',
    'https://www.indiewire.com/wp-content/uploads/2017/09/pee-wees-big-holiday-2016.jpg?w=674',
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 70),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.50,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xff121212),
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 7),
                      enableInfiniteScroll: true,
                    ),
                    items: imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                            ),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;

                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[800]!,
                                  highlightColor: Colors.grey[700]!,
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey[300],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 18, 18, 18),
                        Color.fromARGB(200, 18, 18, 18),
                        Color.fromARGB(150, 18, 18, 18),
                        Color.fromARGB(100, 18, 18, 18),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.3, 0.50, 0.7, 1.0],
                    )),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    alignment: Alignment.center,
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 18, 18, 18),
                        Color.fromARGB(200, 18, 18, 18),
                        Color.fromARGB(150, 18, 18, 18),
                        Color.fromARGB(100, 18, 18, 18),
                        Colors.transparent
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.0, 0.3, 0.50, 0.7, 1.0],
                    )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.add_rounded),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            fixedSize: const Size(120, 15),
                            backgroundColor: Colors.red.withOpacity(0.8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            foregroundColor: Colors.white,
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 18,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "Play",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    wordSpacing: .8),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.favorite_rounded)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          const Sections(title: "Top 10", sectionCount: 10),
          const Sections(title: "Arrived this year", sectionCount: 8),
          const Sections(title: "Latest in hindi", sectionCount: 21),
          const Sections(title: "Top Series", sectionCount: 21),
        ],
      ),
    );
  }
}
