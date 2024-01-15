//
//  CityNavigationApp.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/11/24.
//

import SwiftUI
import CoreLocation

@main
class MyApp {
    static func main() async {
      let hrds = HomeRemoteDataSource()
        let data: () = await hrds.queryMarkersForRadiusInCenter(center: CLLocationCoordinate2D(latitude: 38.9072, longitude: 77.0369), radiusInMeters: 1000)
  }
}
