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
import CoreBluetooth
import Darwin

class ViewController: UIViewController {
    let motionManager = CMMotionManager()
    var avgx = 0.0
    var avgy = 0.0
    var avgz = 0.0
    
    var cntr = 0
    var til = 1000
    
    @IBOutlet weak var xdist: UILabel!
    @IBOutlet weak var ydist: UILabel!
    
    var sumx = 0.0
    var sumy = 0.0
    var sumz = 0.0
    
    var distx: Double = 0
    var disty: Double = 0
    
    var velx: Double = 0
    var vely: Double = 0
    
    var zerocntr = 0
    var runningsum: Double = 0
    
    var lastaccxs: [Double] = Array()
    var lastaccys: [Double] = Array()
    var numlastacc = 5
    
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var accZ: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.accelerometerUpdateInterval = 0.001
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(accelerometerData: CMAccelerometerData!, error:NSError!) in
            //calibration
            var acc = accelerometerData.acceleration
            if self.cntr < self.til {
                self.sumx += acc.x
                self.sumy += acc.y
                self.cntr++
            } else if self.cntr == self.til {
                self.avgx = self.sumx/Double(self.cntr)
                self.avgy = self.sumy/Double(self.cntr)
                self.cntr++
            } else {
                var accx = acc.x - self.avgx
                var accy = acc.y - self.avgy
                /*
                if countElements(self.lastaccxs) > self.numlastacc-1 {
                    self.lastaccxs.removeAtIndex(0)
                    self.lastaccys.removeAtIndex(0)
                }
                self.lastaccxs.append(acc.x)
                self.lastaccys.append(acc.y)
                var accx = self.lastaccxs.reduce(0,+)/Double(self.numlastacc)
                var accy = self.lastaccys.reduce(0,+)/Double(self.numlastacc)
                    
                accx = NSString(format: "%.3f", accx - self.avgx).doubleValue
                accy = NSString(format: "%.3f", accx - self.avgy).doubleValue
                */
                /*if (fabs(accx) >= 0.01 && fabs(self.velx) <= -0.01) || (fabs(accx) <= -0.01 && fabs(self.velx) >= 0.01) {
                    self.velx /= 2
                }*/
                
                if fabs(accx) > 0.001 {
                    self.velx += accx*0.1
                } else if fabs(NSString(format: "%.3f", self.velx).doubleValue) != 0 {
                    self.velx /= 2
                }
                if fabs(accy) > 0.001 {
                    self.vely += accx*0.1
                } else if fabs(NSString(format: "%.3f", self.velx).doubleValue) != 0 {
                    self.vely /= 2
                }
                if accx >= 0 {
                    println(NSString(format: "accx:  %.2f", accx))
                    self.accX.text = NSString(format: " %.2f", accx)
                } else {
                    println(NSString(format: "accx: %.2f", accx))
                    self.accX.text = NSString(format: "%.2f", accx)
                }
                var clickl = false
                var clickr = false
                //self.bluetoothManager.startAdvertising(["value": 1])
            }
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func outputAccelData(acceleration:CMAcceleration) {
        accX.text = "1,2,3"
        //NSString(format: "X: %.4f", acceleration.x)
        //accY.text = NSString(format: "Y: %.4f", acceleration.y)
        //accZ.text = NSString(format: "Z: %.4f", acceleration.z)
    }
*/

}

