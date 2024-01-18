//
//  HomeDomain.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/15/24.
//

import Foundation
import CoreLocation

class HomeDomain{
    let homeDataSource: HomeDataSource
    
    init(){
        homeDataSource = HomeDataSource()
    }
    func getDateObjectFromDateString(date: String) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        print(dateFormatter.date(from: date)!)
        return dateFormatter.date(from: date)!
    }
    
    func queryMarkersInRadius(center: CLLocationCoordinate2D, radiusInMeters: Double) async -> [String: Marker]{
        var Markers = [String: Marker]()
        var allData = await homeDataSource.queryMarkersForRadiusInCenter(center: center, radiusInMeters: radiusInMeters)
        //change all this to a mapper function later
        for (documentID, _) in allData{
            print(allData[documentID]!)
            let dateTimeString = allData["89k6IVtlj7gM0yIQRj22"]!["dateTime"]
            print(dateTimeString!)
            do{
                try allData[documentID]!["dateTime"] = getDateObjectFromDateString(date: dateTimeString as! String)
            }
            catch{
                print("error trying to get Date Object from date String")
            }
            let cllcoordinate = CLLocationCoordinate2D(latitude: allData[documentID]?["lat"] as! CLLocationDegrees, longitude: allData[documentID]?["long"] as! CLLocationDegrees)
            allData[documentID]?["coordinate"] = cllcoordinate
            let dateTime = allData[documentID]!["dateTime"] as! Date
            let geohash = allData[documentID]!["geohash"] as! String
            let coordinate = (allData[documentID]!["coordinate"] as! CLLocationCoordinate2D)
            let markerType = allData[documentID]!["markerType"] as! String
            let yes = allData[documentID]!["yes"] as! Int
            let no = allData[documentID]!["no"] as! Int
            let marker = Marker(dateTime: dateTime, geohash: geohash, coordinate: coordinate, markerType: markerType, yes: yes, no: no)
            Markers[documentID] = marker
        }
        print(Markers)
        return Markers
    }
    func addMarker(marker: Marker) async{
        await homeDataSource.addMarker(coordinate: marker.coordinate, markerType: marker.markerType, dateTime: marker.dateTime)
    }
}

