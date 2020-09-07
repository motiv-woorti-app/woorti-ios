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

/*
 * View that compares worthwhileness/productivity/enjoyment/fitness of the local user with community values.
 */
class WorthwhilenessCommunityVC: GenericViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TopBar: UIView!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CommunityLabel: UILabel!
    @IBOutlet weak var YouLabel: UILabel!
    
    var screenType = screenTypeOptions.Worthwhileness.rawValue
    var dashboard : DashboardViewController?
    
    let modesOfTransport = [Trip.modesOfTransport.walking,Trip.modesOfTransport.running,Trip.modesOfTransport.Bus,Trip.modesOfTransport.Train,Trip.modesOfTransport.Car,Trip.modesOfTransport.Tram, Trip.modesOfTransport.Subway, Trip.modesOfTransport.cycling, Trip.modesOfTransport.Ferry, Trip.modesOfTransport.Plane]

    var modeArray = [Trip.modesOfTransport]()
    
    enum screenTypeOptions : String {
        case Worthwhileness
        case Productivity
        case Enjoyment
        case Fitness
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "ModeDataTableViewCell", bundle: nil), forCellReuseIdentifier: "ModeDataTableViewCell")
        
        if let stats = getCommunityStatsToShow(), let correctedModes = stats.correctedModes {
            for mode in correctedModes {
                modeArray.append(Trip.getModeOfTransportById(id: mode.mode))
            }
        }
        
        if let userStats = getUserStatsToShow(), let correctedModes = userStats.correctedModes {
            for modeStats in correctedModes {
                let mode = Trip.getModeOfTransportById(id: modeStats.mode)
                if !modeArray.contains(mode) {
                    modeArray.append(mode)
                }
            }
        }
        
        
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.TopBar.backgroundColor = MotivColors.WoortiOrange
        
        self.BackButton.tintColor = MotivColors.WoortiOrangeT3
        
        switch screenType {
        case screenTypeOptions.Worthwhileness.rawValue:
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Worthwhileness", comment: ""), label: TitleLabel, size: 14)
            break;
        case screenTypeOptions.Productivity.rawValue:
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Productivity", comment: ""), label: TitleLabel, size: 14)
            break;
        case screenTypeOptions.Enjoyment.rawValue:
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Enjoyment", comment: ""), label: TitleLabel, size: 14)
            break;
        case screenTypeOptions.Fitness.rawValue:
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Fitness", comment: ""), label: TitleLabel, size: 14)
            break;
        default:
            MotivFont.motivBoldFontFor(text: "Fitness", label: TitleLabel, size: 14)
            break;
        }
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: TitleLabel, color: UIColor.white)
        
        MotivFont.motivBoldFontFor(text: NSLocalizedString("Community", comment: ""), label: CommunityLabel, size: 14)
        MotivFont.motivBoldFontFor(text: NSLocalizedString("You", comment: ""), label: YouLabel, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: CommunityLabel, color: MotivColors.WoortiOrange)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: YouLabel, color: MotivColors.WoortiOrangeT1)
        
        self.view.backgroundColor = MotivColors.WoortiOrange
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        MotivAuxiliaryFunctions.RoundView(view: ContainerView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModeDataTableViewCell") as! ModeDataTableViewCell
        
        let mode = modeArray[indexPath.row]
        
        let (modeText, modeImage) = Trip.getLabelAndPictureFromModeOfTRansport(mot: mode)
        
        var leftValueText = ""
        switch screenType {
        case screenTypeOptions.Productivity.rawValue:
            leftValueText = String(format: "%d", getCommunityProdForMode(mode: mode)) + "%"
        case screenTypeOptions.Enjoyment.rawValue:
            leftValueText = String(format: "%d", getCommunityEnjoyForMode(mode: mode)) + "%"
        case screenTypeOptions.Fitness.rawValue:
            leftValueText = String(format: "%d", getCommunityFitForMode(mode: mode)) + "%"
        case screenTypeOptions.Worthwhileness.rawValue:
            leftValueText = String(format: "%d", getCommunityWorthForMode(mode: mode)) + "%"
        default:
            break
        }
        
        var rightValueText = ""
        switch screenType {
        case screenTypeOptions.Productivity.rawValue:
            rightValueText = String(format: "%d", getLocalProdForMode(mode: mode)) + "%"
        case screenTypeOptions.Enjoyment.rawValue:
            rightValueText = String(format: "%d", getLocalEnjoyForMode(mode: mode)) + "%"
        case screenTypeOptions.Fitness.rawValue:
            rightValueText = String(format: "%d", getLocalFitForMode(mode: mode)) + "%"
        case screenTypeOptions.Worthwhileness.rawValue:
            rightValueText = String(format: "%d", getLocalWorthForMode(mode: mode)) + "%"
        default:
            break
        }
        
        
        cell.loadCell(text: modeText, image: modeImage, leftValue: leftValueText, rightValue: rightValueText)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    @IBAction func ClickBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    static func getDateLimitForEraType(type: DashInfoHandler.type) -> Date {
        switch type {
        case DashInfoHandler.type.Day:
            return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        case DashInfoHandler.type.ThreeDays:
            return Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        case DashInfoHandler.type.Week:
            return Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        case DashInfoHandler.type.Month:
            return Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        case DashInfoHandler.type.Year:
            return Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        case DashInfoHandler.type.Era:
            return Calendar.current.date(byAdding: .year, value: -19, to: Date())!
        default:
            break
        }
    }
    
    func getCommunityProdForMode(mode: Trip.modesOfTransport) -> Int {
        var prod = 0
        if let stats = getCommunityStatsToShow() {
            if let correctedModes = stats.correctedModes {
                for modeStats in correctedModes {
                    if Trip.getModeOfTransportById(id: modeStats.mode) == mode {
                        prod = Int((getValueFromTripModeWSumForId(id: 4, array: modeStats.valueFromTripModeWSum!) * 100) / Int64(modeStats.duration * 2))
                    }
                }
            }
            
        }
        return prod
    }
    
    func getCommunityEnjoyForMode(mode: Trip.modesOfTransport) -> Int {
        var prod = 0
        if let stats = getCommunityStatsToShow() {
            if let correctedModes = stats.correctedModes {
                for modeStats in correctedModes {
                    if Trip.getModeOfTransportById(id: modeStats.mode) == mode {
                        prod = Int((getValueFromTripModeWSumForId(id: 2, array: modeStats.valueFromTripModeWSum!) * 100) / Int64(modeStats.duration * 2))
                    }
                }
            }
            
        }
        return prod
    }
    
    func getCommunityFitForMode(mode: Trip.modesOfTransport) -> Int {
        var prod = 0
        if let stats = getCommunityStatsToShow() {
            if let correctedModes = stats.correctedModes {
                for modeStats in correctedModes {
                    if Trip.getModeOfTransportById(id: modeStats.mode) == mode {
                        prod = Int((getValueFromTripModeWSumForId(id: 3, array: modeStats.valueFromTripModeWSum!) * 100) / Int64(modeStats.duration * 2))
                    }
                }
            }
            
        }
        return prod
    }
    
    func getCommunityWorthForMode(mode: Trip.modesOfTransport) -> Int {
        var prod = 0
        if let stats = getCommunityStatsToShow() {
            if let correctedModes = stats.correctedModes {
                for modeStats in correctedModes {
                    if Trip.getModeOfTransportById(id: modeStats.mode) == mode {
                        prod = Int(Int64(modeStats.wastedTimeWSum * 100) / Int64(modeStats.duration * 5))
                    }
                }
            }
            
        }
        return prod
    }
    
    func getValueFromTripModeWSumForId(id: Int, array: [ValueFromTripTotalServer]) -> Int64 {
        for element in array {
            if element.code == id {
                return element.value
            }
        }
        return 1
    }
    
    func getCommunityStatsToShow() -> StatsPerTimeInterval? {
        print("Dashboard - get community stats")
        if let globalStats = GlobalStatsManager.instance.statsFromServer {
            print("Dashboard - stats exist")
            if let dataSource = dashboard!.chosenDataSource {
                
                var statsHolder : StatsHolder?
                var stats : StatsPerTimeInterval        //Final stats relevant to show here
                
                
                //Get stats holder (city, country or campaign by id)
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
                
                switch(dashboard!.chosen){
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
                return stats
            }
        }
        print("Dashboard - nil stats")
        return nil
    }
    
    func getUserStatsToShow() -> StatsPerTimeIntervalForUser? {
        print("Dashboard - get community stats")
        if let globalStats = GlobalStatsManager.instance.statsFromServer {
            print("Dashboard - stats exist")
            if let dataSource = dashboard!.chosenDataSource {
                
                var statsHolderForUser = globalStats.user
                var stats : StatsPerTimeIntervalForUser        //Final stats relevant to show here
                
                
               
                
                print("Dashboard - got community stats holder")
                
                switch(dashboard!.chosen){
                case DashInfoHandler.type.Day:
                    stats = statsHolderForUser!.day1!
                    break
                case DashInfoHandler.type.ThreeDays:
                    stats = statsHolderForUser!.day3!
                    break
                case DashInfoHandler.type.Week:
                    stats = statsHolderForUser!.day7!
                    break
                case DashInfoHandler.type.Month:
                    stats = statsHolderForUser!.day30!
                    break
                case DashInfoHandler.type.Year:
                    stats = statsHolderForUser!.day365!
                    break
                case DashInfoHandler.type.Era:
                    stats = statsHolderForUser!.ever!
                    break
                }
                return stats
            }
        }
        print("Dashboard - nil stats")
        return nil
    }
    
   
    func getLocalProdForMode(mode: Trip.modesOfTransport) -> Int {
        var prod = 0
        if let stats = getUserStatsToShow() {
            if let correctedModes = stats.correctedModes {
                for modeStats in correctedModes {
                    if Trip.getModeOfTransportById(id: modeStats.mode) == mode {
                        prod = Int((getValueFromTripModeWSumForId(id: 4, array: modeStats.valueFromTripModeWSum!) * 100) / Int64(modeStats.duration * 2))
                    }
                }
            }
            
        }
        return prod
    }
    
    func getLocalEnjoyForMode(mode: Trip.modesOfTransport) -> Int {
        var prod = 0
        if let stats = getUserStatsToShow() {
            if let correctedModes = stats.correctedModes {
                for modeStats in correctedModes {
                    if Trip.getModeOfTransportById(id: modeStats.mode) == mode {
                        prod = Int((getValueFromTripModeWSumForId(id: 2, array: modeStats.valueFromTripModeWSum!) * 100) / Int64(modeStats.duration * 2))
                    }
                }
            }
            
        }
        return prod
    }
    
    func getLocalFitForMode(mode: Trip.modesOfTransport) -> Int {
        var prod = 0
        if let stats = getUserStatsToShow() {
            if let correctedModes = stats.correctedModes {
                for modeStats in correctedModes {
                    if Trip.getModeOfTransportById(id: modeStats.mode) == mode {
                        prod = Int((getValueFromTripModeWSumForId(id: 3, array: modeStats.valueFromTripModeWSum!) * 100) / Int64(modeStats.duration * 2))
                    }
                }
            }
            
        }
        return prod
    }
    
    func getLocalWorthForMode(mode: Trip.modesOfTransport) -> Int {
        var prod = 0
        if let stats = getUserStatsToShow() {
            if let correctedModes = stats.correctedModes {
                for modeStats in correctedModes {
                    if Trip.getModeOfTransportById(id: modeStats.mode) == mode {
                        prod = Int(Int64(modeStats.wastedTimeWSum * 100) / Int64(modeStats.duration * 5))
                    }
                }
            }
            
        }
        return prod
    }
    
    
}


