//
//  MercadoPagoDevicesSDK.swift
//  MercadoPagoDevicesSDK
//
//  Created by Franco Cuevas on 3/4/20.
//

import Foundation
import CoreLocation

@objc(MercadoPagoDevicesSDK)
open class MercadoPagoDevicesSDK : NSObject, CLLocationManagerDelegate {

    private static var sharedMercadoPagoDevicesSDK: MercadoPagoDevicesSDK = {
        let mercadoPagoDevicesSDK = MercadoPagoDevicesSDK()
        return mercadoPagoDevicesSDK
    }()
    
    private var device: Device

    override private init() {
        device = Device()
    }

    @objc public class var shared: MercadoPagoDevicesSDK {
        return sharedMercadoPagoDevicesSDK
    }
    
    func getDevice() -> Device {
        device = Device()
        return device
    }
    
    public func getInfo() -> Device {
        return getDevice()
    }
    
    @objc public func getInfoAsJsonData() -> Data? {
        return (try? getDevice().toJSON()) ?? nil
    }
    
    @objc public func getInfoAsJsonString() -> String? {
        return (try? getDevice().toJSONString()) ?? nil
    }
    
    @objc public func getInfoAsDictionary() -> [String: Any]? {
        return (try? getDevice().toDictionary()) ?? nil
    }
}
