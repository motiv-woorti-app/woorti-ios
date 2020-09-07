// (C) 2017-2020 - The Woorti app is a research (non-commercial) application that was
// developed in the context of the European research project MoTiV (motivproject.eu). The
// code was developed by partner INESC-ID with contributions in graphics design by partner
// TIS. The Woorti app development was one of the outcomes of a Work Package of the MoTiV
// project.
 
// The Woorti app was originally intended as a tool to support data collection regarding
// mobility patterns from city and country-wide campaigns and provide the data and user
// management to campaign managers.
 
// The Woorti app development followed an agile approach taking into account ongoing
// feedback of partners and testing users while continuing under development. This has
// been carried out as an iterative process deploying new app versions. Along the 
// timeline, various previously unforeseen requirements were identified, some requirements
// Were revised, there were requests for modifications, extensions, or new aspects in
// functionality or interaction as found useful or interesting to campaign managers and
// other project partners. Most stemmed naturally from the very usage and ongoing testing
// of the Woorti app. Hence, code and data structures were successively revised in a
// way not only to accommodate this but, also importantly, to maintain compatibility with
// the functionality, data and data structures of previous versions of the app, as new
// version roll-out was never done from scratch.

// The code developed for the Woorti app is made available as open source, namely to
// contribute to further research in the area of the MoTiV project, and the app also makes
// use of open source components as detailed in the Woorti app license. 
 
// This project has received funding from the European Union’s Horizon 2020 research and
// innovation programme under grant agreement No. 770145.
 
// This file is part of the Woorti app referred to as SOFTWARE.

import Foundation
import CoreLocation
import Crashlytics
import UIKit

class DetectLocationModule: NSObject, CLLocationManagerDelegate {
    
    //MARK:properties
    public var viewControllerSnapped: ViewController? //used to notify inferface of changes
    public static var locMan: CLLocationManager? = nil
    public static let processLocationData = ProcessLocationData()
    public static let locationDelegate = DetectLocationModule()
    public static let desiredAccuracy = Double(200) //meters
    public static let FirstLocationFixup = Double(30) //meters
    
    public static var lastLocation: CLLocation?
    public static var lastLocationAnyAccuracy : CLLocation?
    
    public static var lastLocationIsUnknown = false //test location unknown
    
    public static var state = states.visiting
    
    enum states {
        case visiting
        case bestAccuracy
        case lowAccuracy
    }
    
    //MARK: Region Properties
    public static let regionMonitoring=false //set to true allows for region monitoring and gps usage pausing
    public static var lastRegion: CLCircularRegion?
    public static let regionIdentifier = "LastStoppedRegion"
    public static let fenceRadious = 1
    
    //MARK:functions
    //used to start detecting location events
    public static func startLM(bestAccuracy: Bool){
        if Thread.isMainThread {
            if(locMan == nil && CLLocationManager.locationServicesEnabled()){
                
                    locMan = CLLocationManager()
                    locMan!.delegate = locationDelegate
                    
                    locMan!.distanceFilter = 1 //5m
                    locMan!.requestAlwaysAuthorization()
                    locMan!.disallowDeferredLocationUpdates()
                    locMan!.allowsBackgroundLocationUpdates=true
                    
                    if DetectLocationModule.regionMonitoring {
                        locMan!.pausesLocationUpdatesAutomatically=true
                    } else {
                        locMan!.pausesLocationUpdatesAutomatically=false
                    }
                
                    if bestAccuracy {
                        locMan!.desiredAccuracy=kCLLocationAccuracyBest
                        state = states.bestAccuracy
                    } else {
                        locMan!.desiredAccuracy=kCLLocationAccuracyThreeKilometers
                        state = states.lowAccuracy
                    }
                    locMan!.startUpdatingLocation()
            } else if(locMan != nil && CLLocationManager.locationServicesEnabled()) {
                if bestAccuracy {
                    locMan!.desiredAccuracy=kCLLocationAccuracyBest
                } else {
                    locMan!.desiredAccuracy=kCLLocationAccuracyThreeKilometers
                }
            }
            
            if !UIDevice.current.isBatteryMonitoringEnabled {
                UIDevice.current.isBatteryMonitoringEnabled = true
            }
            NotificationEngine.getInstance().debugNotification(title: "GPS Power", body: "GPS: \(bestAccuracy) powerLevel: \(UIDevice.current.batteryLevel)",notify: false)
        } else {
            DispatchQueue.main.sync{
                startLM(bestAccuracy: bestAccuracy)
            }
        }
    }
    
