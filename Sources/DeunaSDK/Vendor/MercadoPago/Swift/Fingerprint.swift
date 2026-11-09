//
//  Fingerprint.swift
//  Devices
//
//  Created by Franco Cuevas on 2/26/20.
//

import Foundation
import UIKit
import AdSupport

open class Fingerprint: NSObject, Codable {
    open var os: String?
    open var vendorIds: [DeviceId]?
    open var model: String?
    open var systemVersion: String?
    open var resolution: String?
    open var vendorSpecificAttributes: VendorSpecificAttributes?
    open var diskSpace : UInt?
    open var freeDiskSpace: UInt?
    open var ram: UInt?

    public override init () {
        super.init()
        deviceFingerprint()
    }

    public enum FingerprintKeys: String, CodingKey {
        case vendorSpecificAttributes = "vendor_specific_attributes"
        case vendorIds = "vendor_ids"
        case systemVersion = "system_version"
        case diskSpace = "disk_space"
        case freeDiskSpace = "free_disk_space"
        case model
        case resolution
        case os
        case ram
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FingerprintKeys.self)
        try container.encodeIfPresent(self.vendorSpecificAttributes, forKey: .vendorSpecificAttributes)
        try container.encodeIfPresent(self.vendorIds, forKey: .vendorIds)
        try container.encodeIfPresent(self.systemVersion, forKey: .systemVersion)
        try container.encodeIfPresent(self.model, forKey: .model)
        try container.encodeIfPresent(self.resolution, forKey: .resolution)
        try container.encodeIfPresent(self.os, forKey: .os)
        try container.encodeIfPresent(self.ram, forKey: .ram)
        try container.encodeIfPresent(self.diskSpace, forKey: .diskSpace)
        try container.encodeIfPresent(self.freeDiskSpace, forKey: .freeDiskSpace)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> Fingerprint {
        return try JSONDecoder().decode(Fingerprint.self, from: data)
    }

    open func deviceFingerprint() {
        let device: UIDevice = UIDevice.current

        self.os = "iOS"
        self.vendorIds = getDevicesIds()

        let model : String = (try? Sysctl.string(forName: "hw.model")) ?? ""
        if !Utils.isNullOrEmpty(model) {
            self.model = model
        }

        if !Utils.isNullOrEmpty(device.systemVersion) {
            self.systemVersion = device.systemVersion
        }
        
        self.diskSpace = getTotalDiskSpace()
        self.freeDiskSpace = getFreeDiskSpace()
        self.ram = self.getSysInfo(typeSpecifier: HW_PHYSMEM)
        self.resolution = getDeviceResolution()
        self.vendorSpecificAttributes = VendorSpecificAttributes()
    }
    
    func getSysInfo(typeSpecifier: Int32) -> UInt {
        return try! UInt(Sysctl.value(ofType: UInt32.self, forKeys: [CTL_HW, typeSpecifier]))
    }
    
    func getTotalDiskSpace() -> UInt {
        let fattributes : Dictionary<FileAttributeKey, Any> = try! FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return fattributes[FileAttributeKey.systemSize] as! UInt
    }
    
    func getFreeDiskSpace() -> UInt {
        let fattributes : Dictionary<FileAttributeKey, Any> = try! FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return fattributes[FileAttributeKey.systemFreeSize] as! UInt
    }

    func getDevicesIds() -> [DeviceId]? {
        let vendorId: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let uuid: String = {
            if let cls = NSClassFromString("BPXLUUIDHandler") as? NSObject.Type,
               cls.responds(to: NSSelectorFromString("UUID")),
               let res = cls.perform(NSSelectorFromString("UUID"))?.takeUnretainedValue() as? String {
                return res
            }
            return vendorId
        }()
        let idfa: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString

        let vendorIdObj = DeviceId(name: "vendor_id", value: vendorId)
        let uuidObj = DeviceId(name: "uuid", value: uuid)
        let idfaObj = DeviceId(name: "idfa", value: idfa)

        return [vendorIdObj, uuidObj, idfaObj]
    }

    func getDeviceResolution() -> String {
        let screenSize: CGRect = UIScreen.main.bounds
        let width = NSString(format: "%.0f", screenSize.width)
        let height = NSString(format: "%.0f", screenSize.height)
        return "\(width)x\(height)"
    }
}
