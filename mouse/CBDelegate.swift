//
//  CBDelegate.swift
//  mouse
//
//  Created by Evan Phibbs on 8/29/14.
//  Copyright (c) 2014 Evan Phibbs. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothBroadcaster: NSObject, CBPeripheralManagerDelegate {
    
    let peripheral: CBPeripheralManager!
    var characteristic: CBMutableCharacteristic!
    var advertisedata: NSDictionary!
    let UUID: CBUUID!
    
    init(UUID: CBUUID) {
        super.init()
        self.UUID = UUID
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
        var service = CBMutableService(type: self.UUID, primary: true)
        peripheral.addService(service)
        peripheral.startAdvertising(["12": "12"])
        println("advertise")
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        println("updated state")
    }
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!,
        error: NSError!) {
            println("started advertising")
    }
}