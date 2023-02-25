import 'package:flutter/material.dart';
import 'package:users_app/models/predicted_places.dart';

class PlacePredictionTile extends StatelessWidget {
  const PlacePredictionTile({this.predictedPlaces});

  final PredictedPlaces? predictedPlaces;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: Colors.grey,
            ),
            SizedBox(
              width: 14.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    predictedPlaces!.mainText!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    predictedPlaces!.secondaryText!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
