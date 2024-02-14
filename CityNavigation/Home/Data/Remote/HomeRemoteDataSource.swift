//
//  HomeRemoteDataaSource.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/14/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import UIKit
import GeoFire
import CoreLocation

class HomeRemoteDataSource{
    let db: Firestore
    init(){
        if FirebaseApp.app() == nil{
            FirebaseApp.configure()
        }
        self.db = Firestore.firestore()
    }
    func getDateString(dateTime: Date) -> String{
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)  // this is only available effective iOS 11 and macOS 10.13
        return formatter.string(from: dateTime)
    }
    func addMarker(coordinate: CLLocationCoordinate2D, markterType: String, dateTime: Date) async{
        //need to add a comment section later
        let lat = coordinate.latitude
        let long = coordinate.longitude
        let hash = GFUtils.geoHash(forLocation: coordinate)
        let currentDateAndTimeString = getDateString(dateTime: dateTime)
        let documentData: [String: Any] = [
            "geohash" : hash,
            "markerType" : markterType,
            "lat" : lat,
            "long" : long,
            "yes" : 0,
            "no" : 0,
            "dateTime" : currentDateAndTimeString
        ]
        do{
            let ref = try await db.collection("markers").addDocument(data: documentData)
        }
        catch{
            print("failed")
        }
    }
    @Sendable func fetchMatchingDocs(from query: Query, center: CLLocationCoordinate2D, radiusInMeters: Double) async throws -> [QueryDocumentSnapshot]{
        let snapshot = try await query.getDocuments()
        return snapshot.documents.filter{ document in
            let lat = document.data()["lat"] as? Double ?? 0
            let long = document.data()["long"] as? Double ?? 0
            let markerType = document.data()["markerType"] ?? ""
            let yes = document.data()["yes"] ?? -1
            let no = document.data()["no"] ?? -1
            let dateTime =  document.data()["dateTime"]
            let coordinates = CLLocation(latitude: lat, longitude: long)
            let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
            
            let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                return distance <= radiusInMeters
        }
    }
    func queryMarkersForRadiusInCenter(center: CLLocationCoordinate2D, radiusInMeters: Double) async -> [String: [String: Any]]{
        var allData = [String: [String: Any]]()
        let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radiusInMeters)
        let queries = queryBounds.map { bound -> Query in
            return db.collection("markers")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        do {
          let matchingDocs = try await withThrowingTaskGroup(of: [QueryDocumentSnapshot].self) { group -> [String: [String: Any]] in
            for query in queries {
              group.addTask {
                  try await self.fetchMatchingDocs(from: query, center: center, radiusInMeters: radiusInMeters)
              }
            }
            var matchingDocs = [QueryDocumentSnapshot]()
            for try await documents in group {
              matchingDocs.append(contentsOf: documents)
            }
              for document in matchingDocs {
                  // Extracting the document ID
                  let documentID = document.documentID
                  
                  // Extracting data from the document
                  let data = document.data()
                  
                  // Adding the data to the dictionary
                  allData[documentID] = data
                  
                  let dateTimeString = allData[documentID]?["dateTime"]
                  //don't do this in the datasource layer, do this in domain
                  /*
                  do{
                      try allData[documentID]?["dateTime"] = getDateObjectFromDateString(date: dateTimeString as! String)
                  }
                      let coordinate = CLLocationCoordinate2D(latitude: allData[documentID]?["lat"] as! CLLocationDegrees, longitude: allData[documentID]?["long"] as! CLLocationDegrees)
                      allData[documentID]?["coordinate"] = coordinate
                   */
              }
              return allData
          }
        } catch {
          //nothing
        }
        return allData
    }
}

