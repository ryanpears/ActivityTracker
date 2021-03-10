//
//  Run+CoreDataProperties.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/7/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData


extension Run {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Run> {
        return NSFetchRequest<Run>(entityName: "Run")
    }

    @NSManaged public var minElevation: Double
    @NSManaged public var maxElevation: Double
    @NSManaged public var averagePace: Double

}
