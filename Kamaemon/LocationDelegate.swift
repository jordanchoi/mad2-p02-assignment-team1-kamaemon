//
//  LocationDelegate.swift
//  Kamaemon
//
//  Created by mad2 on 22/1/22.
//

import CoreLocation
class LocationDelegate : NSObject, CLLocationManagerDelegate{
    var locationCallBack: ((CLLocation)->())? = nil
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        locationCallBack?(currentLocation)
    }
}
