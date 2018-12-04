//
//  CalendarViewController.swift
//  moodTracker
//
//  Created by Sarin Swift on 11/27/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    @IBAction func pressDone(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
