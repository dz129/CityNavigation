//
//  Marker.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/15/24.
//

import Foundation
import CoreLocation

struct Marker{
    let dateTime: Date
    let geohash: String
    let coordinate: CLLocationCoordinate2D
    let markerType: String
    let yes: Int
    let no: Int
    
    init(dateTime: Date, geohash: String, coordinate: CLLocationCoordinate2D, markerType: String, yes: Int, no: Int) {
        self.dateTime = dateTime
        self.geohash = geohash
        self.coordinate = coordinate
        self.markerType = markerType
        self.yes = yes
        self.no = no
    }
}
