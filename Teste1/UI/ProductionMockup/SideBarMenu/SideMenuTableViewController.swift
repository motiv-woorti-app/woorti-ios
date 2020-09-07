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

import UIKit
import EzPopup

class SideMenuTableViewController: UITableViewController {
    
//    @IBOutlet weak var startTripLabel: UILabel!
//    @IBOutlet weak var startTripImage: UIImageView!
    static var TripStateChanged = "SideMenuTableViewControllerTripStateChanged"
    var cells = [
//                ("Drawer_Title_Report_Issue","Profile_Settings"),
                ("Drawer_Title_Home","Home"),
//                ("Drawer_Title_Route_Planner","Route_Planner"),
                ("Drawer_Title_My_Trips","My_Trips"),
                ("Dashboard","Dashboard"),
                ("Drawer_Title_Mobility_Coach","Mobility_Coach"),
//                ("Drawer_Title_Finish_Log_Out","Profile_Settings"),
                ("Drawer_Title_Settings","Profile_Settings")
//                ("Drawer_Title_Home","Home"),
//                ("Drawer_Title_Dashboard","Dashboard")
    ]
    
    @IBOutlet var header: UIView!
    @IBOutlet var footer: UIView!
    
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var version: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(toggleTransportRunningUI), name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
//        toggleTransportRunningUI()
//        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
//        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        let v = "2.0.11"
//        MotivFont.motivRegularFontFor(text: "version: \(v) (\(build))", label: self.version, size: 11)
        MotivFont.motivRegularFontFor(text: "version: " + v , label: self.version, size: 11)
        self.tableView.register(UINib(nibName: "SideMenuItemTableViewCell", bundle: nil), forCellReuseIdentifier: "SideMenuItemTableViewCell")
        
        let versionTap = UITapGestureRecognizer(target: self, action: #selector(tapVersion))
        self.version.addGestureRecognizer(versionTap)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        MotivFont.motivRegularFontFor(key: "Menu", comment: "", label: self.menuLabel, size: 10)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(105)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(159)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch indexPath.row {
//        case 0:
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.GoToReporting.rawValue), object: nil)
////            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.SendLogEmail.rawValue), object: nil)
//
//        case 1:
//            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowDefaultPage.rawValue), object: nil)
//        case 2:
////            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowRoutePlanner.rawValue), object: nil)
////        case 3:
//            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowMyTrips.rawValue), object: nil)
//        case 3: //temp
////        case 4:
////            //Dashboard
////            break
////        case 5:
//            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowDashboard.rawValue), object: nil)
////        case 6:
////        case 4: //temp
//////            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.ShowProfileAndSettings.rawValue), object: nil)
////            MotivUser.getInstance()?.signOut(view: self)
//        case 4:
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.ShowMobilityCoach.rawValue), object: nil)
//////        case 7:
//////            StartStopRunningTRansportDetection()
//        case 5:
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.ShowProfileAndSettings.rawValue), object: nil)
//        default:
//            break;
//        }
        switch indexPath.row {
        case 0:
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowDefaultPage.rawValue), object: nil)
        case 1:
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowMyTrips.rawValue), object: nil)
        case 2:
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowDashboard.rawValue), object: nil)
        case 3:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.ShowMobilityCoach.rawValue), object: nil)
        case 4:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.ShowProfileAndSettings.rawValue), object: nil)
        default:
            break;
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuItemTableViewCell", for: indexPath) as! SideMenuItemTableViewCell
        
        let ind = cells[indexPath.row]
        cell.loadCell(key: ind.0, image: ind.1)
        
        return cell
    }
    
    func StartStopRunningTRansportDetection() {
        DispatchQueue.global(qos: .userInitiated).async {
            if DetectLocationModule.processLocationData.state != ProcessLocationData.LocationStates.stoped {
                DetectLocationModule.processLocationData.forceStopTripOnCurrentLocation()
//                PowerManagementModule.stopRunningTRansportDetection()
//                DetectLocationModule.processLocationData.cleanLocationList()
////                if let lastTrip = UserInfo.getFullTrips().last {
////                    let confirmView = storyboard?.instantiateViewController(withIdentifier: "ConfirmScreen") as! ConfrimScreenController
////                    confirmView.ft = lastTrip
////                    navigationController?.pushViewController(confirmView, animated: true)
////                } else {
////
////                    UiAlerts.getInstance().showAlertMsg(title: "Cannot move to Confirmation screen.", message: "you have no Trips in your Trip list.")
////                }
            } else {
                UserInfo.closeOpenedTrips()
                PowerManagementModule.startRunningTRansportDetection()
                DetectLocationModule.processLocationData.startFullTrip() //force the start of a new Trip
            }
//            self.toggleTransportRunningUI()
        }
    }
    
    @objc func tapVersion() {
        let popupVC = UIStoryboard(name: "MoTiVProduction", bundle: nil).instantiateViewController(withIdentifier: "ShowDependenciesPopup") as! ShowDependenciesPopup
                   let width = popupVC.view.bounds.size.width
                   let height = popupVC.view.bounds.size.height
                   let popup = PopupViewController(contentController: popupVC, position: .bottom(5), popupWidth: width, popupHeight: height)
                   popup.canTapOutsideToDismiss = true
                   self.present(popup, animated: true, completion: nil)
    }
    
//    @objc func toggleTransportRunningUI(){
//        if Thread.isMainThread {
//            if DetectLocationModule.processLocationData.state != ProcessLocationData.LocationStates.stoped {
//                MotivFont.motivRegularFontFor(text: "Stop Trip", label: startTripLabel, size: 15)
//                startTripLabel.textColor = MotivColors.WoortiRed
//
//    //            StartStopRunningTranportDetectionButton.setTitle("Stop Trip",for: .normal)
//    //            StartStopRunningTranportDetectionButton.setTitleColor(UIColor.red, for: .normal)
//    //            //            StartStopRunningTranportDetectionButton.titleLabel?.text="Stop Running Transport Detection"
//    //            //            StartStopRunningTranportDetectionButton.titleLabel?.textColor=UIColor.redßßßßßßß
//            } else {
//                MotivFont.motivRegularFontFor(text: "Start Trip", label: startTripLabel, size: 15)
//                startTripLabel.textColor = MotivColors.WoortiGreen
//    //
//    //            StartStopRunningTranportDetectionButton.setTitle("Start Trip",for: .normal)
//    //            StartStopRunningTranportDetectionButton.setTitleColor(UIColor.green, for: .normal)
//    //            //            StartStopRunningTranportDetectionButton.titleLabel?.text="Start Running Transport Detection"
//    //            //            StartStopRunningTranportDetectionButton.titleLabel?.textColor=UIColor.green
//            }
//        } else {
//            DispatchQueue.main.sync {
//                toggleTransportRunningUI()
//            }
//        }
//    }
}

//public class SideMenuItemCell: UITableViewCell {
//
//
//    override public func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override public func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
//
//    func loadCell(key: String, image: String) {
//        MotivFont.motivRegularFontFor(key: key, comment: "", label: self.label, size: 17)
//        self.imageIcon.image = UIImage(named: image)
//    }
//}
