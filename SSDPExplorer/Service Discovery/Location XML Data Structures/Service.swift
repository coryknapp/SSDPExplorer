//
//  Service.swift
//  spm-test
//
//  Created by Cory Knapp on 10/16/19.
//  Copyright © 2019 Cory Knapp. All rights reserved.
//

import Foundation

class Service: Codable {
    var serviceType: String?
    var serviceId: String?
    var controlURL: String?
    var eventSubURL: String?
    var SCPDURL: String?
}
