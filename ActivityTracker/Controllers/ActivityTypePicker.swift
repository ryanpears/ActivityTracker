//
//  ActivityTypePicker.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/4/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//

import Foundation
import UIKit
import os.log

class ActivityTypePicker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    
    @IBOutlet weak var picker: UIPickerView!
    
    private var activityTypes: [String] = ["Run", "Ski", "Bike", "Hike", "Other"]
    
    private(set) var selectedActivity: String = "Other"
    
   
    
    override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
            
            // Connect data:
            self.picker.delegate = self
            self.picker.dataSource = self
            
            // Input the data into the array
            //activityTypes = ["Run", "Ski", "Bike", "Hike", "Other"]
        }
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
            // The parameter named row and component represents what was selected.
        selectedActivity = activityTypes[row]
        
        //send the selection back to ActivityController
        //self.unwind(for: <#T##UIStoryboardSegue#>, towards: ActivityViewController)
        //self.unwind(for: UIStoryboardSegue, towards: ActivityViewController)
        //self.performSegue(withIdentifier: "SelectActivity", sender: self)
        self.performSegue(withIdentifier: "unwindToActivityWithSender:", sender: self)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activityTypes[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1//columns
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activityTypes.count//rows
    }
    
    //MARK: Actions
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //not sure I need to do anything else
        os_log("unwinding from activitypicker now", type: .debug)
    }
}
