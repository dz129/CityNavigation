//
//  HomeViewController.swift
//  CityNavigation
//
//  Created by Daniel Zhang on 1/11/24.
//

import Foundation
import MapboxMaps
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections
import MapboxSearch
import MapboxSearchUI
import SwiftUI
import Combine

class MapViewController : UIViewController, AnnotationInteractionDelegate{
    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?
    var reportButton: UIButton?
    var homeViewModel: HomeViewModel?
    var beginAnnotation: PointAnnotation?
    private var cancellables: Set<AnyCancellable> = []
    let searchController = MapboxSearchController()
    
    fileprivate func setUpReportButton() {
        let reportButton = UIButton()
        reportButton.setTitle("Button", for: .normal)
        reportButton.backgroundColor = .blue
        reportButton.addTarget(self, action: #selector (reportButtonIsPressed), for: .touchUpInside)
        view.addSubview(reportButton)
        view.bringSubviewToFront(reportButton)
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reportButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            reportButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    fileprivate func setUpGoNowButton(){
        let reportButton = UIButton()
        reportButton.setTitle("Go Now", for: .normal)
        reportButton.backgroundColor = .green
        reportButton.addTarget(self, action: #selector (goNowButtonIsPressed), for: .touchUpInside)
        view.addSubview(reportButton)
        view.bringSubviewToFront(reportButton)
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reportButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            reportButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
    }
    fileprivate func setUpCancelButton(){
        let reportButton = UIButton()
        reportButton.setTitle("Cancel", for: .normal)
        reportButton.backgroundColor = .red
        reportButton.addTarget(self, action: #selector (cancelButtonIsPressed), for: .touchUpInside)
        view.addSubview(reportButton)
        view.bringSubviewToFront(reportButton)
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reportButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            reportButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -80)
        ])
    }
    fileprivate func setupView() async {
        //create a navigation map view with the size of the screen
        //you can also have a parameter that includes a custom theme from mapbox
        removeAllSubviews()
        navigationMapView = NavigationMapView(frame: view.bounds)
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationMapView.userLocationStyle = .puck2D()
        navigationMapView.navigationCamera.viewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        //create a long press variable that is a long press recognizer with the target as the class itself and the action as the @objc function
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        navigationMapView.addGestureRecognizer(longPress)
        
        //allows the width and height to be flexible so when you turn the device, it works
        view.addSubview(navigationMapView)
        homeViewModel = HomeViewModel(center: navigationMapView.mapView.mapboxMap.coordinate(for:navigationMapView.mapView.center), zoomLevel: navigationMapView.mapView.cameraState.zoom)
        await homeViewModel?.getMarkersForZoomLevel()
        bindViewModel()
        setUpReportButton()
        navigationMapView.mapView.mapboxMap.onNext(event: .mapLoaded){
            [weak self] _ in
            guard let self = self else {return}
            self.navigationMapView.pointAnnotationManager?.delegate = self
        }
        searchController.delegate = self
        let panelController = MapboxPanelController(rootViewController: searchController)
        addChild(panelController)
    }
    private func bindViewModel() {
        homeViewModel!.$markers
            .sink { [weak self] in self?.createMarkers(markers: $0) }
            .store(in: &cancellables)
    }
    func createMarkers(markers: [String:Marker]){
        print("beingrun")
        for (_, value) in markers{
            print(value)
            createAnnotationPoint(coordinate: value.coordinate)
        }
    }
    func removeAllSubviews() {
        
       // perform a loop to iterate each subView
       view.subviews.forEach { subView in
            
       // removing subView from its parent view
          subView.removeFromSuperview()
       }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await self.setupView()
        }

    }
    @objc func reportButtonIsPressed(){
        if let currPostion = navigationMapView.mapView.location.latestLocation?.coordinate {
            createAnnotationPoint(coordinate: currPostion)
        }
        else{
            print("error")
        }
    }
    @objc func goNowButtonIsPressed(){
        let navigationViewController = NavigationViewController(for: routeResponse!, routeIndex: 0, routeOptions: routeOptions!)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
        }
    @objc func cancelButtonIsPressed() async{
        print("being pressed")
        searchController.resetSearchUI(animated: true)
        await setupView()
    }
    //user does a long press
    //@objc stands for objective c
    func createAnnotationPoint(coordinate: CLLocationCoordinate2D){
        var pointAnnotation = PointAnnotation(coordinate: coordinate)

        // Make the annotation show a red pin
        var circleAnnotation = CircleAnnotation(centerCoordinate: coordinate)
        circleAnnotation.circleColor = StyleColor(.red)

        // Create the `CircleAnnotationManager`, which will be responsible for handling this annotation
        let circleAnnotationManager = navigationMapView.mapView.annotations.makeCircleAnnotationManager()

        // Add the annotation to the manager.
        circleAnnotationManager.annotations = [circleAnnotation]
    }
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer){
        guard sender.state == .began else {return}
        let point = sender.location(in: navigationMapView)
        let coordinate = navigationMapView.mapView.mapboxMap.coordinate(for: point)
        createAnnotationPoint(coordinate: coordinate)
    }
    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        //the route options sets the waypoints it will use and what type of vehicle it is, so change the profile identifier when we actually start modifying this code
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination])
        
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }
                
                strongSelf.routeResponse = response
                strongSelf.routeOptions = routeOptions
                strongSelf.drawRoute(route:route)
                
                if var annotation = strongSelf.navigationMapView.pointAnnotationManager?.annotations.first{
                    annotation.textField = "Start Nav"
                    annotation.textColor = .init(UIColor.white)
                    annotation.textHaloColor = .init(UIColor.systemBlue)
                    annotation.textHaloWidth = 2
                    annotation.textAnchor = .top
                    annotation.textRadialOffset = 1.0
                     
                    strongSelf.beginAnnotation = annotation
                    strongSelf.navigationMapView.pointAnnotationManager?.annotations = [annotation]
                }
            }
        }
    }
    func drawRoute(route: MapboxDirections.Route){
        navigationMapView.show([route])
        navigationMapView.showRouteDurations(along: [route])
        navigationMapView.showWaypoints(on: route)
    }
    
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
    guard annotations.first?.id == beginAnnotation?.id,
    let routeResponse = routeResponse, let routeOptions = routeOptions else {
    return
    }
    let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: routeOptions)
    navigationViewController.modalPresentationStyle = .fullScreen
    self.present(navigationViewController, animated: true, completion: nil)
    }
}
extension MapViewController: SearchControllerDelegate {
    func searchResultSelected(_ searchResult: SearchResult) {
        if let currPostion = navigationMapView.mapView.location.latestLocation?.coordinate {
            let searchCoordinate = searchResult.coordinate
            calculateRoute(from: currPostion, to: searchCoordinate)
            setUpCancelButton()
            setUpGoNowButton()
        }
        else{
            print("error")
        }
    }
    func categorySearchResultsReceived(category: MapboxSearchUI.SearchCategory, results: [SearchResult]) { }
    func userFavoriteSelected(_ userFavorite: FavoriteRecord) { }
}
struct MapViewControllerRepresentable: UIViewControllerRepresentable{
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        //nothin
    }
    
    typealias UIViewControllerType = MapViewController
    
}
