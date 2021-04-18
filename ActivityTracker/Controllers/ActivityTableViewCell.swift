//
//  ActivityTableViewCell.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 8/10/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//

import UIKit
import os.log
import MapKit

class ActivityTableViewCell: UITableViewCell, MKMapViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var activityTypeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceDisp: UILabel!
    
    @IBOutlet weak var elevationGainLabel: UILabel!
    @IBOutlet weak var elevationGainDisp: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeDisp: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    private var pathLine: MKPolyline?
    private var path: [CLLocation] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // should set up the map view
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: MKMapView
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
    
    private func setMapRegion(centerLocation: CLLocation){
        let center = CLLocationCoordinate2D(latitude: centerLocation.coordinate.latitude, longitude: centerLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        mapView.setRegion(region, animated: true)
    }
    
    private func formatMapForCell(){
        
        if !path.isEmpty{
           var possitionsInTwoD = [CLLocationCoordinate2D]()
            for case let point in path{
                let coordinate = CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
                possitionsInTwoD.append(coordinate)
            }
            let newLine:MKPolyline = MKPolyline(coordinates: possitionsInTwoD, count: possitionsInTwoD.count)
            
            //remove old path from old version of this cell
            if self.pathLine != nil{
                mapView.removeOverlay(self.pathLine!)
            }
            
            mapView.setVisibleMapRect(newLine.boundingMapRect, edgePadding: UIEdgeInsets.init(top:50, left: 50, bottom: 50, right: 50), animated: false)
            
            //adds new line to map
            self.pathLine = newLine
            mapView.addOverlay(pathLine!)
            
        }
    }
    
    //MARK: setters
    
    func setCellValues(activity: Activity){
        setPath(path: activity.path)
        setTime(time: activity.time)
        setElevationGain(elevationGain: activity.elevationGain)
        setDistance(distance: activity.distance)
        setTitle(activity: activity)
    }
    
    private func setPath(path: [CLLocation]){
        self.path = path
        //can only do this after given a path
        formatMapForCell()
    }
    
    //TODO add a meteric and imperial version 
    private func setTime(time: Double){
        self.timeDisp.text = MeasurementUtils.timeString(time: time)
    }
    
    private func setElevationGain(elevationGain: Double){
        self.elevationGainDisp.text = String(format: "%.2f m", elevationGain)
    }
    
    private func setDistance(distance: Double){
        let distanceInKm = MeasurementUtils.metersToKilometers(m: distance)
        self.distanceDisp.text = String(format: "%.2f km", distanceInKm)
    }
    
    private func setTitle(activity: Activity){
        //switch on type of activity to set title
        switch activity {
        case (is Run):
            activityTypeLabel.text = StringStructs.ActivityTypes.run
            
        case (is Bike):
            activityTypeLabel.text = StringStructs.ActivityTypes.bike
            
        case (is Hike):
            activityTypeLabel.text = StringStructs.ActivityTypes.hike
            
        default:
            activityTypeLabel.text = StringStructs.ActivityTypes.other
        }
    }
    
}
