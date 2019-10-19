//
//  File.swift
//  spm-test
//
//  Created by Cory Knapp on 10/16/19.
//  Copyright © 2019 Cory Knapp. All rights reserved.
//

import Foundation

class Device: Codable {
    
    var deviceType: [String]?
    
    var presentationURL: String?
    var friendlyName: String?
    var manufacturer: String?
    var manufacturerURL: String?
    var modelDescription: String?
    var modelName: String?
    var modelNumber: String?
    var modelURL: String?
    var serialNumber: String?
    var UDN: String?
    
    var serviceList: [Service]?
    var deviceList: [Device]?
}
