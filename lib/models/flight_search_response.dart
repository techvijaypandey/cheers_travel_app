class FlightSearchResponse {
  final Status status;
  final List<FlightItinerary> data;
  final List<Currency> currencies;
  final bool? isCache;
  final double atol;
  final double safi;
  final List<Airport> airports;
  final List<Airline> airlines;
  final FlightFareSearchRQ flightFareSearchRQ;

  FlightSearchResponse({
    required this.status,
    required this.data,
    required this.currencies,
    this.isCache,
    required this.atol,
    required this.safi,
    required this.airports,
    required this.airlines,
    required this.flightFareSearchRQ,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    return FlightSearchResponse(
      status: Status.fromJson(json['status']),
      data: (json['data'] as List).map((e) => FlightItinerary.fromJson(e)).toList(),
      currencies: (json['currencies'] as List).map((e) => Currency.fromJson(e)).toList(),
      isCache: json['isCache'],
      atol: json['atol']?.toDouble() ?? 0.0,
      safi: json['safi']?.toDouble() ?? 0.0,
      airports: (json['airports'] as List).map((e) => Airport.fromJson(e)).toList(),
      airlines: (json['airlines'] as List).map((e) => Airline.fromJson(e)).toList(),
      flightFareSearchRQ: FlightFareSearchRQ.fromJson(json['flightFareSearchRQ']),
    );
  }
}

class Status {
  final String statusCode;
  final String type;
  final String message;

  Status({
    required this.statusCode,
    required this.type,
    required this.message,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      statusCode: json['statusCode'],
      type: json['type'],
      message: json['message'],
    );
  }
}

class FlightItinerary {
  final String itineId;
  final String uid;
  final String iKey;
  final String fareType;
  final bool refundable;
  final int indexNumber;
  final String provider;
  final String airlines;
  final String valCarrier;
  final String lastTicketingDate;
  final FareInfo fareInfo;
  final dynamic offerDetails;
  final Sectors sectors;
  final FareBasisCodes fareBasisCodes;

  FlightItinerary({
    required this.itineId,
    required this.uid,
    required this.iKey,
    required this.fareType,
    required this.refundable,
    required this.indexNumber,
    required this.provider,
    required this.airlines,
    required this.valCarrier,
    required this.lastTicketingDate,
    required this.fareInfo,
    this.offerDetails,
    required this.sectors,
    required this.fareBasisCodes,
  });

  factory FlightItinerary.fromJson(Map<String, dynamic> json) {
    return FlightItinerary(
      itineId: json['itineId'],
      uid: json['uid'],
      iKey: json['iKey'],
      fareType: json['fareType'],
      refundable: json['refundable'],
      indexNumber: json['indexNumber'],
      provider: json['provider'],
      airlines: json['airlines'],
      valCarrier: json['valCarrier'],
      lastTicketingDate: json['lastTicketingDate'],
      fareInfo: FareInfo.fromJson(json['fareInfo']),
      offerDetails: json['offerDetails'],
      sectors: Sectors.fromJson(json['sectors']),
      fareBasisCodes: FareBasisCodes.fromJson(json['fareBasisCodes']),
    );
  }
}

class FareInfo {
  final double baseFare;
  final double taxes;
  final double markUp;
  final AdultInfo adultInfo;
  final dynamic youthInfo;
  final dynamic childInfo;
  final dynamic infantInfo;
  final dynamic infantOnSeatInfo;

  FareInfo({
    required this.baseFare,
    required this.taxes,
    required this.markUp,
    required this.adultInfo,
    this.youthInfo,
    this.childInfo,
    this.infantInfo,
    this.infantOnSeatInfo,
  });

  factory FareInfo.fromJson(Map<String, dynamic> json) {
    return FareInfo(
      baseFare: json['baseFare']?.toDouble() ?? 0.0,
      taxes: json['taxes']?.toDouble() ?? 0.0,
      markUp: json['markUp']?.toDouble() ?? 0.0,
      adultInfo: AdultInfo.fromJson(json['adultInfo']),
      youthInfo: json['youthInfo'],
      childInfo: json['childInfo'],
      infantInfo: json['infantInfo'],
      infantOnSeatInfo: json['infantOnSeatInfo'],
    );
  }
}

class AdultInfo {
  final int noAdult;
  final String adultKey;
  final double adtTax;
  final double adtBFare;
  final double markUp;

  AdultInfo({
    required this.noAdult,
    required this.adultKey,
    required this.adtTax,
    required this.adtBFare,
    required this.markUp,
  });

  factory AdultInfo.fromJson(Map<String, dynamic> json) {
    return AdultInfo(
      noAdult: json['noAdult'],
      adultKey: json['adultKey'],
      adtTax: json['adtTax']?.toDouble() ?? 0.0,
      adtBFare: json['adtBFare']?.toDouble() ?? 0.0,
      markUp: json['markUp']?.toDouble() ?? 0.0,
    );
  }
}

class Sectors {
  final List<FlightSegment> outBound;
  final List<FlightSegment> inBound;
  final List<dynamic> mLegs;

  Sectors({
    required this.outBound,
    required this.inBound,
    required this.mLegs,
  });

  factory Sectors.fromJson(Map<String, dynamic> json) {
    return Sectors(
      outBound: (json['outBound'] as List).map((e) => FlightSegment.fromJson(e)).toList(),
      inBound: (json['inBound'] as List).map((e) => FlightSegment.fromJson(e)).toList(),
      mLegs: json['mLegs'] ?? [],
    );
  }
}

class FlightSegment {
  final String key;
  final String isConnect;
  final dynamic segmentIndex;
  final dynamic group;
  final dynamic status;
  final String airlineCode;
  final String cclass;
  final CabinClass cabinClass;
  final String noSeats;
  final String fltNum;
  final FlightPoint departure;
  final FlightPoint arrival;
  final String equipType;
  final String elapsedTime;
  final String actualTime;
  final int techStopOver;
  final dynamic multisect;
  final TechStopDetails techStopDetails;
  final OperatingCarrier operatingCarrier;
  final MarketingCarrier marketingCarrier;
  final String baggageInfo;
  final List<dynamic> lstAncillaries;
  final dynamic airChange;
  final dynamic campaign;

  FlightSegment({
    required this.key,
    required this.isConnect,
    this.segmentIndex,
    this.group,
    this.status,
    required this.airlineCode,
    required this.cclass,
    required this.cabinClass,
    required this.noSeats,
    required this.fltNum,
    required this.departure,
    required this.arrival,
    required this.equipType,
    required this.elapsedTime,
    required this.actualTime,
    required this.techStopOver,
    this.multisect,
    required this.techStopDetails,
    required this.operatingCarrier,
    required this.marketingCarrier,
    required this.baggageInfo,
    required this.lstAncillaries,
    this.airChange,
    this.campaign,
  });

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      key: json['key'] ?? '',
      isConnect: json['isConnect'] ?? '',
      segmentIndex: json['segmentIndex'],
      group: json['group'],
      status: json['status'],
      airlineCode: json['airlineCode'],
      cclass: json['cclass'],
      cabinClass: CabinClass.fromJson(json['cabinClass']),
      noSeats: json['noSeats'],
      fltNum: json['fltNum'],
      departure: FlightPoint.fromJson(json['departure']),
      arrival: FlightPoint.fromJson(json['arrival']),
      equipType: json['equipType'],
      elapsedTime: json['elapsedTime'],
      actualTime: json['actualTime'],
      techStopOver: json['techStopOver'] ?? 0,
      multisect: json['multisect'],
      techStopDetails: TechStopDetails.fromJson(json['techStopDetails']),
      operatingCarrier: OperatingCarrier.fromJson(json['operatingCarrier']),
      marketingCarrier: MarketingCarrier.fromJson(json['marketingCarrier']),
      baggageInfo: json['baggageInfo'],
      lstAncillaries: json['lstAncillaries'] ?? [],
      airChange: json['airChange'],
      campaign: json['campaign'],
    );
  }
}

