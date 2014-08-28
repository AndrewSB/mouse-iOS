//
//  ViewController.swift
//  mouse
//
//  Created by Evan Phibbs on 8/26/14.
//  Copyright (c) 2014 Evan Phibbs. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    var xaccel: Double = 0
    var yaccel: Double = 0
    var zaccel: Double = 0
    
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var accz: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(accelerometerData: CMAccelerometerData!, error:NSError!)in
            self.outputAccelData(accelerometerData.acceleration)
        })
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func outputAccelData(acceleration:CMAcceleration) {
        
    }


}

