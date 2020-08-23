//
//  ViewController.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 7/29/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import os.log

class ActivityViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeDisp: UILabel!
    
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var paceDisp: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceDisp: UILabel!
    
    private var mapViewRegion = MKCoordinateRegion()
    private var locationManager: CLLocationManager?
    private var timer:ActivityTimer?
    
    //private var timerIsRunning = false//used to make sure only one timer runs at a time
    //currently data for each activity will be stored here until the activity is saved
    private var totalActivityTime:Double = 0.0
    private var distance = 0.0
    private var path: [PosTime] = []
    
    //TEST REMOVE LATER
    //private var testCoords = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //I think I should instantiate a new activity class here
        //setting up location manager
        locationManager = CLLocationManager()
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            os_log("have premission for location", type: .debug)
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //want the most accurate
            //set up map view only if the user agrees
            mapView.showsUserLocation = true
//            let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
//            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//
//            mapView.setRegion(region, animated: true)
        }else{
            os_log("not given location premissions", type: .debug)
        }
        
        //Map view settings
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.center = view.center
        
        //setting up timer
        timer = ActivityTimer(timeUpdated:{ [weak self] timeInterval in
            //make a strong self in the callback to avoid errors
            //os_log("in ActivityTimer callback block")
            guard let strongSelf = self else {
                return
            }
            strongSelf.timeDisp.text = strongSelf.timeString(time: timeInterval)
            strongSelf.totalActivityTime = timeInterval
            
        })
        
//        //TESTCOORDINATES
//        let coords1 = CLLocationCoordinate2D(latitude: 21.1233668, longitude: 79.1027889)
//        let coords2 = CLLocationCoordinate2D(latitude: 21.122083, longitude: 79.1135274)
//        let coords3 = CLLocationCoordinate2D(latitude: 21.1235418, longitude: 79.1150327)
//        let coords4 = CLLocationCoordinate2D(latitude: 21.1384636, longitude: 79.1189755)
//        testCoords = [coords1,coords2,coords3,coords4]
//
    }
    
   //MARK: LocationMangerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager?.startUpdatingLocation()
        case .denied, .notDetermined, .restricted:
            self.locationManager?.stopUpdatingLocation()
        @unknown default:
            return
        }
    }
    
    //NOTE: may want to add points to the path in this function since the locations array could make this much more accurate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //only record points while the timer is running
        if timer?.isPaused ?? true {
            os_log("not recording yet", type: .debug)
            setMapRegion(currentLocation: locations[locations.count-1])
            return
        }
        //checks the authorization
        //THIS MIGHT NOT BE NESSICARY SINCE WE ARE ALREADY GETTING A LOCATION
        //NEED TO TEST
//if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        //appends a possition to the path
        let time = totalActivityTime
        let possition = locations[locations.count-1]
        guard let currPosTime = PosTime(time: time, possition: possition) else{
            os_log("Failed to initilize last possition", type: .debug)
            return
        }
        path.append(currPosTime)
        os_log("appending current location", type: .debug)
        
        //updates the distance and pace
        //MIGHT MAKE A FUNCTION TO UPDATE THE CORRECT STATS
        if path.count > 1{
            distance += calcDistance(point1:
                path[path.count-1].pos, point2: path[path.count-2].pos)
            distanceDisp.text = String(format: "%.2f", distance)
            
            let pace: Double = totalActivityTime/distance
            paceDisp.text = timeString(time: pace)
        }
//}
       
        //let currentLocation = path[path.count-1].pos
        
        //create MKPolyline from path
        //MayAlso make this a different func
        var possitionsInTwoD = [CLLocationCoordinate2D]()
        for case let point in path{//loops over non-nil(kinda cool
            let coordinate = CLLocationCoordinate2D(latitude: point.pos.coordinate.latitude, longitude: point.pos.coordinate.longitude)
            possitionsInTwoD.append(coordinate)
        }

        let line = MKPolyline(coordinates: possitionsInTwoD, count: possitionsInTwoD.count)
        //posstion map
        //NEED TO CHANGE THE DELTA VALUES LATER
        setMapRegion(currentLocation: currPosTime.pos)
        mapView.addOverlay(line)
        
    }
    
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        if let polyline = overlay as? MKPolyline{
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .blue
            lineRenderer.lineWidth = 2.0
            return lineRenderer
        }
        os_log("could not render line", type: .debug)
        return MKPolylineRenderer()//returns nothing
    }

    //MARK: Actions
    @IBAction func StartPauseButton(_ sender: UIButton) {
        timer?.toggle()
    }
    
    //MARK: private functions
    private func timeString(time: Double) -> String {
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutes = Int(time.truncatingRemainder(dividingBy: 60 * 60) / 60)
        return String(format: "%.2d:%.2d", minutes, seconds)
    }
    
    //Note: this is inacurrate I will need to account for error a bit better.
    private func calcDistance(point1: CLLocation, point2: CLLocation) -> Double{
        var dist = point1.distance(from: point2)
        //convert to km and round to avoid larger recorded distances
        dist = Double(round(dist*1000)/1000000)
        return dist
    }
    
    private func setMapRegion(currentLocation: CLLocation){
        let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        mapView.setRegion(region, animated: true)
    }
}



