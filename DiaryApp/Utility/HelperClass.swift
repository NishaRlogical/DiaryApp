//
//  HelperClass.swift
//  DiaryApp
//
//  Created by rlogical-dev-11 on 18/11/20.
//

import Foundation
import SystemConfiguration

//MARK:- time convert from date
 func timeConvertFromDate(date: Date) -> String {
    
    let calendar = Calendar.current
    let dateCompnents = Set<Calendar.Component>([.year, .month, .weekOfMonth, .day, .hour, .minute, .second])
    let components = calendar.dateComponents(dateCompnents, from: date, to: Date())
    
    if components.year! > 0 {
        if components.year! > 1 {
            return "\(components.year!) years ago"
        } else {
            return "\(components.year!) year ago"
        }
    } else if components.month! > 0 {
        if components.month! > 1 {
            return "\(components.month!) months ago"
        } else {
            return "\(components.month!) month ago"
        }
    } else if components.weekOfMonth! > 0 {
        if components.weekOfMonth! > 1 {
            return "\(components.weekOfMonth!) weeks ago"
        } else {
            return "\(components.weekOfMonth!) week ago"
        }
    } else if components.day! > 0 {
        if components.day! > 1 {
            return "\(components.day!) days ago"
        } else {
            return "\(components.day!) day ago"
        }
    } else {
        if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            return "\(components.hour!) hour ago"
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            return "\(components.minute!) minute ago"
        } else {
            return "moment ago"
        }
    }
}

//MARK:- Internet Reachability -------------

public class Reachability {
    static func isConnectedToNetwork() -> Bool {
        //return false
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}


 
