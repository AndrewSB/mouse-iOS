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
        //var service = CBService()
        self.peripheral = CBPeripheralManager(delegate: self, queue: nil)
        var mutableservice = CBMutableService(type: self.UUID, primary: true)
        //service.characteristics = [1,2,3]
        //var props = CBCharacteristicProperties()
        //var perms = CBAttributePermissions()
        //var characteristics = CBMutableCharacteristic(type: self.UUID, properties: props, value: nil, permissions: perms)
        //var service = CBService()
        //mutableservice.characteristics = [characteristics]
        //mutableservice.includedServices = [service]
        //println("services: ")
        //println(service.characteristics)
        //println(service.includedServices)
        self.peripheral.addService(mutableservice)
        self.peripheral.startAdvertising([1: "hey"])
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        println("updated state")
    }
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!,
        error: NSError!) {
            println("started advertising")
    }
}