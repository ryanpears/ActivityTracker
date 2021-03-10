//
//  Activity+CoreDataProperties.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/7/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var distance: Double
    @NSManaged public var path: [CLLocation]
    @NSManaged public var time: Double
    @NSManaged public var elevationGain: Double

}

extension Activity : Identifiable {

}
