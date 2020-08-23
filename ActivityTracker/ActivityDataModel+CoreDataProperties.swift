//
//  ActivityDataModel+CoreDataProperties.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 8/22/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData


extension ActivityDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityDataModel> {
        return NSFetchRequest<ActivityDataModel>(entityName: "ActivityDataModel")
    }

    @NSManaged public var activity: Activity?

}
