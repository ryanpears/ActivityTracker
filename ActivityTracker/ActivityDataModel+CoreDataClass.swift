//
//  ActivityDataModel+CoreDataClass.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 8/22/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//
//


//NOTE TIME:
//ok so make core data set up with an abstract(maybe not at first) activity class
//attributes being a CLLocation array (this has a timestamp so not postime stuff needed)

//next make certain classes to be for certian activities such as run, hike, where theey calculate a useful stat about it like pace.

//only thing im worried about is CLLocation being encoded.

import Foundation
import CoreData

@objc(ActivityDataModel)
public class ActivityDataModel: NSManagedObject {

}
