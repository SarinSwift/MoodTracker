//
//  ViewController.swift
//  moodTracker
//
//  Created by Sarin Swift on 11/8/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    var cellId = "mood entry cell"
    var entries: [MoodEntry] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let goodEntry = MoodEntry(mood: .good, date: Date())
        let badEntry = MoodEntry(mood: .bad, date: Date())
        let nuetralEntry = MoodEntry(mood: .neutral, date: Date())
        
        entries = [goodEntry, badEntry, nuetralEntry]
        tableView.reloadData()
        
        if WCSession.isSupported(){
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error != nil {
            print("Error: \(error)")
        }else{
            print("Ready to communicate with apple watch.")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Deactivated")
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            print("This is the user info \(userInfo)")
            
            guard let mood = userInfo["mood"] as? String, let date =  userInfo["date"] as? Date else{ return}
            let newEntry : MoodEntry!
            
            switch mood {
            case "Amazing":
                newEntry = MoodEntry(mood: .amazing, date: date)
            case "Good":
                newEntry = MoodEntry(mood: .good, date: date)
            case "Bad":
                newEntry = MoodEntry(mood: .bad, date: date)
            case "Terrible":
                newEntry = MoodEntry(mood: .terrible, date: date)
            case "Neutral":
                newEntry = MoodEntry(mood: .neutral, date: date)
            default:
                return
            }
            
            self.entries.append(newEntry)
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
        guard let identifier = segue.identifier else {
            return
        }
        
        guard let detailedEntryViewController = segue.source as? MoodDetailedViewController else {
            return print("storyboard unwind segue not set up correctly")
        }
        
        switch identifier {
        case "unwind from save":
            let newMood: MoodEntry.Mood = detailedEntryViewController.mood
            let newDate: Date = detailedEntryViewController.date
            if detailedEntryViewController.isEditingEntry {
                guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
                print("from save button and editing an existing entry")
                updateEntry(mood: newMood, date: newDate, at: selectedIndexPath.row)
                }
             else {
                createEntry(mood: newMood, date: newDate)
                print("from save button and adding a new entry")
            }
        case "unwind from cancel":
            print("from cancel button")
        default:
            break
        }
    }
    
    @IBAction func pressCalendar(_ sender: UIBarButtonItem) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let calendarVc = mainStoryboard.instantiateViewController(withIdentifier: "calendar vc") as? CalendarViewController else {
            return print("storyboard not set up correctly, check the identity of \"calendar vc\"")
        }
        present(calendarVc, animated: true, completion: nil)
    }
    
    func createEntry(mood: MoodEntry.Mood, date: Date) {
        let newEntry = MoodEntry(mood: mood, date: date)
        entries.insert(newEntry, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func updateEntry(mood: MoodEntry.Mood, date: Date, at index: Int) {
        entries[index].mood = mood
        entries[index].date = date
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func deleteEntry(at index: Int) {
        entries.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    
    // ending the selected entry to the destination view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show new entry":
                guard let entryDetailsViewController = segue.destination as? MoodDetailedViewController else {
                    return print("storyboard not set up correctly, 'show entry details' segue needs to segue to a 'MoodDetailedViewController'")
                }
                entryDetailsViewController.mood = MoodEntry.Mood.none
                entryDetailsViewController.date = Date()
                
            case "show entry details":
                // knowing which index you choose
                guard let selectedCell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: selectedCell) else {
                        return print("failed to locate index path from sender")
                }
                // setting the destination
                guard let entryDetailsViewController = segue.destination as? MoodDetailedViewController else {
                    return print("storyboard not set up properely, 'show entry details' segue needs to segue to a 'MoodDetailsViewController'")
                }
                let entry = entries[indexPath.row]  // let entry = moodService.entries[indexPath.row]
                entryDetailsViewController.mood = entry.mood
                entryDetailsViewController.date = entry.date
                entryDetailsViewController.isEditingEntry = true
            default: break
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MoodEntryTableViewCell
        
        let entry = entries[indexPath.row]
        cell.configure(entry)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEntry = entries[indexPath.row]
        print("Selected mood was \(selectedEntry.mood.stringValue)")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteEntry(at: indexPath.row)
        default:
            break
        }
    }

}
