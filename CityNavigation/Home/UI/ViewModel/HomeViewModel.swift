//
//  HomeViewModel.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/18/24.
//

import Foundation
import CoreLocation

class HomeViewModel: ObservableObject{
    let homeDomain = HomeDomain()
    @Published var center: CLLocationCoordinate2D
    @Published var zoomLevel: CGFloat
    @Published var markers: [String: Marker] = [:]
    //pixelDensity used to calculate the amount of meters to query
    var pixelDensity = 6000.0
    init(center: CLLocationCoordinate2D, zoomLevel: CGFloat) {
        self.center = center
        self.zoomLevel = zoomLevel
    }
    func setNewMapSettings(center: CLLocationCoordinate2D, zoomLevel: CGFloat){
        self.center = center
        self.zoomLevel = zoomLevel
    }
    
    func getMarkersForZoomLevel() async{
        if (zoomLevel >= 19){
            self.markers = await homeDomain.queryMarkersInRadius(center: center, radiusInMeters: pixelDensity * 0.15)
        }
        else if (zoomLevel >= 18){
            self.markers = await homeDomain.queryMarkersInRadius(center: center, radiusInMeters: pixelDensity * 0.3)
        }
        else if (zoomLevel >= 17){
            self.markers = await homeDomain.queryMarkersInRadius(center: center, radiusInMeters: pixelDensity * 0.6)
        }
        else if (zoomLevel >= 16){
            print("being hit at 16")
            self.markers = await homeDomain.queryMarkersInRadius(center: center, radiusInMeters: pixelDensity * 1.2)
        }
        else if (zoomLevel >= 15){
            self.markers = await homeDomain.queryMarkersInRadius(center: center, radiusInMeters: pixelDensity * 2.4)
        }
        else if (zoomLevel >= 14){
            self.markers = await homeDomain.queryMarkersInRadius(center: center, radiusInMeters: pixelDensity * 4.8)
        }
        else if (zoomLevel >= 13){
            self.markers = await homeDomain.queryMarkersInRadius(center: center, radiusInMeters: pixelDensity * 10)
        }
        else{
            self.markers = [:]
        }
        print("markersFromVM", self.markers)
        print("center:", self.center, "zoom", self.zoomLevel)
    }
    func addMarker(marker: Marker) async{
        await homeDomain.addMarker(marker: marker)
    }
    func updateCenter(center: CLLocationCoordinate2D){
        self.center = center
    }
}
