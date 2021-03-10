//
//  Bike+CoreDataProperties.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/9/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData


extension Bike {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bike> {
        return NSFetchRequest<Bike>(entityName: "Bike")
    }

    @NSManaged public var averagePace: Double
    @NSManaged public var minElevation: Double
    @NSManaged public var maxElevation: Double
    @NSManaged public var maxSpeed: Double

}
