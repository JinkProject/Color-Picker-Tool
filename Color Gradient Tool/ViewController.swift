//
//  ViewController.swift
//  Color Gradient Tool
//
//  Created by Stephen Whitfield on 12/18/15.
//  Copyright © 2015 Stephen Whitfield. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var colorPicker: RAColorPicker!
    @IBOutlet weak var colorPreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.colorPickerDelegate = self
    }

}

extension ViewController: RAColorPickerDelegate {
    func pickerColorDidChange(pickerColor: UIColor) {
        colorPreview.backgroundColor = pickerColor
    }
}

