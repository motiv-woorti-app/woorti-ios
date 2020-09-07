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
import CoreMotion
import CoreLocation
import Crashlytics

class PowerManagementModule {
    
    public enum GPSPower: String {
        case ON, OFF, PowerSaving
    }
    public static let toggleSemaphore = DispatchSemaphore(value: 1)
    
    private static var powerState = GPSPower.OFF
    
    private static var timerRunning = true //set to true disables the timer to toggle the energy consumption
    private static var schedTimerToggle: Timer?
    private static var schedTimerVerifyer: Timer?
    private static let locationTimeInterval = 45 //seconds (45)
        private static let tripIdleTime = 60 //5*60 //seconds (cannot use location detection one)
    private static var tripStarted = false
    public static var canToggle = true
    
    public static var ctrl_fullTripTableView: FullTripTableViewController?
    
    //MARK: publicly available functions
    //receives a notification that the
    public static func fullTripEnds(){
        TurnGPSBatterySavingMode()
        DetectMotionModule.stopMotionManager()
        tripStarted=false
    }
    
    public static func getGPSPower() -> GPSPower {
        return powerState
    }
    
    //Receives a notification that the full trip has started
    public static func fullTripStarts(){
        tripStarted=true
        schedTimerVerifyer?.invalidate()
        schedTimerVerifyer = nil
        DetectMotionModule.startMotionManager()
        if powerState != GPSPower.ON {
            TurnGpsOn()
        }
    }
    
    //receives a new activity, decies if the gps should be turned on
    public static func processnewActivity(activity: CMMotionActivity){
        if powerState == GPSPower.PowerSaving {
            print("processnewActivity: \(activity.description)")
            if (!activity.stationary && activity.confidence.rawValue > 0) {
                NotificationEngine.getInstance().debugNotification(title: "gps on for activity", body: "confidence: \(activity.confidence.rawValue) a:\(activity.automotive) c:\(activity.cycling) r:\(activity.running) u:\(activity.unknown) w:\(activity.walking) s:\(activity.stationary)", notify: false)
                TurnGpsOn()
                schedTimerVerifyerfunc()
            }
        }
    }
    
    //Verify trip state every X (60) seconds.
     static func schedTimerVerifyerfunc() {
        if Thread.isMainThread {
            if schedTimerVerifyer == nil {
                schedTimerVerifyer = Timer.scheduledTimer(timeInterval: TimeInterval(60), target: PowerManagementModule.self, selector: #selector(PowerManagementModule.verifyTripState), userInfo: nil, repeats: false)
            }
        } else {
            DispatchQueue.main.async {
                schedTimerVerifyerfunc()
            }
        }
    }
    
    //When the app starts, turn GPS on and set a timer to verify trip state.
    public static func GPSOnAppStart() {
        TurnGpsOn()
        schedTimerVerifyerfunc()
    }
    
    //Function that manages how much time it takes to toggle back to highPower mode
    public static func TogglePowerConsumption() {
        if (!timerRunning && powerState == GPSPower.ON && canToggle) {
            toggleGPSPowerConsumption()
            timerRunning=true
            schedTimerToggle = Timer.scheduledTimer(timeInterval: TimeInterval(PowerManagementModule.locationTimeInterval), target: PowerManagementModule.self, selector: #selector(PowerManagementModule.toggleGPSPowerConsumption), userInfo: nil, repeats: false)
        }
    }
    
    //Enables higher battery consumption on gps
    public static func TurnGpsOn(){
        if PowerManagementModule.powerState != GPSPower.ON {
            print("GPS - TURN ON!")
            DetectLocationModule.startLM(bestAccuracy: true)
            PowerManagementModule.powerState=GPSPower.ON
            ctrl_fullTripTableView?.UpdateBtnColor()
            Crashlytics.sharedInstance().setObjectValue(PowerManagementModule.powerState.rawValue, forKey: "PowerMode")
        }
    }
    
    //Disables higher battery consumption on gps
    public static func TurnGPSBatterySavingMode(){
        if PowerManagementModule.powerState != GPSPower.PowerSaving {
             print("GPS - TURN BATTERY SAVE!")
            PowerManagementModule.schedTimerToggle?.invalidate()
            PowerManagementModule.schedTimerToggle = nil
            //DetectLocationModule.stopLM()
            DetectLocationModule.startLM(bestAccuracy: false)
            PowerManagementModule.powerState=GPSPower.PowerSaving
            ctrl_fullTripTableView?.UpdateBtnColor()
            Crashlytics.sharedInstance().setObjectValue(PowerManagementModule.powerState.rawValue, forKey: "PowerMode")
        }
    }
    
    public static func TurnGpsOff(){
        if PowerManagementModule.powerState != GPSPower.OFF {
             print("GPS - TURN OFF!")
            DetectLocationModule.stopLM()
            PowerManagementModule.powerState=GPSPower.OFF
            ctrl_fullTripTableView?.UpdateBtnColor()
            Crashlytics.sharedInstance().setObjectValue(PowerManagementModule.powerState.rawValue, forKey: "PowerMode")
        }
    }
    
    //MARK: Internal functions
    //function that verifies if FullTrip has started
    @objc static func verifyTripState(){
        schedTimerVerifyer?.invalidate()
        schedTimerVerifyer = nil
        if PowerManagementModule.powerState==GPSPower.ON {
            if !PowerManagementModule.tripStarted {
                print("Battery Save Mode")
                PowerManagementModule.TurnGPSBatterySavingMode()
            }
        }
    }
    
    //Function that mtoggles the GPS power consumption
    @objc static func toggleGPSPowerConsumption(){
        toggleSemaphore.wait()
        if canToggle{
            if powerState==GPSPower.ON {
                TurnGPSBatterySavingMode()
            }else {
                TurnGpsOn()
            }
        }
        PowerManagementModule.timerRunning=false
        toggleSemaphore.signal()
    }
    
    static func gpsOff() -> Bool {
        return powerState == GPSPower.OFF
    }
    
    static func startRunningTRansportDetection(){
        PowerManagementModule.GPSOnAppStart() //it has the timer to turn off if not in Trip in 5 min time
        PowerManagementModule.canToggle = true
        ProcessLocationData.stoppedTracking=false
    }
    
    static func stopRunningTRansportDetection(){
        if schedTimerToggle != nil {
            schedTimerToggle?.invalidate()
        }
        PowerManagementModule.TurnGpsOff()
        ProcessLocationData.stoppedTracking=true
        DetectMotionModule.stopMotionManager()
    }
}
