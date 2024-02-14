//
//  CityNavigationApp.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/11/24.
//

import SwiftUI
import CoreLocation
import Firebase

@main
struct CityNavigationApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

