//
//  Date+String.swift
//  moodTracker
//
//  Created by Sarin Swift on 11/27/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import UIKit

extension Date {
    var stringValue: String {
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .short)
    }
}
