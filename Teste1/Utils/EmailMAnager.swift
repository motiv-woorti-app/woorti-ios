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
import MessageUI
import ThirdPartyMailer

class EmailManager: NSObject, MFMailComposeViewControllerDelegate {
    
    static private var manager: EmailManager?
    
    var sentString = ""
    var generatedId = ""
    var lastvc: UIViewController?
    
    private override init() {super.init()}
    
    public static func getInstance() -> EmailManager {
        if manager == nil {
            manager = EmailManager()
        }
        return manager!
    }
    
    func generateID() {
        self.generatedId = "\(MotivUser.getInstance()?.userid ?? "UNKNOWN")\(Date().timeIntervalSince1970)"
    }
    
    func getID() -> String {
        return self.generatedId
    }
    
    func generateUrl() -> String {
        let os = "\(UIDevice.current.systemName)_\(UIDevice.current.systemVersion)"
        return "https://docs.google.com/forms/d/e/1FAIpQLSd_CecHCKoPqb9hptIq1T6aaMvAmxeU7gQOHFWtyNf1ec_XKA/viewform?usp=pp_url&entry.1666136297=\(self.getID())&entry.1046610782=\(os)"
    }
    
    
    
    /// displays view to send email with lofs
    /// - Parameter view: controller where the email view is displayed
    func sendEmail(view: UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            
            let to = "woortiissuereporting@gmail.com"
            let subject = "Trip Debug logs \(self.getID())"
            let body = "\nPlease send this email as is\n"
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setToRecipients([to])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            
            let debugLog = UserInfo.readFromAllLogFiles()
            
            if sendAsThirdParty(to: to, subject: subject, body: "\(body)\n\(debugLog)") {
                UserInfo.deleteLog()
                return
            }
            
            var i = 0
            
            //Attach logs to mail
            for logs in splitStringForFiles(text: debugLog).reversed() {
                if let data = (logs as NSString).data(using: String.Encoding.utf8.rawValue){
                    mail.addAttachmentData(data, mimeType: "text/plain", fileName: "Log\(i)")
                    i+=1
                }
            }
            self.lastvc = view
            
            view.present(mail, animated: true)
        } else {
            // show failure alert
            print("fail to send email")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == MFMailComposeResult.sent {
            UserInfo.deleteLog()
        }
        controller.dismiss(animated: true)
    }
    
    func splitStringForFiles(text: String) -> [String]{
        let Size4Mb =  4 * 1000 * 1000
        if text.count > Size4Mb {
            //get first 4MB
            let log = String(text.dropLast(text.count - Size4Mb))
            //get list for the next Values
            var files = splitStringForFiles(text: String(text.dropFirst(Size4Mb)))
            // write the log on the files dict
            files.append(log)
            return files
        } else {
            return [text]
        }
    }
    
    
    func sendAsThirdParty(to: String, subject: String, body: String) -> Bool{
        let clients = ThirdPartyMailClient.clients()
        let application = UIApplication.shared
        for client in clients {
            if ThirdPartyMailer.application(application, openMailClient: client, recipient: to, subject: subject, body: body) {
                return true
            }
        }
        
        return false
    }
    
}