class CabinClass {
  final String code;
  final String name;

  CabinClass({
    required this.code,
    required this.name,
  });

  factory CabinClass.fromJson(Map<String, dynamic> json) {
    return CabinClass(
      code: json['code'],
      name: json['name'],
    );
  }
}

class FlightPoint {
  final String airportCode;
  final String terminal;
  final String date;
  final String time;

  FlightPoint({
    required this.airportCode,
    required this.terminal,
    required this.date,
    required this.time,
  });

  factory FlightPoint.fromJson(Map<String, dynamic> json) {
    return FlightPoint(
      airportCode: json['airportCode'],
      terminal: json['terminal'],
      date: json['date'],
      time: json['time'],
    );
  }
}

class TechStopDetails {
  final String? airportCode;
  final String? airportName;
  final String? groundTime;
  final String? terminal;

  TechStopDetails({
    this.airportCode,
    this.airportName,
    this.groundTime,
    this.terminal,
  });

  factory TechStopDetails.fromJson(Map<String, dynamic> json) {
    return TechStopDetails(
      airportCode: json['airportCode'],
      airportName: json['airportName'],
      groundTime: json['groundTime'],
      terminal: json['terminal'],
    );
  }
}

class OperatingCarrier {
  final String optrCarrierCode;

  OperatingCarrier({
    required this.optrCarrierCode,
  });

