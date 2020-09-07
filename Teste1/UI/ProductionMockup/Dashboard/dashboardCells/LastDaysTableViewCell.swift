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
 * Table cell for dashboard feature showing travel stats (time and dist) in the selected period.
 */
class LastDaysTableViewCell: UITableViewCell {
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var inTheLastLabel: UILabel!
    @IBOutlet weak var youhaveSpentLabel: UILabel!
    
    @IBOutlet weak var ShowTimeSpent: UIButton!
    @IBOutlet weak var showDistSpent: UIButton!
    
    
    var timeLapse = [NSLocalizedString("Day", comment: ""), NSLocalizedString("Days_3", comment: ""), NSLocalizedString("Week", comment: ""), NSLocalizedString("Month", comment: ""),
                     NSLocalizedString("Year", comment: "")]
    var chosen = 1
    let smallSize = 17
    let bigSize = 23
    
    var spentMinutes = 258
    var distanceWalked = 63
    
    var communityCount = 0
    
    var parent: DashboardViewController?
    
    fileprivate func loadText() {
        if let user = MotivUser.getInstance(){
            var finalYouHaveSpentString : NSMutableAttributedString
            if let chosenDataSource = parent?.chosenDataSource {
                
                if chosenDataSource.type == "" {
                    let inititalYouHaveSpentString = String(format: NSLocalizedString("You_Have_Spent_Complete", comment: ""), "#", "#", "#")

                    var splitYouHaveSpent = inititalYouHaveSpentString.components(separatedBy: "#")
                    
                    finalYouHaveSpentString = MotivFont.getRegularText(text: splitYouHaveSpent[0], size: smallSize)
                    finalYouHaveSpentString.append(MotivFont.getBoldText(text: String(spentMinutes) + " mins", size: bigSize))
                    finalYouHaveSpentString.append(MotivFont.getRegularText(text: splitYouHaveSpent[1], size: smallSize))
                    finalYouHaveSpentString.append(MotivFont.getBoldText(text: String(distanceWalked) + " kms", size: bigSize))
                    finalYouHaveSpentString.append(MotivFont.getRegularText(text: splitYouHaveSpent[2], size: smallSize))
                    finalYouHaveSpentString.append(MotivFont.getBoldText(text: user.city, size: bigSize))
                    finalYouHaveSpentString.append(MotivFont.getRegularText(text: ".", size: smallSize))
                    MotivFont.motivAttributedFontFor(attributedText: finalYouHaveSpentString, label: youhaveSpentLabel)
                    
                    
                } else {
                    let communityValues = getCommunityTotalValues()
                    print("Dashboard, community values, duration=\(communityValues.0) and distance=\(communityValues.1)")
                    let durationValue = Int(communityValues.0 - Double(spentMinutes))
                    let distanceValue = Int(communityValues.1 - Double(distanceWalked))
                    var durationString = ""
                    var distanceString = ""
                    if(durationValue < 0) {
                        durationString = "\(abs(durationValue)) " + NSLocalizedString("Minutes_Less", comment: "")
                    } else {
                        durationString = "\(abs(durationValue)) " + NSLocalizedString("Minutes_More", comment: "")
                    }
                    if(distanceValue < 0) {
                        distanceString = "\(abs(distanceValue)) " + NSLocalizedString("Km_Less", comment: "")
                    } else {
                        distanceString = "\(abs(distanceValue)) " + NSLocalizedString("Km_More", comment: "")
                    }
                    
                    
                    let inititalYouHaveSpentString = String(format: NSLocalizedString("People_From_Place_Have_Spent_On_Average", comment: ""), "#", "#", "#")
                    
                    var splitYouHaveSpent = inititalYouHaveSpentString.components(separatedBy: "#")
                    
                    finalYouHaveSpentString = MotivFont.getRegularText(text: splitYouHaveSpent[0], size: smallSize)
                    finalYouHaveSpentString.append(MotivFont.getBoldText(text: chosenDataSource.name, size: bigSize))
                    finalYouHaveSpentString.append(MotivFont.getRegularText(text: splitYouHaveSpent[1], size: smallSize))
                    finalYouHaveSpentString.append(MotivFont.getBoldText(text: distanceString, size: bigSize))
                    finalYouHaveSpentString.append(MotivFont.getRegularText(text: splitYouHaveSpent[2], size: smallSize))
                    finalYouHaveSpentString.append(MotivFont.getBoldText(text: durationString, size: bigSize))
                    finalYouHaveSpentString.append(MotivFont.getRegularText(text: splitYouHaveSpent[3], size: smallSize))
                    MotivFont.motivAttributedFontFor(attributedText: finalYouHaveSpentString, label: youhaveSpentLabel)
                    
                }
            }
            
            
            
            timeButton.setImage(UIImage(named: "cm_arrow_downward_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
            let attString = NSAttributedString(string: timeLapse[chosen], attributes: [NSAttributedStringKey.foregroundColor: MotivColors.WoortiOrange])
            timeButton.setAttributedTitle(attString, for: .normal)
            timeButton.imageView?.tintColor = MotivColors.WoortiOrange
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MotivAuxiliaryFunctions.ShadowOnView(view: timeButton)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: timeButton, bColor: UIColor.white, tColor: UIColor.white, text: timeLapse[chosen], boldText: true, size: smallSize, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: false)
        
        timeButton.imageView?.tintColor = UIColor.white
        timeButton.setImage(UIImage(named: "cm_arrow_downward_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        MotivFont.motivRegularFontFor(key: "In_The_Last", comment: "" , label: inTheLastLabel, size: smallSize)
        loadText()

        inTheLastLabel.textColor = UIColor.white
        youhaveSpentLabel.textColor = UIColor.white
        timeButton.isUserInteractionEnabled = true
        timeButton.isEnabled = true
    }
    
    func cellLoad(parent: DashboardViewController, di: DashInfo, chosen: Int) {
        self.parent = parent
        self.spentMinutes = Int(di.duration)
        self.distanceWalked = Int(di.distance)
        self.chosen = chosen
        loadText()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func DayButtonClick(_ sender: Any) {
        self.parent?.toggleChoosetimeLapse(responder: self, choice: chosen)
    }
    
    func reloadSelection(choice: Int) {
        self.chosen = choice
        MotivAuxiliaryFunctions.loadStandardButton(button: timeButton, bColor: UIColor.white, tColor: UIColor.white, text: timeLapse[chosen], boldText: true, size: smallSize, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: false)
        timeButton.setImage(UIImage(named: "cm_arrow_downward_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        let attString = NSAttributedString(string: timeLapse[chosen], attributes: [NSAttributedStringKey.foregroundColor: MotivColors.WoortiOrange])
        timeButton.setAttributedTitle(attString, for: .normal)
        timeButton.tintColor = MotivColors.WoortiOrange
        timeButton.imageView?.tintColor = MotivColors.WoortiOrange
        timeButton.isUserInteractionEnabled = true
        timeButton.isEnabled = true
    }
    
    @IBAction func clickShowTimeSpent(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.TimeSpentInTravel.rawValue), object: nil)
    }
    
    @IBAction func clickShowDistSpent(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.DistSpentInTravel.rawValue), object: nil)
    }

    func getCommunityTotalValues() -> (Double, Double){
        var duration = 0.0
        var distance = 0.0
        if let communityStats = getCommunityStatsToShow() {
            if communityStats.totalUsers != 0 && communityStats.totalDuration != 0 && communityStats.totalDistance != 0 {
                duration = Double(communityStats.totalDuration) / 60000 / Double(communityStats.totalUsers)
                distance = Double(communityStats.totalDistance) / 1000 / Double(communityStats.totalUsers)
            }
        }
        return (duration, distance)
    }
    
    func getCommunityStatsToShow() -> StatsPerTimeInterval? {
        print("Dashboard - get community stats")
        if let globalStats = GlobalStatsManager.instance.statsFromServer {
            print("Dashboard - stats exist")
            if let dataSource = parent!.chosenDataSource {
                
                var statsHolder : StatsHolder?
                var stats : StatsPerTimeInterval        //Final stats relevant to show here
                
                statsHolder = globalStats.country!
                if dataSource.type == NSLocalizedString("Country", comment: "") {
                    statsHolder = globalStats.country!
                } else if dataSource.type == NSLocalizedString("City_Region", comment: "") {
                    statsHolder = globalStats.city!
                } else if dataSource.type == NSLocalizedString("Campaign", comment: "") {
                    if let statsById = globalStats.campaigns[dataSource.id!] {
                        statsHolder = statsById
                    }
                } else {        //SAFETY ELSE
                    statsHolder = globalStats.country!
                }
                
                print("Dashboard - got community stats holder")
                
                switch(parent!.chosen){
                case DashInfoHandler.type.Day:
                    stats = statsHolder!.day1!
                    break
                case DashInfoHandler.type.ThreeDays:
                    stats = statsHolder!.day3!
                    break
                case DashInfoHandler.type.Week:
                    stats = statsHolder!.day7!
                    break
                case DashInfoHandler.type.Month:
                    stats = statsHolder!.day30!
                    break
                case DashInfoHandler.type.Year:
                    stats = statsHolder!.day365!
                    break
                case DashInfoHandler.type.Era:
                    stats = statsHolder!.era!
                    break
                }
                communityCount = stats.totalUsers
                return stats
            }
        }
        print("Dashboard - nil stats")
        return nil
    }
    
}
