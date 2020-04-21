//
//  ViewController.swift
//  MyFirstApp
//
//  Created by Takashi Nakano on 2020/04/21.
//  Copyright © 2020 Takashi Nakano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        outputLabel.text = "Stay Home."
        
        
    }


    @IBOutlet weak var outputLabel: UILabel!
}

