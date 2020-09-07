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

/*
 * Dashboard cell to show productive/enjoyment/fitness/worthwhileness of user's trips in the selected period. 
 */
class OverallTripsTableViewCell: UITableViewCell {
    @IBOutlet weak var overalWorthwhilenessLabel: UILabel!
    
    @IBOutlet weak var productiveWorthwhilenessLabel: UILabel!
    @IBOutlet weak var enjoymentWorthwhilenessLabel: UILabel!
    @IBOutlet weak var fitnessWorthwhilenessLabel: UILabel!
    @IBOutlet weak var TotalWorthwhilenessLabel: UILabel!
    @IBOutlet weak var InfoImage: UIImageView!
    
    var worthwhile = 55.0
    var productive = 60.0
    var enjoyment = 22.0
    var fitness = 50.0
    
    let smallSize = 15
    let bigSize = 23
    
    var infoIsOut = false
    var layoutView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var canSelectCommunity = false
    
    fileprivate func loadText() {
        // Initialization code
        print("--Worthwhile = " + String(worthwhile))
        let initialOverallString = String(format: NSLocalizedString("Your_Trips_Overall_Percentage_Worthwhile", comment: ""), "#")
        
        var splitOverallString = initialOverallString.components(separatedBy: "#")
        
        var finalOverallString = MotivFont.getRegularText(text: splitOverallString[0], size: smallSize)
        finalOverallString.append(MotivFont.getBoldText(text: String(format: "%.0f%%", worthwhile), size: bigSize))
        finalOverallString.append(MotivFont.getRegularText(text: splitOverallString[1], size: smallSize))
        
        MotivFont.motivAttributedFontFor(attributedText: finalOverallString, label: overalWorthwhilenessLabel)
        
        let productiveString = NSLocalizedString("Productive", comment: "")
        let enjoymentString = NSLocalizedString("Enjoyment", comment: "")
        let fitnessString = NSLocalizedString("Fitness", comment: "")
        let worthwhileString = NSLocalizedString("Worthwhile", comment: "")
        
        
        do {
            if(canSelectCommunity) {
                MotivFont.motivRegularFontFor(text: String(Int(productive)) + "% " + productiveString, label: productiveWorthwhilenessLabel, size: smallSize, underlined: true)
                MotivFont.motivRegularFontFor(text: String(Int(enjoyment)) + "% " + enjoymentString, label: enjoymentWorthwhilenessLabel, size: smallSize, underlined: true)
                MotivFont.motivRegularFontFor(text: String(Int(fitness)) + "% " + fitnessString, label: fitnessWorthwhilenessLabel, size: smallSize, underlined: true)
                MotivFont.motivRegularFontFor(text: String(Int(worthwhile)) + "% " + worthwhileString, label: TotalWorthwhilenessLabel, size: smallSize, underlined: true)
            } else {
                if(!productive.isNaN) {
                    MotivFont.motivRegularFontFor(text: String(Int(productive)) + "% " + productiveString, label: productiveWorthwhilenessLabel, size: smallSize)
                }
                if(!enjoyment.isNaN) {
                    MotivFont.motivRegularFontFor(text: String(Int(enjoyment)) + "% " + enjoymentString, label: enjoymentWorthwhilenessLabel, size: smallSize)
                }
                if(!fitness.isNaN) {
                    MotivFont.motivRegularFontFor(text: String(Int(fitness)) + "% " + fitnessString, label: fitnessWorthwhilenessLabel, size: smallSize)
                }
                if(!worthwhile.isNaN) {
                    MotivFont.motivRegularFontFor(text: String(Int(worthwhile)) + "% " + worthwhileString, label: TotalWorthwhilenessLabel, size: smallSize)
                }
            }
        } catch {
            
            
        }
        
        self.InfoImage.isUserInteractionEnabled = true
        let gr = UITapGestureRecognizer(target: self, action: #selector(clickInfoButton))
        self.InfoImage.addGestureRecognizer(gr)
        
        if(canSelectCommunity) {
            self.productiveWorthwhilenessLabel.isUserInteractionEnabled = true
            self.enjoymentWorthwhilenessLabel.isUserInteractionEnabled = true
            self.fitnessWorthwhilenessLabel.isUserInteractionEnabled = true
            self.TotalWorthwhilenessLabel.isUserInteractionEnabled = true
        }
        
        let productiveGesture = UITapGestureRecognizer(target: self, action: #selector(clickProd))
        let enjoymentGesture = UITapGestureRecognizer(target: self, action: #selector(clickEnjoy))
        let fitnessGesture = UITapGestureRecognizer(target: self, action: #selector(clickFit))
        let worthGesture = UITapGestureRecognizer(target: self, action: #selector(clickWorth))
        
        self.productiveWorthwhilenessLabel.addGestureRecognizer(productiveGesture)
        self.enjoymentWorthwhilenessLabel.addGestureRecognizer(enjoymentGesture)
        self.fitnessWorthwhilenessLabel.addGestureRecognizer(fitnessGesture)
        self.TotalWorthwhilenessLabel.addGestureRecognizer(worthGesture)
        
        overalWorthwhilenessLabel.textColor = UIColor.white
        productiveWorthwhilenessLabel.textColor = UIColor.white
        enjoymentWorthwhilenessLabel.textColor = UIColor.white
        fitnessWorthwhilenessLabel.textColor = UIColor.white
        TotalWorthwhilenessLabel.textColor = UIColor.white
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadText()
    }
    
    func cellLoad(di: DashInfo){
        self.worthwhile = (di.totalWorth * 100) ?? 0
        self.productive = (di.productiveWorth * 100) ?? 0
        self.enjoyment = (di.enjoymentWorth * 100) ?? 0
        self.fitness = (di.fitnessWorth * 100) ?? 0
        loadText()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    @objc func clickInfoButton() {
        if infoIsOut {
            infoIsOut = false
            removeInfo()
        } else {
            infoIsOut = true
            showInfo()
        }
    }
    
    @objc func showInfo() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.ShowInfoBalloon.rawValue), object: nil)
    }
    
    func removeInfo() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.RemoveInfoBallon.rawValue), object: nil)
    }
    
    @objc func clickProd() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.Productity.rawValue), object: nil)
    }
    
    @objc func clickEnjoy() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.Enjoyment.rawValue), object: nil)
    }
    
    @objc func clickFit() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.Fitness.rawValue), object: nil)
    }
    
    @objc func clickWorth() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.Worthwhile.rawValue), object: nil)
    }
    
    
}
