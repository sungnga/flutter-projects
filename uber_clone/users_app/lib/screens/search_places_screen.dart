import 'package:flutter/material.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/google_maps/map_key.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

// GOOGLE PLACES API - PLACE AUTOCOMPLETE
// docs: https://developers.google.com/maps/documentation/places/web-service/autocomplete

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  void findPlaceAutocompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      // Search 'country short name 2 letters' to find the country
      String urlAutocompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:US";

      var responseAutocompleteSearch =
          await RequestAssistant.receiveRequest(urlAutocompleteSearch);
      if (responseAutocompleteSearch == "Request failed.") {
        return;
      }

      print('This is autocomplete search response:');
      print(responseAutocompleteSearch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            height: 160.0,
            decoration: BoxDecoration(
              color: Colors.black54,
              boxShadow: [
                BoxShadow(
                  color: Colors.white54,
                  blurRadius: 8.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 25.0,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Search & Set Drop-off Location',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.adjust_sharp,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 14.0,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (inputValue) {
                              findPlaceAutocompleteSearch(inputValue);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search location',
                              fillColor: Colors.white54,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 11.0,
                                top: 8.0,
                                bottom: 8.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
