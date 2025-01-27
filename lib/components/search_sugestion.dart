import 'package:flutter/material.dart';

class SearchSugestionCard extends StatelessWidget {
  const SearchSugestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      
      margin: const EdgeInsets.only(bottom: 15),
      height: 135,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(.5), width: .5)),
      clipBehavior: Clip.hardEdge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            height: 135,
            child: Image.asset(
              'assets/images/2.PNG',
              fit: BoxFit.fitHeight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chor nikal ke bhaga",
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  'Action | Thriller | Comedy',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Row(
                  children: [
                    Text(
                      'TOP 10',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    Icon(
                      Icons.trending_up_rounded,
                      color: Color.fromARGB(255, 178, 49, 40),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black.withOpacity(.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        child: const Row(
                          children: [
                            Icon(Icons.add_rounded),
                            Text(
                              'Wishlist',
                              style: TextStyle(),
                            )
                          ],
                        )),
                        const SizedBox(
                          width: 8,
                        ),
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                     
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black.withOpacity(.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        child: const Row(
                          children: [Icon(Icons.play_arrow_rounded), Text('Play')],
                        ))
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
