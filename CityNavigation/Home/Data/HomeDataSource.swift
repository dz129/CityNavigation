//
//  HomeDataSource.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/14/24.
//

import Foundation
import CoreLocation
//make sure the data source only has one job to consolidate unmodified raw
class HomeDataSource{
    let homeRemoteDataSource: HomeRemoteDataSource
    init(){
        homeRemoteDataSource = HomeRemoteDataSource()
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D, markerType: String, dateTime: Date) async{
        await homeRemoteDataSource.addMarker(coordinate: coordinate, markterType: markerType, dateTime: dateTime)
    }
    
    func queryMarkersForRadiusInCenter(center: CLLocationCoordinate2D, radiusInMeters: Double) async -> [String: [String: Any]]{
        return await homeRemoteDataSource.queryMarkersForRadiusInCenter(center: center, radiusInMeters: radiusInMeters)
    }
}
