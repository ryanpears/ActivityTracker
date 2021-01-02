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
        
        cell.setPath(path: activity.path)
        cell.setTime(time: activity.time)
        cell.setPace(pace: activity.avePace)
        cell.setDistance(distance: activity.distance)
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        
        if segue.identifier == "addActivity"{
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
        if let sourceVC = sender.source as? ActivityViewController,
           let newActivity = sourceVC.currentActivity{
            //add another row
            let newIndexPath = IndexPath(row: activities.count, section: 0)
            //adds first
            activities.insert(newActivity, at: 0)
            tableView.insertRows(at: [newIndexPath], with: .top)
            os_log("new activity added to activity array", type: .debug)
            //reload data this feels a little hacky probably will change.
            tableView.reloadData()
            //create the coreData model to be saved
            let wrappedActivityDescription = NSEntityDescription.entity(forEntityName: "ActivityDataModel", in: context)!
            let wrappedActivity = ActivityDataModel(entity: wrappedActivityDescription, insertInto: self.context)
            wrappedActivity.activity = newActivity
            if wrappedActivity.activity == nil {
                fatalError("activity is nil this is bad")
            }
            //did not work
            //self.context.refresh(wrappedActivity, mergeChanges: true)
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
            let data:[ActivityDataModel] = try context.fetch(ActivityDataModel.fetchRequest())
            for wrappedActivity in data{
                if wrappedActivity.activity != nil{
                    self.activities.append(wrappedActivity.activity!)
                }
            }
            //reload data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            print("error fetching data: \(error)")
        }
    }
    
    //MARK: private test functions
    private func loadSampleActivity(){
        var path:[PosTime] = []
        path.append(PosTime.init(time:0, possition: CLLocation(latitude:  44.098681, longitude: -114.955616))!)
        path.append(PosTime.init(time: 1840, possition: CLLocation(latitude:  44.0842558, longitude: -114.9731255))!)
        path.append(PosTime.init(time: 3443, possition: CLLocation(latitude:  44.0747604, longitude: -114.9897766))!)
        path.append(PosTime.init(time:4575, possition: CLLocation(latitude:  44.067977, longitude: -115.0050545))!)
        path.append(PosTime.init(time: 6000, possition:CLLocation(latitude:  44.0549014, longitude: -115.0131226))!)
        let act1 = Activity.init(path: path)
        activities.append(act1)
    }
}

