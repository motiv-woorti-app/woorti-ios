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

class ComfortAndDiscomfortFactorsViewController: UIViewController {
    
    var part: FullTripPart?
    var productive: Bool?
    @IBOutlet weak var closeImage: UIImageView!
    @IBOutlet weak var RatingTitle: UILabel!
    
    @IBOutlet weak var TitleRP: UILabel!
    @IBOutlet weak var descriptionRP: UILabel!
    var loaded = false
    
    var chooseFactorsVC: ChooseCDFactorsViewController?
    var orderFactorsVC: OrderCDFactorsViewController?
    var rateFactorsVC: RateCDFactorsViewController?
    var aditionalFactorsVC: AdditionalCDFactorsViewController?
    
    @IBOutlet weak var rankFactorsContainer: UIView!
    @IBOutlet weak var rateFactorsContainer: UIView!
    @IBOutlet weak var aditionalInfoContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gr = UITapGestureRecognizer(target: self, action: #selector(close))
        closeImage.addGestureRecognizer(gr)
        loaded = true
        updateUI()
        rankFactorsContainer.isHidden = true
        rateFactorsContainer.isHidden = true
        aditionalInfoContainer.isHidden = true
        
        self.closeImage.tintColor = UIColor(displayP3Red: CGFloat(236)/CGFloat(255), green: CGFloat(192)/CGFloat(255), blue: CGFloat(138)/CGFloat(255), alpha: CGFloat(1))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(part: FullTripPart, productive: Bool) {
        self.part = part
        self.productive = productive
        updateUI()
        
        let type = productive ? ComfortDiscomfortValues.type.Production : ComfortDiscomfortValues.type.Relaxing
        part.cleanFactors(type: type)
    }
    
    func updateUI(){
        if  let part = self.part,
            let productive = self.productive,
            loaded {
            
            if let leg = part as? Trip {
                self.RatingTitle.text = "\(leg.correctedModeOfTransport ?? "") Rating"
                self.TitleRP.text = "\(productive ? "Productive" : "Relaxing") \(leg.correctedModeOfTransport ?? "") Ride"
                self.descriptionRP.text = "Help us understand what made this \(leg.correctedModeOfTransport ?? "") ride more \(productive ? "Productive" : "Relaxing" ) than usual"
            } else if let we = part as? WaitingEvent {
                self.RatingTitle.text = "Transfer Rating"
                self.TitleRP.text = " \(productive ? "Productive" : "Relaxing" ) Transfer"
                self.descriptionRP.text = "Help us understand what made this Transfer more \(productive ? "Productive" : "Relaxing" ) than usual"
            }
            
            
        }
    }
    
    @objc func close(){
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        view.translatesAutoresizingMaskIntoConstraints = false
        switch segue.destination {
        case let vc as ChooseCDFactorsViewController:
            self.chooseFactorsVC = vc
            vc.ContainedIn = self
        case let vc as OrderCDFactorsViewController:
            self.orderFactorsVC = vc
            vc.ContainedIn = self
        case let vc as RateCDFactorsViewController:
            self.rateFactorsVC = vc
            vc.ContainedIn = self
        case let vc as AdditionalCDFactorsViewController:
            self.aditionalFactorsVC = vc
            vc.ContainedIn = self
        default:
            break
        }
    }
    
    
    func processDone(vc: UIViewController) {
        switch vc {
        case let vc as ChooseCDFactorsViewController:
            rankFactorsContainer.isHidden = false
            if let order = self.orderFactorsVC{
                order.values = vc.selectedValues
                order.reloadView()
            }
            if let rate = self.rateFactorsVC {
                rate.loadValues(newvalues: vc.selectedValues)
            }
            
            break
        case let vc as OrderCDFactorsViewController:
            rateFactorsContainer.isHidden = false
            break
        case let vc as RateCDFactorsViewController:
            aditionalInfoContainer.isHidden = false
            break
        case let vc as AdditionalCDFactorsViewController:
            addFactorsToPart()
            UserInfo.appDelegate?.saveContext()
            self.dismiss(animated: true, completion: nil)
            break
        default:
            break
        }
    }

    func addFactorsToPart(){
        for value in orderFactorsVC!.values {
            let indValue = chooseFactorsVC!.values.index(of: value)!
            let factorCode = chooseFactorsVC!.codes[indValue]
            let textValue = value
            let orderValue = orderFactorsVC!.values.index(of: value)!
            let type = productive! ? ComfortDiscomfortValues.type.Production : ComfortDiscomfortValues.type.Relaxing
            let additionalText = aditionalFactorsVC!.getText()
            let rate = rateFactorsVC!.values[value]!
            
            let factor = ComfortDiscomfortValues.getComfortDiscomfortValues(indValue: factorCode, textValue: textValue, orderValue: Double(orderValue), type: type, rate: Double(rate), context: UserInfo.context!)
        
            self.part!.addCDFactorValue(cdfactor: factor!, type: type, factorText: additionalText)
        }
    }
}
