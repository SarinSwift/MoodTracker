//
//  MoodRow.swift
//  moodTracker
//
//  Created by Sarin Swift on 12/4/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import WatchKit

class MoodRow: NSObject {
    
    var entries: [MoodEntry] = []
    
    @IBOutlet weak var moodImg: WKInterfaceImage!
    @IBOutlet weak var moodLabel: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let goodEntry = MoodEntry(mood: .good, date: Date())
        let badEntry = MoodEntry(mood: .bad, date: Date())
        let neutralEntry = MoodEntry(mood: .neutral, date: Date())
        let amazingEntry = MoodEntry(mood: .amazing, date: Date())
        let terribleEnrty = MoodEntry(mood: .terrible, date: Date())
        
        entries = [goodEntry, badEntry, neutralEntry, amazingEntry, terribleEnrty]
        table.setNumberOfRows(entries.count, withRowType: "moodRow")
    }
    
    var moodObj: MoodEntry? {
        didSet {
            guard let moodObj = moodObj else { return }
            moodImg.setImage(UIImage(named: moodObj.mood.stringValue))
            moodLabel.setText(moodObj.mood.stringValue)
        }
    }
    
}
