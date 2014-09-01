//
//  CBDelegate.swift
//  mouse
//
//  Created by Evan Phibbs on 8/29/14.
//  Copyright (c) 2014 Evan Phibbs. All rights reserved.
//

import UIKit
import CoreBluetooth

class CBDelegate: NSObject, CBPeripheralManagerDelegate {
    var peripheral: CBPeripheralManager?
    var service: CBMutableService?
    var characteristic: CBMutableCharacteristic?
    var advertisedata: NSDictionary?
    
    //let service = CBMutableService(type: CBUUID.UUIDWithString("0011"), primary: true)
    //self.peripheral.addService(self.service)
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        println("updated state")
    }
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!,
        error: NSError!) {
            println("started advertising")
    }
}