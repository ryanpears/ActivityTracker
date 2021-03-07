//
//  ActivitySelectionPopup.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/6/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//

import UIKit

class ActivitySelectionPopup: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var activityPicker: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    
    private var activityTypes: [String] = [String]()
    
    private(set) var selectedActivity: String = ""
        
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //connect data to Picker
        self.activityPicker.delegate = self
        self.activityPicker.dataSource = self
        
        activityTypes = ["Run", "Bike", "Ski", "Other"]
        selectedActivity = activityTypes[0]
        
        selectButton.setTitle("Select", for: .normal)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedActivity = activityTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activityTypes[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activityTypes.count
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let dest = segue.destination as? ActivityViewController{
            dest.activitySelectionButton.setTitle(selectedActivity, for: .normal)
        }
    }
}
