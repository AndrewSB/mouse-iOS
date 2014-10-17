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
import Darwin

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var peripheral: CBPeripheralManager!
    var service: CBMutableService!
    var characteristic: CBMutableCharacteristic!
    var advertisedata: NSDictionary!
    var dataToSend: NSString!
    var sendDataIndex: Int = 0
    var central: CBCentral!
    var max_bytes = 20
    var xchar = CBMutableCharacteristic(type: CBUUID.UUIDWithString("0771752E-7B66-49F6-9053-6E3DF9F2343B"), properties: nil, value: nil, permissions: nil)
    var ychar = CBMutableCharacteristic(type: CBUUID.UUIDWithString("0771752E-7B66-49F6-9053-6E3DF9F2343B"), properties: nil, value: nil, permissions: nil)
    
    @IBAction func button(sender: UIButton) {
        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [CBUUID.UUIDWithString("0771752E-7B66-49F6-9053-6E3DF9F2343B")]])
    }
    
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
    
    var velx: Double = 0
    var vely: Double = 0
    
    var lastaccxs: [Double] = Array()
    var lastavgxs: [Double] = Array()
    
    var lastaccys: [Double] = Array()
    var lastavgys: [Double] = Array()
    
    var lastslopesx: [Double] = Array()
    
    var numlastacc = 11
    var params: [Double] = Array()
    //var slopeweight = [1.0,2.0,3.0,2.0,1.0]
    var weight = [1.0,2.0,3.0,4.0,5.0,6.0,5.0,4.0,3.0,2.0,1.0]
    //var weight = [1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,8.0,7.0,6.0,5.0,4.0,3.0,2.0,1.0]
    //var weight = [1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,13.0,12.0,11.0,10.0,9.0,8.0,7.0,6.0,5.0,4.0,3.0,2.0,1.0]
    var start: CFAbsoluteTime!
    var diff: CFAbsoluteTime!
    var first = true
    
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var accZ: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //peripheral = CBPeripheralManager(delegate: self, queue: nil)
        
        //motionManager.accelerometerUpdateInterval = 0.01
        //motionManager.gyroUpdateInterval = 0.01
        motionManager.deviceMotionUpdateInterval = 0.001
        for i in 1...5 {
            self.params.append(Double(arc4random_uniform(1)))
        }
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(motionData: CMDeviceMotion!, error:NSError!) in
            var attitude = motionData.attitude
            var gravity = motionData.gravity
            var usracceleration = motionData.userAcceleration
            var rotation = motionData.rotationRate
            //println(NSString(format: "Net: %.2f", sumacceleration.x))
            if countElements(self.lastaccxs) > self.numlastacc-1 {
                var sumx = 0.0
                var sumy = 0.0
                var i = 0
                for e in self.lastaccxs {
                    sumx += self.weight[i]*e
                    i++
                }
                i = 0
                for e in self.lastaccys {
                    sumy += self.weight[i]*e
                    i++
                }
                //var avgx = sumx/9.0
                //var avgy = sumy/9.0
                //var avgx = sumx/196.0
                //var avgy = sumy/196.0
                var avgx = sumx/81.0
                var avgy = sumy/81.0
                self.lastavgxs.append(avgx)
                self.lastavgys.append(avgy)
                if self.lastavgxs.count > 5 {
                    self.lastavgxs.removeAtIndex(0)
                    self.lastavgys.removeAtIndex(0)
                }
                
                var sum1 = 0.0
                var sumx1 = 0.0
                var sumx12 = 0.0
                var sumx2 = 0.0
                var j = 0.0
                for el in self.lastavgxs {
                    sum1 += Double(el)*j
                    sumx1 += Double(el)
                    sumx12 += pow(el,2)
                    sumx2 += j
                    j += 1.0
                }
                var b1 = 1/(Double(self.lastavgxs.count)*sum1-sumx1*sumx2)*(Double(self.lastavgxs.count)*sumx12 - pow(sumx1, 2))
                var b0 = (avgx - b1*sumx2/Double(self.lastavgxs.count))
                
                var stddevx = 0.0
                for e in self.lastaccxs {
                    stddevx += pow(e - avgx, 2)
                }
                stddevx = sqrt(stddevx)/Double(countElements(self.lastaccxs))
                
                var stddevy = 0.0
                for e in self.lastaccys {
                    stddevy += pow(e - avgy, 2)
                }
                stddevy = sqrt(stddevy)/Double(countElements(self.lastaccys))
                
                
                if stddevx > 0.001 {
                    self.velx += round(avgx*100)/100.00
                    self.sumx += round(self.velx*100)/100.00
                } else if avgx < 0.001 {
                    self.velx /= 2
                }
                
                if stddevy > 0.001 {
                    self.vely += round(avgy*100)/100.00
                    self.sumy += round(self.vely*100)/100.00
                }
                
                self.lastaccxs.removeAtIndex(0)
                self.lastaccys.removeAtIndex(0)
                
                //print(NSString(format:  "%.5f", b1) + "," + NSString(format:  "%.5f\n", avgx))
            }
            self.lastaccxs.append(usracceleration.x)
            self.lastaccys.append(usracceleration.y)
            //println(NSString(format: "rotation: %.2f", rotation.x))
        })
        /*
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
                    
                accx = NSString(format: "%.8f", accx - self.avgx).doubleValue
                accy = NSString(format: "%.8f", accx - self.avgy).doubleValue
            */
                if fabs(accx) > 0.01 {
                    self.velx += accx*0.1
                } else {
                    self.velx *= 0.9
                }
                if fabs(accy) > 0.01 {
                    self.vely += accy*0.1
                } else {
                    self.vely *= 0.9
                }
                /*
                if accx >= 0 {
                    println(NSString(format: "%.8f", accx))
                    self.accX.text = NSString(format: " %.8f", accx)
                } else {
                    println(NSString(format: "%.8f", accx))
                    self.accX.text = NSString(format: "%.8f", accx)
                }
                */
                var string = ""
                
                if self.velx >= 0 {
                    string += NSString(format: "velx:  %.2f", self.velx)
                    //self.accX.text = NSString(format: " %.2f", self.velx)
                } else {
                    string += NSString(format: "velx: %.2f", self.velx)
                    //self.accX.text = NSString(format: "%.2f", self.velx)
                }
                
                if self.vely >= 0 {
                    string += NSString(format: ", vely:  %.2f", self.vely)
                    //self.accX.text = NSString(format: " %.2f", self.vely)
                } else {
                    string += NSString(format: ", vely: %.2f", self.vely)
                    //self.accX.text = NSString(format: "%.2f", self.vely)
                }
                
                println(string)
                
                //var clickl = false
                //var clickr = false
                if self.central != nil {
                    //self.sendData()
                }
            }
        })
