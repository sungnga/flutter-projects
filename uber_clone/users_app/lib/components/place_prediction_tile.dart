import 'package:flutter/material.dart';
import 'package:users_app/models/predicted_places.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/components/progress_dialog.dart';
import 'package:users_app/google_maps/map_key.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/utils/app_info_provider.dart';
import 'package:provider/provider.dart';

// PLACE IDS DOCS:
// https://developers.google.com/maps/documentation/places/web-service/place-id
// PLACE DETAILS DOCS:
// https://developers.google.com/maps/documentation/places/web-service/details

class PlacePredictionTile extends StatelessWidget {
  const PlacePredictionTile({this.predictedPlaces});

  final PredictedPlaces? predictedPlaces;

  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Setting drop-off location...",
      ),
    );

    // make connection to google api
    String placeDirectionDetailsURL =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    // make api request to get the place details of the place the user clicked on
    // contains placeId, place name, place lat/lng
    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsURL);

    // close the ProgressDialog box after making the request
    Navigator.pop(context);

    if (responseApi == "Request failed.") {
      return;
    } else {
      if (responseApi['status'] == 'OK') {
        Directions directions = Directions();
        directions.locationId = placeId;
        // use google Place Details docs to read json-format data
        directions.locationName = responseApi["result"]["name"];
        directions.locationLatitude =
            responseApi["result"]["geometry"]["location"]["lat"];
        directions.locationLongitude =
            responseApi["result"]["geometry"]["location"]["lng"];

        // update the userDropOffLocation state in AppInfo provider
        Provider.of<AppInfo>(context, listen: false)
            .updateDropOffLocationAddress(directions);

        // after updating userDropOffLocation state, close the Search Drop-off Place screen
        Navigator.pop(context, "obtainedDropOff");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(predictedPlaces!.placeId, context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white12,
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
