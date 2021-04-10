//
//  File.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/8/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//

import Foundation
class StringStructs{
    
    public struct ActivityTypes{
        //to make a singlton but i don't like that cause multi threading
        //static let instance: ActivityTypes = ActivityTypes()
        static let run = "Run"
        static let bike = "Bike"
        static let hike = "Hike"
        static let other = "Other"
        //this is dumb but I cannot get the protocol to work as I want
        static let allActivities = [run, bike, hike, other]
    }
    
    //don't think this needs to be loopable
    public struct Segues {
        static let addActivity = "addActivity"
        static let UnwindToProfile = "UnwindToProfile"
        static let SelectActivitySegue = "SelectActivitySegue"
    }
    
    
}

//protocol PropertyLoopable {
//    static func allProperties() throws -> [String]
//}
////hopefully loops through and gives the correct value for the structs
//extension PropertyLoopable{
//    static func allProperties() -> [String] {
//        var results: [String] = []
//        let mirror = Mirror(reflecting: self)
//
//        for (_ , propertyValue) in mirror.children{
//            guard let propertyString = propertyValue as? String else{
//                continue
//            }
//            results.append(propertyString)
//        }
//        return results
//    }
//}
