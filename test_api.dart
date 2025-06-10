import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://newflightapi.cheerstravel.com.au/API/Searchfare');
  
  final body = {
    "searchId": "7753dd15991d42199e2dbf25060761a7",
    "companyId": "Cheers",
    "Channel": "B2C",
    "cacheKey": "T=R|RT=MEL|RTA=NRT|F=MEL|To=NRT|Dt=02-07-2024|Dt1=09-07-2024|Adt=1|chd=0|inf=0|ins=0|Yth=0|Cl=Y|ON=MEL|DN=NRT|OT=MEL|DiT=NRT|CCode=Cheers",
    "customerType": "DIR",
    "alternateAirport": false,
    "journeyType": "R",
    "directFlight": false,
    "gds": "1A",
    "flexi": false,
    "currency": "AUD",
    "branchId": "7753dd15991d42199e2dbf25060761a7",
    "cabinClass": "Y",
    "cabinClassName": "Economy",
    "outboundClass": "",
    "inboundClass": "",
    "fareType": "",
    "availableFare": false,
    "refundableFare": false,
    "paxDetails": {
      "adults": 1,
      "youth": 0,
      "children": 0,
      "infants": 0,
      "infantOnSeat": 0
    },
    "segments": [
      {
        "origin": "MEL",
        "OriginName": "MEL",
        "oriText": "MEL",
        "disText": "NRT",
        "destination": "NRT",
        "destinationName": "NRT",
        "originType": "C",
        "destinationType": "C",
        "date": "02-07-2025",
        "time": "",
        "legs": null
      },
      {
        "origin": "NRT",
        "OriginName": "NRT",
        "oriText": "MEL",
        "disText": "NRT",
        "destination": "MEL",
        "destinationName": "MEL",
        "originType": "C",
        "destinationType": "C",
        "date": "09-07-2025",
        "time": "",
        "legs": null
      }
    ],
    "sourceMedia": "Cheers",
    "preferedAirline": "",
    "linkid": null,
    "isBaggage": false,
    "gfsresult": false,
    "CJEVENT": null,
    "isCache": false,
    "continent": null
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Response Body:');
    try {
      final jsonResponse = jsonDecode(response.body);
      print(const JsonEncoder.withIndent('  ').convert(jsonResponse));
    } catch (e) {
      print(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
} 