*/
    }
    override func viewWillDisappear(animated: Bool) {
        self.peripheral.stopAdvertising()
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        service = CBMutableService(type: CBUUID.UUIDWithString("0771752E-7B66-49F6-9053-6E3DF9F2343B"), primary: true)
        service.characteristics = [xchar, ychar]
        self.peripheral.addService(service)
    }
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        //sendData()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!,
        central: CBCentral!,
        didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
            println("\n\n\ncharacteristic subscribe\n\n\n")
            self.central = central
            self.peripheral.stopAdvertising()
            sendDataIndex = 0
    }
    /*
    func sendData() {
        var strvelx1 = NSString(format: "%0.4f", velx) as String
        var strvelx2: NSData = strvelx1.dataUsingEncoding(NSUTF8StringEncoding)!
        var strvelx: String = strvelx2.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!) as String

        var strvely1 = NSString(format: "%0.4f", vely) as String
        var strvely2: NSData = strvely1.dataUsingEncoding(NSUTF8StringEncoding)!
        var strvely: String = strvely2.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!) as String
        
        
        var didSendx = self.peripheral.updateValue(NSData(base64EncodedString: strvelx, options: nil), forCharacteristic: xchar, onSubscribedCentrals: [central])
        var didSendy = self.peripheral.updateValue(NSData(base64EncodedString: strvely, options: nil), forCharacteristic: ychar, onSubscribedCentrals: [central])
        
        // Did it send?
        if (didSendx && didSendy) {
            println("Sent: mouse data")
        } else {
            return
        }
    
        if (sendDataIndex >= dataToSend.length) {
            
            // No data left.  Do nothing
            return;
        }
        
        // There's data left, so send until the callback fails, or we're done.
        /*
        var didSend = true
        
        while (didSend) {
            
            // Make the next chunk
            
            // Work out how big it should be
            var amountToSend = dataToSend.length - sendDataIndex
            
            // Can't be longer than 20 bytes
            if (amountToSend > max_bytes) {
                amountToSend = max_bytes
            }
            
            // Copy out the data we want
            var chunk = NSData.dataWithBytes(dataToSend.bytes + sendDataIndex.length(amountToSend))
            
            // Send it
            didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            // If it didn't work, drop out and wait for the callback
            if (!didSend) {
                return;
            }
            
            NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
            NSLog(@"Sent: %@", stringFromData);
            
            // It did send, so update our index
            self.sendDataIndex += amountToSend;
            
            // Was it the last one?
            if (self.sendDataIndex >= self.dataToSend.length) {
                
                // It was - send an EOM
                
                // Set this so if the send fails, we'll send it next time
                sendingEOM = YES;
                
                // Send it
                BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
                
                if (eomSent) {
                    // It sent, we're all done
                    sendingEOM = NO;
                    
                    NSLog(@"Sent: EOM");
                }
                
                return;
            }
        }
*/
    }
    /*func outputAccelData(acceleration:CMAcceleration) {
        accX.text = "1,2,3"
        //NSString(format: "X: %.4f", acceleration.x)
        //accY.text = NSString(format: "Y: %.4f", acceleration.y)
        //accZ.text = NSString(format: "Z: %.4f", acceleration.z)
    }
*/*/
}