//
//  Constants.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import Foundation
import CoreLocation

let stopLatitudes = [37.77639, 37.776348, 37.757599, 37.757583, 37.709537, 37.709544, 37.65589, 37.655946, 37.631128, 37.631108, 37.59988, 37.599797, 37.58764, 37.587552, 37.580197, 37.580186, 37.568087, 37.568294, 37.552938, 37.552994, 37.537868, 37.537814, 37.52089, 37.520844, 37.50805, 37.507933, 37.486159, 37.486101, 37.464645, 37.464584, 37.454856, 37.454745, 37.443475, 37.443405, 37.429365, 37.429333, 37.407323, 37.407277, 37.394459, 37.394402, 37.378916, 37.378789, 37.370598, 37.370484, 37.353238, 37.353189, 37.342384, 37.342338, 37.329239, 37.329231, 37.31174, 37.31175, 37.284102, 37.284062, 37.252422, 37.252379, 37.129363, 37.129321, 37.085225, 37.086653, 37.003538, 37.003485, 37.330196, 37.311638]

let stopLongitudes = [-122.394992, -122.394935, -122.39188, -122.392404, -122.401586, -122.40198, -122.40487, -122.405018, -122.411968, -122.412076, -122.386647, -122.386832, -122.36265, -122.362708, -122.3449, -122.345075, -122.323851, -122.324092, -122.309338, -122.309608, -122.297349, -122.297461, -122.275738, -122.275816, -122.26015, -122.260266, -122.231936, -122.232, -122.19779, -122.197869, -122.182297, -122.182405, -122.164614, -122.164697, -122.141927, -122.141978, -122.107069, -122.107125, -122.075956, -122.075994, -122.031372, -122.031423, -121.997114, -121.997135, -121.93608, -121.936135, -121.9146, -121.914677, -121.903011, -121.903173, -121.883721, -121.883999, -121.841955, -121.842037, -121.797643, -121.797683, -121.650244, -121.650304, -121.610049, -121.610936, -121.566088, -121.566225, -121.901985, -121.883403]

public extension CLLocationCoordinate2D {
    public static func stopCoordinates(stop: StopName) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(stopLatitudes[stop.rawValue], stopLatitudes[stop.rawValue])
    }
}

public enum StopName: Int {
    case sanFranciscoNorthbound = 0, sanFranciscoSouthbound,
    twentySecondStreetNorthbound, twentySecondStreetSouthbound,
    bayshoreNorthbound, bayshoreSouthbound,
    southSanFranciscoNorthbound, southSanFranciscoSouthbound,
    sanBrunoNorthbound, sanBrunoSouthbound,
    millbraeNorthbound, millbraeSouthbound,
    broadwayNorthbound, broadwaySouthbound,
    burlingameNorthbound, burlingameSouthbound,
    sanMateoNorthbound, sanMateoSouthbound,
    haywardParkNorthbound, haywardParkSouthbound,
    hillsdaleNorthbound, hillsdaleSouthbound,
    belmontNorthbound, belmontSouthbound,
    sanCarlosNorthbound, sanCarlosSouthbound,
    redwoodCityNorthbound, redwoodCitySouthbound,
    athertonNorthbound, athertonSouthbound,
    menloParkNorthbound, menloParkSouthbound,
    paloAltoNorthbound, paloAltoSouthbound,
    californiaAveNorthbound, californiaAveSouthbound,
    sanAntonioNorthbound, sanAntonioSouthbound,
    mountainViewNorthbound, mountainViewSouthbound,
    sunnyvaleNorthbound, sunnyvaleSouthbound,
    lawrenceNorthbound, lawrenceSouthbound,
    santaClaraNorthbound, santaClaraSouthbound,
    collegeParkNorthbound, collegeParkSouthbound,
    sanJoseDiridonNorthbound, sanJoseDiridonSouthbound,
    tamienNorthbound, tamienSouthbound,
    capitolNorthbound, capitolSouthbound,
    blossomHillNorthbound, blossomHillSouthbound,
    morganHillNorthbound, morganHillSouthbound,
    sanMartinNorthbound, sanMartinSouthbound,
    gilroyNorthbound, gilroySouthbound,
    sanJose,
    tamien
}

