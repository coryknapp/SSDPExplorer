//
//  ContentView.swift
//  SSDPExplorer
//
//  Created by Cory Knapp on 10/19/19.
//  Copyright © 2019 Cory Knapp. All rights reserved.
//

import SwiftUI
import AppKit

struct ContentView: View {
        
    @EnvironmentObject var serviceDiscovery : ServiceDiscovery
    @State var focusedHost: Host?
    @State var focusedServiceGroup: ServiceGroup?

    
    var body: some View {
        HStack(){
            // Hosts/services menu
            Group {
                List((NSApplication.shared.delegate as! AppDelegate).serviceDiscovery.hosts, id: \.host) { host in
                    HostRow(host: host, focusedHostBinding: self.$focusedHost)
                }.listStyle(SidebarListStyle())
            }
            Group {
                // host detail v
                if(( focusedHost ) != nil){
                    HostDetail(host: self.focusedHost!, focusedServiceGroupBinding: $focusedServiceGroup)
                }
            }
            Group {
                // service group detail v
                if(( focusedServiceGroup ) != nil){
                    ServiceGroupDetail(serviceGroup: focusedServiceGroup!)
                }
            }

        }
        //.frame(minWidth: 400, idealWidth: 400, minHeight: 300, idealHeight: 300, alignment: .leading)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(focusedHost: nil)
    }
}

struct HostRow: View {
    var host: Host

    @Binding var focusedHostBinding : Host?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(host.friendlyName)
            Text( "\(host.serviceGroups.count) services found" )
            Divider()
        }.onTapGesture {
            self.focusedHostBinding = self.host
        }    }
}

struct HostDetail: View {
    var host: Host

    @Binding var focusedServiceGroupBinding : ServiceGroup?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(host.host ?? "unknown").font(.largeTitle)
            Text( "\(host.serviceGroups.count) service groups found" )
            
            List(host.serviceGroups, id: \.uniqueServiceNameBase) { serviceGroup in
                VStack {
                    ServiceGroupRow(serviceGroup: serviceGroup, focusedServiceGroupBinding: self.$focusedServiceGroupBinding)
                    Divider()
                }
            }
            
        }
    }
}

struct ServiceGroupRow: View {
    var serviceGroup: ServiceGroup
    
    @Binding var focusedServiceGroupBinding : ServiceGroup?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(serviceGroup.friendlyName)
            Text("location: \(serviceGroup.locationURL?.absoluteString ?? "None provided")").onTapGesture {
                if self.serviceGroup.locationURL != nil {
                    NSWorkspace.shared.open(self.serviceGroup.locationURL!)
                }
            }
            Text("\tservice count: \(serviceGroup.services.count)")
        }.onTapGesture {
            self.focusedServiceGroupBinding = self.serviceGroup
        }
    }
}

struct ServiceGroupDetail: View {
    var serviceGroup: ServiceGroup
        
    var body: some View {
        ScrollView(){
            VStack(alignment: .leading) {
                Text("UniqueService: \(serviceGroup.uniqueServiceNameBase)")
                Text("\tservice count: \(serviceGroup.services.count)")
                List(serviceGroup.services, id: \.uniqueServiceNameAddition) { service in
                    Text( service.uniqueServiceNameAddition!.count == 0 ? "<empty>" : "\t\(service.uniqueServiceNameAddition!)" )
                }.frame(height: 200, alignment: .leading)

                Divider()

                Text("location: \(serviceGroup.locationURL?.absoluteString ?? "None provided")").onTapGesture {
                    if self.serviceGroup.locationURL != nil {
                        NSWorkspace.shared.open(self.serviceGroup.locationURL!)
                    }
                }

                Divider()
                
                Group(){
                    if self.serviceGroup.locationXMLData != nil {
                        if (self.serviceGroup.locationXMLData!.specVersion != nil) {
                            Text( "Major version: \((self.serviceGroup.locationXMLData?.specVersion!.major) ?? "Unknown" )")
                            Text( "Minor version: \((self.serviceGroup.locationXMLData?.specVersion!.minor) ?? "Unknown" )")
                        }
                        
                        if( self.serviceGroup.locationXMLData?.device != nil){
                            DeviceView(device: self.serviceGroup.locationXMLData!.device!)
                        }
                        
                    } else {
                        Text( "no location XML file found" )
                    }
                }
            }
        }
    }
}

struct DeviceView: View {
    var device: Device
        
    var body: some View {
        VStack(alignment: .leading) {
            Text("Device Type: \(device.deviceType?.joined(separator: ", ") ?? "None provided")")
            Text( "presentationURL: \((device.presentationURL) ?? "Unknown" )")

        }
    }
}
