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
    
    @IBOutlet weak var avePaceLabel: UILabel!
    @IBOutlet weak var avePaceDisp: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeDisp: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var path: [PosTime] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // should set up the map view
        mapView.delegate = self
        if !path.isEmpty{
           var possitionsInTwoD = [CLLocationCoordinate2D]()
            for case let point in path{
                let coordinate = CLLocationCoordinate2D(latitude: point.pos.coordinate.latitude, longitude: point.pos.coordinate.longitude)
                possitionsInTwoD.append(coordinate)
            }


            let line = MKPolyline(coordinates: possitionsInTwoD, count: possitionsInTwoD.count)
            setMapRegion(currentLocation: path[0].pos)
            mapView.addOverlay(line)
        }
        
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
    
    private func setMapRegion(currentLocation: CLLocation){
        let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        mapView.setRegion(region, animated: true)
    }
    
    //MARK: setters
    func setPath(path: [PosTime]){
        self.path = path
    }
    
    //TODO add a meteric and imperial version 
    func setTime(time: Double){
        let seconds = MeasurementUtils.millisecondsToSeconds(ms: time);
        self.timeDisp.text = MeasurementUtils.timeString(time: seconds) + " min"
    }
    
    func setPace(pace: Double){
        let newPace = MeasurementUtils.millisecondsPerMeterToKilometersPerHour(mspm: pace)
        self.avePaceDisp.text = MeasurementUtils.timeString(time: newPace) + " km/min"
    }
    
    func setDistance(distance: Double){
        self.distanceDisp.text = String(format: "%.2f km", distance)
    }
    
    //MARK: private functions probably replace
    /*private func timeString(time: Double) -> String {
        //checking for valid input
        if time.isNaN || time.isInfinite {
            return String(format: "%.2d:%.2d", 0, 0)
        }
        
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutes = Int(time.truncatingRemainder(dividingBy: 60 * 60) / 60)
        return String(format: "%.2d:%.2d", minutes, seconds)
    }*/

}
