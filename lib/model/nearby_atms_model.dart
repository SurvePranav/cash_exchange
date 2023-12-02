class NearbyAtmsModel {
  final String? businessStatus;
  final Geometry? geometry;
  final String? icon;
  final String? iconBackgroundColor;
  final String? iconMaskBaseUri;
  final String? name;
  final OpeningHours? openingHours;
  final String? placeId;
  final PlusCode? plusCode;
  final double? rating;
  final String? reference;
  final String? scope;
  final List<String>? types;
  final int? userRatingsTotal;
  final String? vicinity;

  NearbyAtmsModel({
    this.businessStatus,
    this.geometry,
    this.icon,
    this.iconBackgroundColor,
    this.iconMaskBaseUri,
    this.name,
    this.openingHours,
    this.placeId,
    this.plusCode,
    this.rating,
    this.reference,
    this.scope,
    this.types,
    this.userRatingsTotal,
    this.vicinity,
  });

  NearbyAtmsModel.fromJson(Map<String, dynamic> json)
      : businessStatus = json['business_status'] as String?,
        geometry = (json['geometry'] as Map<String, dynamic>?) != null
            ? Geometry.fromJson(json['geometry'] as Map<String, dynamic>)
            : null,
        icon = json['icon'] as String?,
        iconBackgroundColor = json['icon_background_color'] as String?,
        iconMaskBaseUri = json['icon_mask_base_uri'] as String?,
        name = json['name'] as String?,
        openingHours = (json['opening_hours'] as Map<String, dynamic>?) != null
            ? OpeningHours.fromJson(
                json['opening_hours'] as Map<String, dynamic>)
            : null,
        placeId = json['place_id'] as String?,
        plusCode = (json['plus_code'] as Map<String, dynamic>?) != null
            ? PlusCode.fromJson(json['plus_code'] as Map<String, dynamic>)
            : null,
        rating = json['rating'] as double?,
        reference = json['reference'] as String?,
        scope = json['scope'] as String?,
        types =
            (json['types'] as List?)?.map((dynamic e) => e as String).toList(),
        userRatingsTotal = json['user_ratings_total'] as int?,
        vicinity = json['vicinity'] as String?;

  Map<String, dynamic> toJson() => {
        'business_status': businessStatus,
        'geometry': geometry?.toJson(),
        'icon': icon,
        'icon_background_color': iconBackgroundColor,
        'icon_mask_base_uri': iconMaskBaseUri,
        'name': name,
        'opening_hours': openingHours?.toJson(),
        'place_id': placeId,
        'plus_code': plusCode?.toJson(),
        'rating': rating,
        'reference': reference,
        'scope': scope,
        'types': types,
        'user_ratings_total': userRatingsTotal,
        'vicinity': vicinity
      };
}

class Geometry {
  final Location? location;
  final Viewport? viewport;

  Geometry({
    this.location,
    this.viewport,
  });

  Geometry.fromJson(Map<String, dynamic> json)
      : location = (json['location'] as Map<String, dynamic>?) != null
            ? Location.fromJson(json['location'] as Map<String, dynamic>)
            : null,
        viewport = (json['viewport'] as Map<String, dynamic>?) != null
            ? Viewport.fromJson(json['viewport'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() =>
      {'location': location?.toJson(), 'viewport': viewport?.toJson()};
}

class Location {
  final double? lat;
  final double? lng;

  Location({
    this.lat,
    this.lng,
  });

  Location.fromJson(Map<String, dynamic> json)
      : lat = json['lat'] as double?,
        lng = json['lng'] as double?;

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class Viewport {
  final Northeast? northeast;
  final Southwest? southwest;

  Viewport({
    this.northeast,
    this.southwest,
  });

  Viewport.fromJson(Map<String, dynamic> json)
      : northeast = (json['northeast'] as Map<String, dynamic>?) != null
            ? Northeast.fromJson(json['northeast'] as Map<String, dynamic>)
            : null,
        southwest = (json['southwest'] as Map<String, dynamic>?) != null
            ? Southwest.fromJson(json['southwest'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() =>
      {'northeast': northeast?.toJson(), 'southwest': southwest?.toJson()};
}

class Northeast {
  final double? lat;
  final double? lng;

  Northeast({
    this.lat,
    this.lng,
  });

  Northeast.fromJson(Map<String, dynamic> json)
      : lat = json['lat'] as double?,
        lng = json['lng'] as double?;

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class Southwest {
  final double? lat;
  final double? lng;

  Southwest({
    this.lat,
    this.lng,
  });

  Southwest.fromJson(Map<String, dynamic> json)
      : lat = json['lat'] as double?,
        lng = json['lng'] as double?;

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class OpeningHours {
  final bool? openNow;

  OpeningHours({
    this.openNow,
  });

  OpeningHours.fromJson(Map<String, dynamic> json)
      : openNow = json['open_now'] as bool?;

  Map<String, dynamic> toJson() => {'open_now': openNow};
}

class PlusCode {
  final String? compoundCode;
  final String? globalCode;

  PlusCode({
    this.compoundCode,
    this.globalCode,
  });

  PlusCode.fromJson(Map<String, dynamic> json)
      : compoundCode = json['compound_code'] as String?,
        globalCode = json['global_code'] as String?;

  Map<String, dynamic> toJson() =>
      {'compound_code': compoundCode, 'global_code': globalCode};
}
