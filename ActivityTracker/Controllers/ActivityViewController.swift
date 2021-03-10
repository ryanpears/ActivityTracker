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

class ActivityViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var activitySelectionButton: UIButton!
    var selectedActivity: String = StringStructs.ActivityTypes.other
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeDisp: UILabel!
    
    @IBOutlet weak var averagePaceLabel: UILabel!
    @IBOutlet weak var averagePaceDisp: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceDisp: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private var mapViewRegion = MKCoordinateRegion()
    private var locationManager: CLLocationManager?
    private var timer:ActivityTimer?
    
    //currently data for each activity will be stored here until the activity is saved
    private var totalActivityTime:Double = 0.0
    private var distance = 0.0
    private(set) var path: [CLLocation] = []
    //used for calculating distance in a kinda lazy way.
    private var lastSignificatePossition: CLLocation?
    //probably should make private
    //private(set) var currentActivity: Activity?
    
    //TEST REMOVE LATER
    //private var testCoords = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // maybe need to assign a UIPopoverdelagate
        
        //I think I should instantiate a new activity class here
        //setting up location manager
        locationManager = CLLocationManager()
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            os_log("have premission for location", type: .debug)
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //want the most accurate
            locationManager?.allowsBackgroundLocationUpdates = true //want to update from background
            //set up map view only if the user agrees
            mapView.showsUserLocation = true
        }else{
            os_log("not given location premissions", type: .debug)
            //possibly display error to user
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
            os_log("in ActivityTimer callback block")
            guard let strongSelf = self else {
                return
            }
            strongSelf.timeDisp.text = MeasurementUtils.timeString(time: timeInterval)
            strongSelf.totalActivityTime = timeInterval
            
        })
        //disable save button
        saveButton.isEnabled = false
        
        activitySelectionButton.setTitle(StringStructs.ActivityTypes.other, for: .normal)
        
        
        //Zero out the stats
        timeDisp.text = MeasurementUtils.timeString(time: 0) + " \nmin"
        averagePaceDisp.text = String(format: "%.2f", 0) + " \nkm"
        distanceDisp.text = String(format: "%.2f", 0) + " \nkm"
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
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //only record points while the timer is running
        if timer?.isPaused ?? true {
            os_log("not recording yet", type: .debug)
            setMapRegion(currentLocation: locations[locations.count-1])
            return
        }
        //checks the authorization
        //THIS MIGHT NOT BE NESSICARY SINCE WE ARE ALREADY GETTING A LOCATION
        //appends a possition to the path
        //let time = totalActivityTime
        let currPoss = locations[locations.count-1]
        path.append(currPoss)
        os_log("appending current location", type: .debug)
        
        //updates the distance and pace
        //MIGHT MAKE A FUNCTION TO UPDATE THE CORRECT STATS
        if path.count > 1{
            //hopefully forceful unwrap won't cause problems.
            let nextDistance = calcDistance(point1: lastSignificatePossition!,
                                            point2: path[path.count-1])
            if nextDistance != 0{
                distance += nextDistance
                lastSignificatePossition = path[path.count-1]
            }
               
            distanceDisp.text = String(format: "%.2f", distance)
            
            let pace: Double = totalActivityTime/distance
            averagePaceDisp.text = MeasurementUtils.timeString(time: pace)
            
        }else{
            lastSignificatePossition = path[0]
        }
       
        //let currentLocation = path[path.count-1].pos
        
        //create MKPolyline from path
        //MayAlso make this a different func
        //NOTE I THINK THIS CAUSES THE SLOW DOWN IN THE APP MAYBE MAKE ASYNC
        var possitionsInTwoD = [CLLocationCoordinate2D]()
        for case let point in path{//loops over non-nil(kinda cool)
            let coordinate = CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
            possitionsInTwoD.append(coordinate)
        }

        let line = MKPolyline(coordinates: possitionsInTwoD, count: possitionsInTwoD.count)
        //posstion map
        //NEED TO CHANGE THE DELTA VALUES LATER
        setMapRegion(currentLocation: currPoss)
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
        if (timer?.isPaused)!{
            startStopButton.setTitle("start", for: .normal)
            saveButton.isEnabled = true
        }else{
            startStopButton.setTitle("stop", for: .normal)
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func SelectActivityPressed(_ sender: UIButton) {
        //self.performSegue(withIdentifier: "SelectActivitySegue", sender: self)
        self.performSegue(withIdentifier: StringStructs.Segues.SelectActivitySegue, sender: self)
    }
    
    //MARK: navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //for popover
        if segue.identifier == StringStructs.Segues.SelectActivitySegue{
            let dest = segue.destination
            if let selectionPopup = dest.popoverPresentationController{
                selectionPopup.delegate = self
            }
            return
        }else if segue.identifier == StringStructs.Segues.addActivity{//TODO: make this per segue
            guard let button = sender as? UIBarButtonItem, button === saveButton else{
                os_log("save button wasn't pressed", type: .debug)
                return
            }
            //new activity created to be passed to table view
            os_log("activity created unwinding now", type: .debug)
        }
        
    }
    
    @IBAction func unwindToActivity(_ sender: UIStoryboardSegue){
        //nothing in here really yet
    }
    
    
    
    //MARK: private functions
    /*private func timeString(time: Double) -> String {
        //checking for valid input
        if time.isNaN || time.isInfinite {
            return String(format: "%.2d:%.2d", 0, 0)
        }
        
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutes = Int(time.truncatingRemainder(dividingBy: 60 * 60) / 60)
        return String(format: "%.2d:%.2d", minutes, seconds)
    }*/
    
    //Note: this is inacurrate I will need to account for error a bit better.
    //possibly move this to MeasurementUtils
    private func calcDistance(point1: CLLocation, point2: CLLocation) -> Double{
        var dist = point1.distance(from: point2)
        if dist > point2.horizontalAccuracy {
            //convert to km and round to avoid larger recorded distances
            dist = Double(round(dist*1000)/1000000)
            return dist
        }
        //not accurate enough
        return 0
    }
    
    private func setMapRegion(currentLocation: CLLocation){
        let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        mapView.setRegion(region, animated: true)
    }
}



