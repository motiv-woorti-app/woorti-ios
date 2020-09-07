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

class UiAlerts {
    
    private var view: UIViewController?
    private static var alertInstance = UiAlerts()
    private var alertController: UIAlertController? = nil
    
    static func getInstance() -> UiAlerts {
        return alertInstance
    }
    
    public func newView(view: UIViewController){
        self.view = view
    }

    //MARK: Alert with ttl
    func showAlertMsg(title: String, message: String){
        if self.view != nil {
            self.alertController?.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            self.view!.present(alertController, animated: true, completion: nil)
            let delay = DispatchTime.now().uptimeNanoseconds + UInt64(3.0 * Double(NSEC_PER_SEC))
            let time = DispatchTime(uptimeNanoseconds: delay)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
                self.alertController = nil
                print("popup disappeared")
            })
            self.alertController = alertController
        }
    }
    
    func showAlertMsgForTripValidation(title: String, message: String, seconds: Double){
        if self.view != nil {
            if let controller = self.alertController {
                //self.alertController?.dismiss(animated: false, completion: nil)
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            if Thread.isMainThread {
                 self.view!.present(alertController, animated: false, completion: nil)
            } else {
                DispatchQueue.main.sync {
                    self.view!.present(alertController, animated: false, completion: nil)
                }
            }
           
            let delay = DispatchTime.now().uptimeNanoseconds + UInt64(seconds * Double(NSEC_PER_SEC))
            let time = DispatchTime(uptimeNanoseconds: delay)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: false, completion: nil)
                self.alertController = nil
                print("Trip_Validation_Popup - Dismissing popup")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  UseTripForViewController.oberserverOptions.moveToNext.rawValue), object: nil)
            })
            self.alertController = alertController
        }
    }
    
    func showLoadingBar(){
        if self.view != nil {
            self.alertController?.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            
            alertController.view.addSubview(loadingIndicator)
            self.view!.present(alertController, animated: true, completion: nil)
            let delay = DispatchTime.now().uptimeNanoseconds + UInt64(3.0 * Double(NSEC_PER_SEC))
            let time = DispatchTime(uptimeNanoseconds: delay)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
                self.alertController = nil
            })
            self.alertController = alertController
        }
    }
    
    
    
    
    func showTripBeinSentAlertMsg(){
        print("UiAlert: Show trip being sent alert")
        showAlertMsgForTripValidation(title: "", message: NSLocalizedString("Trip_Submission_Attempt", comment: ""), seconds: 6)
    }
    
    func showAlertMsg(error: Error){
        showAlertMsg(title: "Error", message: error.localizedDescription)
    }
    
    func showEndDumpMessage(){
        showAlertMsg(title: "Send to Server", message: "All confirmed trips were sent to server")
    }
    
    func showEndDeleteAllSentTrips(){
        showAlertMsg(title: "Delete all sent trips", message: "The deletion of sent trips has finished")
    }
    
    func showEndDelete(){
        showAlertMsg(title: "Delete trips", message: "The deletion this trip has finished")
    }
    
    func showRestartAppAfterLanguageChange(){
        showAlertMsg(title: "Language Changed", message: "Please restart the app to complete this Process")
    }
    
    func showResetPasswordAlert(email: String) {
        showAlertMsg(title: "Reset Password", message: "an email was sent to \(email) with the instructions on how to reset the password.")
    }
    
    func showNeedOneTransportMsg(){
        showAlertMsg(title: "", message: "Hey, you must choose at least one mode of transport.")
    }
    
    func showNeedOneWorthwhileUseForMsg(){
        showAlertMsg(title: "", message: "Hey, you must choose at least one worthwhileness element you before you confrim this Trip.")
    }
    
    
    func showAlertViewWithOptionsForSurveys(title: String, message: String) -> Bool {
        let alertSem = DispatchSemaphore(value: 0)
        var accepted = false
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "yes", style: UIAlertActionStyle.default, handler: { (action) in
            accepted = true
            alertSem.signal()
            alert.dismiss(animated: true, completion: nil)
            self.GoToSurveyList()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { (action) in
            accepted = false
            alertSem.signal()
            alert.dismiss(animated: true, completion: nil)
        }))
        if let view = self.view {
            view.present(alert, animated: true, completion: nil)
            alertSem.wait()
        }
        
        return accepted
    }
    
    //MARK: Alert view with option
    func showAlertViewWithOptions(title: String, message: String) -> Bool {
        let alertSem = DispatchSemaphore(value: 0)
        var accepted = false
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "yes", style: UIAlertActionStyle.default, handler: { (action) in
            accepted = true
            alertSem.signal()
            alert.dismiss(animated: true, completion: nil)
            //self.GoToSurveyList()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { (action) in
            accepted = false
            alertSem.signal()
            alert.dismiss(animated: true, completion: nil)
        }))
        if let view = self.view {
            view.present(alert, animated: true, completion: nil)
            alertSem.wait()
        }
        
        return accepted
    }
    
    func showJoinLegAlert() -> Bool{
        return showAlertViewWithOptions(title: "Join Two Legs", message: "Are you sure you want to Join those legs?")
    }
    
    func showSplitLegAlert() -> Bool{
        return showAlertViewWithOptions(title: "Split one Legs", message: "Are you sure you want to split this leg?")
    }
    
    func showSplitTripAlert() -> Bool {
        return showAlertViewWithOptions(title: "Split Trip", message: "Are you sure you want to split the Trip on this Leg?")
    }
    
    func showDeleteAllSentTripsAlert() -> Bool{
        return showAlertViewWithOptions(title: "Delete all sent trips", message: "Are you sure you want to delete all sent trips?")
    }
    
    func showDeleteThisTripAlert() -> Bool{
        return showAlertViewWithOptions(title: "Delete trip", message: "Are you sure you want to delete this trips?")
    }
    
    func showSetHomeAlert() -> Bool {
        return showAlertViewWithOptions(title: "", message: MotivStringsGen.getInstance().Do_You_Want_To_Set_This_Location_Home)
    }
    
    func showSetWorkAlert() -> Bool {
        return showAlertViewWithOptions(title: "", message: MotivStringsGen.getInstance().Do_You_Want_To_Set_This_Location_Work)
    }
    
    //MARK: Alert view with info and close button
    func showAlertViewWithInfo(title: String, info: String){
        let alert = UIAlertController(title: title, message: info, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.view!.present(alert, animated: true, completion: nil)
    }
    
    func showBateryConsumptionInfo() {
        let body = NSLocalizedString("Alert_Battery_Content", comment: "")
        showAlertViewWithInfo(title: "", info: body)
    }
    
    
    func showNewSurveysToAnswerAlert(foreground: Bool) -> Bool{
        if !foreground {
            GoToSurveyList()
            return true
        } else if showAlertViewWithOptionsForSurveys(title: "New Surveys to answer", message: "you have new surveys to answer, do you want to see them?"){
            //GoToSurveyList()
            return true
        }
        return false
    }
    
    func GoToSurveyList() {
        if Thread.isMainThread {
            if let presentView = view {
                let SurveysToFill = presentView.storyboard?.instantiateViewController(withIdentifier: "SurveysToFill") as! SurveyViewController
                presentView.navigationController?.pushViewController(SurveysToFill, animated: true)
            }
        }else {
            DispatchQueue.main.sync{
                GoToSurveyList()
            }
        }
    }
}