  factory OperatingCarrier.fromJson(Map<String, dynamic> json) {
    return OperatingCarrier(
      optrCarrierCode: json['optrCarrierCode'],
    );
  }
}

class MarketingCarrier {
  final String mktCarrierCode;

  MarketingCarrier({
    required this.mktCarrierCode,
  });

  factory MarketingCarrier.fromJson(Map<String, dynamic> json) {
    return MarketingCarrier(
      mktCarrierCode: json['mktCarrierCode'],
    );
  }
}

class FareBasisCodes {
  final List<FareBasisCode> fareBasisCode;

  FareBasisCodes({
    required this.fareBasisCode,
  });

  factory FareBasisCodes.fromJson(Map<String, dynamic> json) {
    return FareBasisCodes(
      fareBasisCode: (json['fareBasisCode'] as List)
          .map((e) => FareBasisCode.fromJson(e))
          .toList(),
    );
  }
}

class FareBasisCode {
  final String fareBasis;
  final String airline;
  final String paxType;
  final String origin;
  final String destination;
  final String fareRst;
  final String fareInfoKey;
  final String key;

  FareBasisCode({
    required this.fareBasis,
    required this.airline,
    required this.paxType,
    required this.origin,
    required this.destination,
    required this.fareRst,
    required this.fareInfoKey,
    required this.key,
  });

  factory FareBasisCode.fromJson(Map<String, dynamic> json) {
    return FareBasisCode(
      fareBasis: json['fareBasis'],
      airline: json['airline'],
      paxType: json['paxType'],
      origin: json['origin'],
      destination: json['destination'],
      fareRst: json['fareRst'],
      fareInfoKey: json['fareInfoKey'],
      key: json['key'],
    );
  }
}

class Currency {
  final dynamic gds;
  final String clientCurrency;
  final double roe;
  final String currencyCode;

  Currency({
    this.gds,
    required this.clientCurrency,
    required this.roe,
    required this.currencyCode,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      gds: json['gds'],
      clientCurrency: json['clientCurrency'],
      roe: json['roe']?.toDouble() ?? 0.0,
      currencyCode: json['currencyCode'],
    );
  }
}

class Airport {
  final String airportCode;
  final String airportName;
  final String cityCode;
  final String cityName;
  final String countryCode;
  final String countryName;
  final dynamic continentCode;
  final dynamic continentName;

  Airport({
    required this.airportCode,
    required this.airportName,
    required this.cityCode,
    required this.cityName,
    required this.countryCode,
    required this.countryName,
    this.continentCode,
    this.continentName,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      airportCode: json['airportCode'],
      airportName: json['airportName'],
      cityCode: json['cityCode'],
      cityName: json['cityName'],
      countryCode: json['countryCode'],
      countryName: json['countryName'],
      continentCode: json['continentCode'],
      continentName: json['continentName'],
    );
  }
}

