//
//  RunTask.swift
//  DeunaSDK
//
//  Created by deuna on 15/1/25.
//
import Foundation

class DeunaTasks {
    static var useMainThread = false

    static func run(cb: @escaping () -> Void) {
        if useMainThread {
            DispatchQueue.main.async {
                DeunaLogs.info("running task in main thread")
                cb()
            }
        } else {
            cb()
        }
    }
}
