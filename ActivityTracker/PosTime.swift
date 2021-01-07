//
//  PosTime.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 7/30/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//

import Foundation
import os.log
import CoreLocation


//Don't think I need and archiving path since the data should be stored in CoreData
public class PosTime: NSObject, NSSecureCoding{
    
    public static var supportsSecureCoding: Bool{get{return true}}
    
    
    //no need to be private these are constants
    let time: Double//may make a time date object
    let pos: CLLocation//CLLocation makes so this is not Codable
    //if CLLocation can't be saved
//    let  latitude: CLLocationDegrees
//    let longitude: CLLocationDegrees
//    let altitude: CLLocationDistance
//    let vAccuraty: CLLocationAccuracy
//    let hAccuraty: CLLocationAccuracy
//    let timeStamp: Date
       
    private struct PropertyKey{
        static let time = "time"
        static let possition = "pos"
    }
    
    init?(time: Double, possition: CLLocation){
    if time < 0.0{
        return nil
    }
        self.time = time
        self.pos = possition
        //self.latitude = possition.coordinate
    }
    
    
    
    //MARK: NSCoding
    public func encode(with coder: NSCoder) {
        coder.encode(NSNumber(value: time), forKey: PropertyKey.time)
        coder.encode(pos, forKey: PropertyKey.possition)
    }
    
    public required init?(coder: NSCoder) {
        guard let time = coder.decodeObject(of: NSNumber.self, forKey: PropertyKey.time)
        else{
            os_log("cannot decode PosTime.time", type: .error)
            return nil
        }
        guard let pos = coder.decodeObject(of: CLLocation.self, forKey: PropertyKey.possition)
            else{
            os_log("cannot decode PosTime.pos", type: .error)
            return nil
        }
        self.time = time.doubleValue
        self.pos = pos
        super.init()
    }
}

