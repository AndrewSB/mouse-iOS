#import <CoreBluetooth/CoreBluetooth.h>

#import "BTLEPeripheralViewController.h"
@import UIKit;

#ifndef LXCBLog
# define LXCBLog NSLog
#endif


@interface LXCBPeripheralServer () <NSObject, CBPeripheralManagerDelegate>

@property(nonatomic, strong) CBPeripheralManager *peripheral;
@property(nonatomic, strong) CBMutableCharacteristic *protocolmode_characteristic;
@property(nonatomic, strong) CBMutableCharacteristic *reportmap_characteristic;
//@property(nonatomic, strong) CBMutableCharacteristic *bootkeyboardinputreport_characteristic; //keyboards
//@property(nonatomic, strong) CBMutableCharacteristic *bootkeyboardoutputreport_characteristic; //keyboards
@property(nonatomic, strong) CBMutableCharacteristic *bootmouseinputreport_characteristic; //mice
@property(nonatomic, strong) CBMutableCharacteristic *hidinfo_characteristic;
@property(nonatomic, strong) CBMutableCharacteristic *hidcontrolpoint_characteristic;
@property(nonatomic, assign) BOOL serviceRequiresRegistration;
@property(nonatomic, strong) CBMutableService *service;
@property(nonatomic, strong) NSData *pendingData;

@end

@implementation LXCBPeripheralServer

+ (BOOL)isBluetoothSupported {
    // Only for iOS 6.0
    if (NSClassFromString(@"CBPeripheralManager") == nil) {
        return NO;
    }
    
    // TODO: Make a check to see if the CBPeripheralManager is in unsupported state.
    return YES;
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<LXCBPeripheralServerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.peripheral =
        [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        self.delegate = delegate;
        self.serviceUUID = [CBUUID UUIDWithString: @"1812"];
        self.characteristicUUID = [CBUUID UUIDWithString: @"1812"];
        self.serviceName = [[[UIDevice currentDevice] name] stringByAppendingString:@" - Mercury Mouse"];
    }
    return self;
}

#pragma mark -

- (void)enableService {
    // If the service is already registered, we need to re-register it again.
    if (self.service) {
        [self.peripheral removeService:self.service];
    }
    
    // Create a BTLE Peripheral Service and set it to be the primary. If it
    // is not set to the primary, it will not be found when the app is in the
    // background.
    self.service = [[CBMutableService alloc]
                    initWithType:self.serviceUUID
                    primary:YES];
    
    // Set up the characteristic in the service. This characteristic is only
    // readable through subscription (CBCharacteristicsPropertyNotify) and has
    // no default value set.
    //
    // There is no need to set the permission on characteristic.
    
    
    //characteristics
    
    self.protocolmode_characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType: [CBUUID UUIDWithString:@"2A4E"]
     properties: CBCharacteristicPropertyRead | CBCharacteristicPropertyWriteWithoutResponse
     value:0
     permissions:0];
    
    self.reportmap_characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType:[CBUUID UUIDWithString:@"2A4B"]
     properties: CBCharacteristicPropertyRead
     value:nil
     permissions:0];
    
    self.bootmouseinputreport_characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType:[CBUUID UUIDWithString:@"2A33"]
     properties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead
     value:nil
     permissions: 11];
    
    self.hidinfo_characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType:[CBUUID UUIDWithString:@"2A4A"]
     properties:CBCharacteristicPropertyRead
     value:nil
     permissions:0];
    
    self.hidcontrolpoint_characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType:[CBUUID UUIDWithString:@"2A4C"]
     properties:CBCharacteristicPropertyWriteWithoutResponse
     value:0
     permissions:0];
    
    /*
    self.bootkeyboardinputreport_characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType:self.characteristicUUID
     properties:CBCharacteristicPropertyNotify
     value:nil
     permissions:0];
    
    self.bootkeyboardoutputreport_characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType:self.characteristicUUID
     properties:CBCharacteristicPropertyNotify
     value:nil
     permissions:0];
    */
    
    // Assign the characteristic.
    self.service.characteristics = [NSArray arrayWithObjects: self.protocolmode_characteristic, self.reportmap_characteristic, self.bootmouseinputreport_characteristic, self.hidinfo_characteristic, self.hidcontrolpoint_characteristic, nil];
    
    // Add the service to the peripheral manager.
    [self.peripheral addService:self.service];
}

