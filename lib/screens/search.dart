import 'package:expproj/components/search_sugestion.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,

      ),
      child:  Column(
        children: [
          SearchBar(
           backgroundColor: WidgetStateProperty.all(Colors.white),
           hintText: 'Search something crazy!',
           leading: const Icon(Icons.search_rounded),
           
    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)) ),
          ),
          const SizedBox(
            height: 25,
          ),
          Expanded(
            child: SizedBox(
              
              child: ListView.builder(
               physics: BouncingScrollPhysics(),
                
                itemCount: 12,
                itemBuilder: (context,index) {
                return const SearchSugestionCard();
              }),
            ),
          ),

        ],
      ),
    );
  }
}