    public static func requestAuthorization() {
        if Thread.isMainThread {
            if(CLLocationManager.locationServicesEnabled()){
                CLLocationManager().requestAlwaysAuthorization()
            }
        } else {
            DispatchQueue.main.sync{
                requestAuthorization()
            }
        }
    }
    
    //used to stop location events
    public static func stopLM(){
        if Thread.isMainThread {
            locMan?.stopUpdatingLocation()
            locMan = nil
        } else {
            DispatchQueue.main.sync{
                stopLM()
            }
        }
    }
    
    //handler for location events
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) -> Void {
        
        for location in locations {
            
            if DetectLocationModule.lastLocation == nil {
                DetectLocationModule.lastLocationAnyAccuracy = location
                if location.horizontalAccuracy.isLess(than: DetectLocationModule.FirstLocationFixup) {
                    DetectLocationModule.lastLocationIsUnknown = false
                    DetectLocationModule.processLocationData.addLocation(newLocation: location)
                    PowerManagementModule.TogglePowerConsumption()
                    DetectLocationModule.lastLocation = location
                }
            } else if canAddLocation(location: location) {
                DetectLocationModule.lastLocationIsUnknown = false
                DetectLocationModule.processLocationData.addLocation(newLocation: location)
                PowerManagementModule.TogglePowerConsumption()
                DetectLocationModule.lastLocation = location
            } else if !(location.horizontalAccuracy.isLess(than: DetectLocationModule.desiredAccuracy)) {
                DetectLocationModule.processLocationData.CloseEntireTrip(newLocation: location)
                DetectLocationModule.lastLocationIsUnknown = true
            }
        }
    }
    
    func canAddLocation(location: CLLocation) -> Bool {
        return  (
                location.horizontalAccuracy.isLess(than: DetectLocationModule.desiredAccuracy) &&
                (DetectLocationModule.lastLocation?.distance(from: location))! > Double(0) &&
                location.timestamp.timeIntervalSince((DetectLocationModule.lastLocation?.timestamp) ?? location.timestamp) > Double(15)
                )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        
        if let error = error as? CLError {
            NotificationEngine.getInstance().debugNotification(title: "LocationDidFail: ", body: "code: \(error.code.rawValue) error: \(error.localizedDescription)", notify: false)
            switch error.code {
            case .denied:
                // Location updates are not authorized.
                manager.stopUpdatingLocation()
                Crashlytics.sharedInstance().recordCustomExceptionName("locationManager didfail code: \(error.code.rawValue)", reason: "error: \(error.localizedDescription)", frameArray: [CLSStackFrame]())
            case .locationUnknown:
                Crashlytics.sharedInstance().recordCustomExceptionName("locationManager didfail code: \(error.code.rawValue)", reason: "error: \(error.localizedDescription)", frameArray: [CLSStackFrame]())
                DetectLocationModule.lastLocationIsUnknown = true
            default:
                break
            }
        } else {
            Crashlytics.sharedInstance().recordCustomExceptionName("locationManager didfail generic", reason: "error: \(error.localizedDescription)", frameArray: [CLSStackFrame]())
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        //fail Deferred
    }
    
    // handle location paused updates
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        if DetectLocationModule.lastRegion != nil {
            DetectLocationModule.locMan!.stopMonitoring(for: DetectLocationModule.lastRegion!)
        }
        
        let stoppedCoordinate = DetectLocationModule.processLocationData.locationStoped?.coordinate
        let center = CLLocationCoordinate2D(latitude: (stoppedCoordinate?.latitude)!, longitude: (stoppedCoordinate?.longitude)!)
        
        
        DetectLocationModule.lastRegion = CLCircularRegion(center: center, radius: CLLocationDistance(DetectLocationModule.fenceRadious), identifier: DetectLocationModule.regionIdentifier)
        
        DetectLocationModule.lastRegion?.notifyOnEntry = false
        DetectLocationModule.lastRegion?.notifyOnExit = true
        
        DetectLocationModule.locMan!.startMonitoring(for: DetectLocationModule.lastRegion!)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
        if DetectLocationModule.lastRegion != nil {
            DetectLocationModule.locMan!.stopMonitoring(for: DetectLocationModule.lastRegion!)
        }
        DetectLocationModule.lastRegion = nil
        
        DetectLocationModule.startLM(bestAccuracy: true)
    }
    
    public static func getCurrentLocation() -> CLLocation? {
        if locMan != nil {
            return locMan?.location
        }
        
        return nil
    }
}
