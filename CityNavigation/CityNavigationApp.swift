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
        await hrds.addMarker(coordinate: CLLocationCoordinate2D(latitude: 38.9072, longitude: 77.0369), markterType: "test")
  }
}
