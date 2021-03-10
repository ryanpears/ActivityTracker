//
//  ProfileTableViewController.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 7/29/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//

import UIKit
import os.log
import CoreLocation
import CoreData

class ProfileTableViewController: UITableViewController {
    
    

    //USE THIS CLASS TO DEFINE ACTIONS OF THE TABLE VIEW
    
    //MARK: Properties
    private var activities = [Activity]()
    //used in deletion This is a bad idea since my coredata entity is wack and I need to fix
    //private var managedActivities = [ActivityDataModel]()
    //needed to use coreData saving and loading
    //private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //loadSampleActivity()
        fetch()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    

    // MARK: - Table view data source
    //maybe will need to change
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    //doesn't fix problem
    override func tableView(_ tableView: UITableView, heightForRowAt
    indexPath: IndexPath) -> CGFloat {
            return 475
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //allows cell to be dequeued
        let cellIdentifier = "ActivityTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ActivityTableViewCell else{
            fatalError("shit")
            }
        
        let activity = activities[indexPath.row]
        
        cell.setCellValues(activity: activity)
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // all rows should be editible
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            os_log("deleting activity now", type: .debug)
            // Delete the row from the data source
            self.deleteCell(forCell: indexPath.row)
            //not sure if I need self but being safe
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == StringStructs.Segues.addActivity{
            //DO NOTHING FOR NOW may add stuff later.
        }else if segue.identifier == "showActivity"{
            //TODO: add showActivity view/controller.
            if let destVC = segue.destination as? ActivityViewController{
                //destVC.activity = activities[IndexPath.row]
            }
        }
    }
    //MARK: Actions
    @IBAction func unwindToProfile(sender: UIStoryboardSegue){
        if let sourceVC = sender.source as? ActivityViewController{
            
            let newActivity = createNewActivity(path: sourceVC.path, activityType: sourceVC.selectedActivity)
            //add another row
            let newIndexPath = IndexPath(row: activities.count, section: 0)
            //adds first
            activities.insert(newActivity, at: 0)
            tableView.insertRows(at: [newIndexPath], with: .top)
            os_log("new activity added to activity array", type: .debug)
            //reload data this feels a little hacky probably will change.
            tableView.reloadData()
            
            //save the data
            save()
            
        }
    }
    
    //MARK: CoreData Saving/Loading
    private func save(){
        do{
            //name change to stop weird coredata stuff
            NSKeyedArchiver.setClassName("ActivityTracker.activity", for: Activity.self)
            try self.context.save()
        }catch{
            print("error saving data: \(error)")
        }
    }
    
    private func fetch(){
        do{
            //name change to stop weird coredata stuff
            NSKeyedUnarchiver.setClass(Activity.self, forClassName: "ActivityTracker.activity")
            let data:[Activity] = try context.fetch(Activity.fetchRequest())
            for activity in data{
                if activity != nil{
                    self.activities.insert(activity, at:0)
                }
            }
            //reload data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            print("error fetching data: \(error)")
            //possibly change to different type of ACTivity.
        }
    }
    
   
    /**
            deletes the cell at the row given
     */
    private func deleteCell(forCell: Int){
        context.delete(activities[forCell])
        self.activities.remove(at: forCell)
        self.save()
    }
    
    //MARK: private test functions
    private func createNewActivity(path: [CLLocation], activityType: String) -> Activity{
        
        let newActivity: Activity
        //TODO stop this stringy shit
        switch activityType{
        case StringStructs.ActivityTypes.run:
            //create the coreData model to be saved
            let activityDescription = NSEntityDescription.entity(forEntityName: StringStructs.ActivityTypes.run, in: self.context)!
            newActivity = Activity(entity: activityDescription, insertInto: self.context)
            //ALWAYS ALWAYS DO THIS WHEN CREATING A NEW ACTIVITY
            newActivity.psuedoinit(path: path)
            
        case StringStructs.ActivityTypes.bike:
            //create coreData model to be saved
            let activityDescription = NSEntityDescription.entity(forEntityName: StringStructs.ActivityTypes.bike, in: self.context)!
            newActivity = Activity(entity: activityDescription, insertInto: self.context)
            newActivity.psuedoinit(path: path)
            
        case StringStructs.ActivityTypes.hike:
            //create coreData model to be saved
            let activityDescription = NSEntityDescription.entity(forEntityName: StringStructs.ActivityTypes.hike, in: self.context)!
            newActivity = Activity(entity: activityDescription, insertInto: self.context)
            newActivity.psuedoinit(path: path)
            
        default:
            //other
            //create the coreData model to be saved
            let activityDescription = NSEntityDescription.entity(forEntityName: "Activity", in: self.context)!
            newActivity = Activity(entity: activityDescription, insertInto: self.context)
            //ALWAYS ALWAYS DO THIS WHEN CREATING A NEW ACTIVITY
            newActivity.psuedoinit(path: path)
        }
        
        return newActivity
    }
    
   /* private func loadSampleActivity(){
        var path:[PosTime] = []
        path.append(PosTime.init(time:0, possition: CLLocation(latitude:  44.098681, longitude: -114.955616))!)
        path.append(PosTime.init(time: 1840, possition: CLLocation(latitude:  44.0842558, longitude: -114.9731255))!)
        path.append(PosTime.init(time: 3443, possition: CLLocation(latitude:  44.0747604, longitude: -114.9897766))!)
        path.append(PosTime.init(time:4575, possition: CLLocation(latitude:  44.067977, longitude: -115.0050545))!)
        path.append(PosTime.init(time: 6000, possition:CLLocation(latitude:  44.0549014, longitude: -115.0131226))!)
        let act1 = Activity.init(path: path)
        activities.append(act1)
    }*/
}

