//
//  mouse.swift
//  mouse
//
//  Created by Evan Phibbs on 8/27/14.
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
    
    @IBOutlet var accX : UILabel = nil
    @IBOutlet var accY : UILabel = nil
    @IBOutlet var accZ : UILabel = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(accelerometerData: CMAccelerometerData!, error:NSError!)in
            self.outputAccelData(accelerometerData.acceleration)
            if error
            {
                println("\(error)")
            }
        })
        
        motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(gyroData: CMGyroData!, error: NSError!)in
            self.outputRotationData(gyroData.rotationRate)
            if error
            {
                println("\(error)")
            }
        })
    }
    func outputAccelData(acceleration:CMAcceleration) {
        
    }
}