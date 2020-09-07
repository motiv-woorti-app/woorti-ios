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
import UIKit
import Firebase
import GoogleSignIn

class MainMenuView: UIViewController {
    @IBOutlet weak var StartStopRunningTranportDetectionButton: UIButton!
    @IBOutlet weak var VersionAndBuildLabel: UILabel!
    var isTRansportModeRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main Menu"
        self.VersionAndBuildLabel.text = getVersionAndBuild()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isTRansportModeRunning = !PowerManagementModule.gpsOff()
        toggleTransportRunningUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UiAlerts.getInstance().newView(view: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    @IBAction func StartStopRunningTRansportDetection(_ sender: UIButton) {
        if isTRansportModeRunning {
            DetectLocationModule.processLocationData.forceStopTripOnCurrentLocation()
            PowerManagementModule.stopRunningTRansportDetection()
            DetectLocationModule.processLocationData.cleanLocationList()
            if let lastTrip = UserInfo.getFullTrips().last {
                let confirmView = storyboard?.instantiateViewController(withIdentifier: "ConfirmScreen") as! ConfrimScreenController
                confirmView.ft = lastTrip
                navigationController?.pushViewController(confirmView, animated: true)
            } else {
                
                UiAlerts.getInstance().showAlertMsg(title: "Cannot move to Confirmation screen.", message: "you have no Trips in your Trip list.")
            }
        } else {
            //UserInfo.closeOpenedTrips()
            PowerManagementModule.startRunningTRansportDetection()
            DetectLocationModule.processLocationData.startFullTrip() //force the start of a new Trip
        }
        isTRansportModeRunning = !PowerManagementModule.gpsOff()
        toggleTransportRunningUI()
    }
    
    func toggleTransportRunningUI(){
        if isTRansportModeRunning {
            StartStopRunningTranportDetectionButton.setTitle("Stop Trip",for: .normal)
            StartStopRunningTranportDetectionButton.setTitleColor(UIColor.red, for: .normal)
//            StartStopRunningTranportDetectionButton.titleLabel?.text="Stop Running Transport Detection"
//            StartStopRunningTranportDetectionButton.titleLabel?.textColor=UIColor.red
        } else {
            StartStopRunningTranportDetectionButton.setTitle("Start Trip",for: .normal)
            StartStopRunningTranportDetectionButton.setTitleColor(UIColor.green, for: .normal)
//            StartStopRunningTranportDetectionButton.titleLabel?.text="Start Running Transport Detection"
//            StartStopRunningTranportDetectionButton.titleLabel?.textColor=UIColor.green
        }
    }
    
    @IBAction func FinishAppAndLoggoutClick(_ sender: UIButton) {
//        let firebaseAuth = Auth.auth()
//        do {
//            GIDSignIn.sharedInstance().signOut()
//            try firebaseAuth.signOut()
//            navigationController?.popToRootViewController(animated: true)
//
//        } catch let signOutError as NSError {
//            //print ("Error signing out: %@", signOutError)
//        }
        MotivUser.getInstance()?.signOut(view: self)
    }
    
    @IBAction func sendConfirmedTripsToServerClick(_ sender: Any) {
        UserInfo.DumpToServerConfirmedTrips()
        UiAlerts.getInstance().showEndDumpMessage()
    }

    
    //Version and Build
    private func getVersionAndBuild() -> String {
        var returnString = ""
        if let dictionary = Bundle.main.infoDictionary {
            if let version = dictionary["CFBundleShortVersionString"] as? String {
                returnString.append("Version: \(version) ")
            }
            if let build = dictionary["CFBundleVersion"] as? String {
                returnString.append("Build: \(build) ")
            }
        
        }
        return returnString
    }
    
    //Delete all sent Trips
    @IBAction func DeleteAllSentTripsClick(_ sender: Any) {
        DispatchQueue.global(qos: .userInteractive).async {
            if(UiAlerts.getInstance().showDeleteAllSentTripsAlert()) {
                for trip in UserInfo.getFullTrips(){
                    if trip.sentToServer {
                        trip.delete()
                    }
                }
                UiAlerts.getInstance().showEndDeleteAllSentTrips()
            }
        }
    }
}
