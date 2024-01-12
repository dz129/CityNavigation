//
//  SearchViewControler.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/11/24.
//

import UIKit
import MapboxSearch
import MapboxSearchUI
import SwiftUI
 
class SearchViewController: UIViewController {
let searchController = MapboxSearchController()
 
override func viewDidLoad() {
super.viewDidLoad()
    searchController.delegate = self
    let panelController = MapboxPanelController(rootViewController: searchController)
    addChild(panelController)
}
}
 
extension SearchViewController: SearchControllerDelegate {
    func searchResultSelected(_ searchResult: SearchResult) { }
    func categorySearchResultsReceived(category: MapboxSearchUI.SearchCategory, results: [SearchResult]) { }
    func userFavoriteSelected(_ userFavorite: FavoriteRecord) { }
}
struct SearchViewControllerRepresentable: UIViewControllerRepresentable{
    func makeUIViewController(context: Context) -> SearchViewController {
        return SearchViewController()
    }
    
    func updateUIViewController(_ uiViewController: SearchViewController, context: Context) {
        //nothin
    }
    
    typealias UIViewControllerType = SearchViewController
    
}