- (void)disableService {
    [self.peripheral removeService:self.service];
    self.service = nil;
    [self stopAdvertising];
    NSLog(@"disabled service, stopped advertising");
}


// Called when the BTLE advertisments should start. We don't take down
// the advertisments unless the user switches us off.
- (void)startAdvertising {
    if (self.peripheral.isAdvertising) {
        [self.peripheral stopAdvertising];
        NSLog(@"stopped advertising");
    }
    NSDictionary *advertisment = @{CBAdvertisementDataServiceUUIDsKey : @[self.serviceUUID], CBAdvertisementDataLocalNameKey: self.serviceName, CBAdvertisementDataIsConnectable: [[NSNumber alloc] initWithBool:1]};
    [self.peripheral startAdvertising:advertisment];
}

- (void)stopAdvertising {
    [self.peripheral stopAdvertising];
}

- (BOOL)isAdvertising {
    return [self.peripheral isAdvertising];
}


#pragma mark -

- (void)sendToSubscribers:(NSData *)data {
    if (self.peripheral.state != CBPeripheralManagerStatePoweredOn) {
        LXCBLog(@"sendToSubscribers: peripheral not ready for sending state: %d", self.peripheral.state);
        return;
    }
    
    BOOL success = [self.peripheral updateValue:data
                              forCharacteristic:self.protocolmode_characteristic
                           onSubscribedCentrals:nil];
    if (!success) {
        LXCBLog(@"Failed to send data, buffering data for retry once ready.");
        self.pendingData = data;
        return;
    }
}

- (void)applicationDidEnterBackground {
    // Deliberately continue advertising so that it still remains discoverable.
}

- (void)applicationWillEnterForeground {
    NSLog(@"applicationWillEnterForeground.");
    // I once thought that it would be good to re-advertise and re-enable
    // the services when coming in the foreground, but it does more harm than
    // good. If we do that, then if there was a Central subscribing to a
    // characteristic, that would get reset.
    //
    // So here we deliberately avoid re-enabling or re-advertising the service.
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    // As soon as the service is added, we should start advertising.
    NSLog(@"did add service");
    [self startAdvertising];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"peripheralStateChange: Powered On");
            // As soon as the peripheral/bluetooth is turned on, start initializing
            // the service.
            [self enableService];
            break;
        case CBPeripheralManagerStatePoweredOff: {
            NSLog(@"peripheralStateChange: Powered Off");
            [self disableService];
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateResetting: {
            NSLog(@"peripheralStateChange: Resetting");
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnauthorized: {
            NSLog(@"peripheralStateChange: Deauthorized");
            [self disableService];
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnsupported: {
            NSLog(@"peripheralStateChange: Unsupported");
            self.serviceRequiresRegistration = YES;
            // TODO: Give user feedback that Bluetooth is not supported.
            break;
        }
        case CBPeripheralManagerStateUnknown:
            NSLog(@"peripheralStateChange: Unknown");
            break;
        default:
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
    if (error) {
        NSLog(@"didStartAdvertising: Error: %@", error);
        return;
    }
    NSLog(@"didStartAdvertising");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"didSubscribe: %@", characteristic.UUID);
    NSLog(@"didSubscribe: - Central: %@", central.UUID);
    [self.delegate peripheralServer:self centralDidSubscribe:central];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"didUnsubscribe: %@", central.UUID);
    [self.delegate peripheralServer:self centralDidUnsubscribe:central];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"isReadyToUpdateSubscribers");
    if (self.pendingData) {
        NSData *data = [self.pendingData copy];
        self.pendingData = nil;
        [self sendToSubscribers:data];
    }
}

@end