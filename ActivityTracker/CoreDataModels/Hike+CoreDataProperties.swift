//
//  Hike+CoreDataProperties.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/9/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData


extension Hike {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hike> {
        return NSFetchRequest<Hike>(entityName: "Hike")
    }

    @NSManaged public var minElevation: Double
    @NSManaged public var maxElevation: Double
    @NSManaged public var averagePace: Double

}
