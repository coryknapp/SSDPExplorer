//
//  ServiceDiscovery.swift
//  spm-test
//
//  Created by Cory Knapp on 10/9/19.
//  Copyright © 2019 Cory Knapp. All rights reserved.
//

import Foundation
import SSDPClient
import XMLCoder

class Host: ObservableObject {
    
    var friendlyName: String{
        get{
            // find the first group that has parsed xml data
            var sg = serviceGroups.first(where: { (sg) -> Bool in
                return sg.locationXMLData?.device?.modelDescription != nil;
            });
            return server ?? sg?.locationXMLData?.device?.modelDescription ?? host!;
        }
    }
    
    var host : String? //XXX make none optional
    
    var server : String? // Some hosts will return a human readable description, which we'd prefer to display if available
    
    var serviceGroups = [ServiceGroup]()
    
    func insertService(_ service: MyService){
        for group in serviceGroups {
            if group.uniqueServiceNameBase == service.uniqueServiceNameBase && group.location == service.location{
                group.services.append(service)
                return
            }
        }
        serviceGroups.append( ServiceGroup(uniqueServiceNameBase: service.uniqueServiceNameBase, location: service.location, service: service))
    }
}

/// Services are grouped into service groups based on simillar `uniqueServiceName` values and shared `location` values
class ServiceGroup : NSObject, XMLParserDelegate{
    
    var friendlyName: String{
        get{
            // do any of my devices provide a friendly name?
            return self.locationXMLData?.device?.modelDescription ?? self.locationXMLData?.device?.friendlyName ?? uniqueServiceNameBase;
        }
    }
    
    /// the leading UUID like string of the uniqueServiceName of the grouped `MyService` objects
    var uniqueServiceNameBase: String;
    
    /// shared `location` value of grouped `MyService` objects
    var location: String?; // XXX change to URL type?
    
    var services = [MyService]()

    var locationXMLData: LocationXMLData?
    
    init(uniqueServiceNameBase: String, location: String?, service: MyService){
        self.uniqueServiceNameBase = uniqueServiceNameBase;
        self.location = location
        
        super.init()
        
        if self.location != nil {
            processLocationXML()
        }
        
        services.append(service)
    }
    
    public var locationURL: URL? {
        get {
            return self.location == nil ? nil : URL(string: self.location!)
        }
    }
    
    func processLocationXML() {
        let data = try! Data(contentsOf: locationURL!)
        locationXMLData = try! XMLDecoder().decode(LocationXMLData.self, from: data)
    }

}

// XXX awful name.  Plz fix
class MyService : Identifiable{
    
    var _service: SSDPService;
    
    var uniqueServiceNameBase: String
    var uniqueServiceNameAddition: String?

    init(service: SSDPService) {
        _service = service
        
        let split = _service.uniqueServiceName!.split(separator: ":")
        uniqueServiceNameBase = String(split.first! + ":" + split[1])
        uniqueServiceNameAddition = String(uniqueServiceName!.dropFirst(uniqueServiceNameBase.count))
    }
    
    // MARK: - Identifiable protocal
    var ID: String? {
        return uniqueServiceName
    }
    
    
    // MARK: - SSDPService forwards
    
    /// The SSDPService class is marked `public` rather then `closed` so I replicate it's fields and forward
    /// them to the SSDP member so we can fake a sublass,
    
    public var host: String {
        get{
            return _service.host
        }
    }

    /// The value of `LOCATION` header
    public var location: String? {
        get{
                return _service.location
        }
    }

    /// The value of `SERVER` header
    public var server: String? {
        get{
            return _service.server
        }
    }

    /// The value of `ST` header
    public var searchTarget: String? {
        get{
            return _service.searchTarget
        }
    }

    /// The value of `USN` header
    public var uniqueServiceName: String? {
        get{
            return _service.uniqueServiceName
        }
    }
    
    // MARK: - Additions
    
    /// Returns a tuple where the first element is the base of the `uniqueServiceName` and the second is the `uniqueServiceName` with the base removed
    private func baseName(_ uniqueServiceName: String) -> (String, String?){
        let split = uniqueServiceName.split(separator: ":")
        let base = String(split.first! + ":" + split[1])
        return (base, String(uniqueServiceName.dropFirst(base.count)))
    }
}

class ServiceDiscovery : ObservableObject{
    let client = SSDPDiscovery()

    private var hostsDictionary = [String: Host]()
    
    @Published var status: Bool = false
    
    var hosts : [Host]{
        get{
            return [Host](hostsDictionary.values);
        }
    }
    
    init() {
        self.client.delegate = self
        self.client.discoverService()
    }
}

extension ServiceDiscovery: SSDPDiscoveryDelegate {
    func ssdpDiscovery(_: SSDPDiscovery, didDiscoverService service: SSDPService) {
        
        let service = MyService(service: service);
        let hostField = service.host;

        if let host = hostsDictionary[hostField] {
            host.insertService(service)
        } else {
            let host = Host()
            host.host = hostField
            host.server = service.server;
            host.insertService(service)
            hostsDictionary[hostField] = host
        }
    }
    
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error) {
        //print("error", error);
        //print()
        
        //for item in servers {
        //    print(item.key);
        //    print(item.value.services.count)
        //    if(item.key != item.value.serverName){
        //        assert(false)
        //    }
        //}
    }
}
