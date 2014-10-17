//
//  AppDelegate.swift
//  mouse
//
//  Created by Evan Phibbs on 8/28/14.
//  Copyright (c) 2014 Evan Phibbs. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CBPeripheralManagerDelegate {
    
    var window: UIWindow!
    var bluetooth: LXCBPeripheralServer!
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        bluetooth = LXCBPeripheralServer()
        return true
    }
    func advertise() {
        //peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [uuid]])
    }
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        println("updated state")
    }
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!,
        error: NSError!) {
            if (error == nil) {
                println("started advertising")
            } else {
                println("error")
            }
    }
    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