class Airline {
  final String airlineCode;
  final String airlineName;
  final dynamic airlineLogoPath;

  Airline({
    required this.airlineCode,
    required this.airlineName,
    this.airlineLogoPath,
  });

  factory Airline.fromJson(Map<String, dynamic> json) {
    return Airline(
      airlineCode: json['airlineCode'],
      airlineName: json['airlineName'],
      airlineLogoPath: json['airlineLogoPath'],
    );
  }
}

class FlightFareSearchRQ {
  final String searchId;
  final String companyId;
  final String branchId;
  final String sourceMedia;
  final String customerType;
  final bool alternateAirport;
  final String journeyType;
  final bool directFlight;
  final bool flexi;
  final String gds;
  final bool flexiType;
  final bool isBaggage;
  final String currency;
  final double maxAmount;
  final String cabinClass;
  final String outboundClass;
  final String inboundClass;
  final String fareType;
  final bool availableFare;
  final bool refundableFare;
  final String preferedAirline;
  final PaxDetails paxDetails;
  final List<Segment> segments;
  final bool isCache;
  final dynamic continent;

  FlightFareSearchRQ({
    required this.searchId,
    required this.companyId,
    required this.branchId,
    required this.sourceMedia,
    required this.customerType,
    required this.alternateAirport,
    required this.journeyType,
    required this.directFlight,
    required this.flexi,
    required this.gds,
    required this.flexiType,
    required this.isBaggage,
    required this.currency,
    required this.maxAmount,
    required this.cabinClass,
    required this.outboundClass,
    required this.inboundClass,
    required this.fareType,
    required this.availableFare,
    required this.refundableFare,
    required this.preferedAirline,
    required this.paxDetails,
    required this.segments,
    required this.isCache,
    this.continent,
  });

  factory FlightFareSearchRQ.fromJson(Map<String, dynamic> json) {
    return FlightFareSearchRQ(
      searchId: json['searchId'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      sourceMedia: json['sourceMedia'],
      customerType: json['customerType'],
      alternateAirport: json['alternateAirport'],
      journeyType: json['journeyType'],
      directFlight: json['directFlight'],
      flexi: json['flexi'],
      gds: json['gds'],
      flexiType: json['flexiType'],
      isBaggage: json['isBaggage'],
      currency: json['currency'],
      maxAmount: json['maxAmount']?.toDouble() ?? 0.0,
      cabinClass: json['cabinClass'],
      outboundClass: json['outboundClass'],
      inboundClass: json['inboundClass'],
      fareType: json['fareType'],
      availableFare: json['availableFare'],
      refundableFare: json['refundableFare'],
      preferedAirline: json['preferedAirline'],
      paxDetails: PaxDetails.fromJson(json['paxDetails']),
      segments: (json['segments'] as List).map((e) => Segment.fromJson(e)).toList(),
      isCache: json['isCache'],
      continent: json['continent'],
    );
  }
}

class PaxDetails {
  final int adults;
  final int youth;
  final int children;
  final int infants;
  final int infantOnSeat;

  PaxDetails({
    required this.adults,
    required this.youth,
    required this.children,
    required this.infants,
    required this.infantOnSeat,
  });

  factory PaxDetails.fromJson(Map<String, dynamic> json) {
    return PaxDetails(
      adults: json['adults'],
      youth: json['youth'],
      children: json['children'],
      infants: json['infants'],
      infantOnSeat: json['infantOnSeat'],
    );
  }
}

class Segment {
  final String origin;
  final String destination;
  final String originType;
  final String destinationType;
  final String date;
  final String time;
  final dynamic legs;

  Segment({
    required this.origin,
    required this.destination,
    required this.originType,
    required this.destinationType,
    required this.date,
    required this.time,
    this.legs,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      origin: json['origin'],
      destination: json['destination'],
      originType: json['originType'],
      destinationType: json['destinationType'],
      date: json['date'],
      time: json['time'],
      legs: json['legs'],
    );
  }
} 