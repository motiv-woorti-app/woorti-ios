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
 * Show travel stats from the community (co2, distance, time, calories).
 * Compare with local stats
 */
class CommunityDataPerModeViewController : GenericViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var BackButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var TopBar: UIView!
    @IBOutlet weak var ContainerView: UIView!
    
    @IBOutlet weak var AvgMinutesLabel: UILabel!
    
    
    
    var screenType = screenTypeOptions.COMMUNITY_TIME.rawValue      //Indicates if screen relative to TIME, DIST, CO2 OR CALORIES
    var eraType = DashInfoHandler.type.Day                          //Time interval - day, 3 days, week,...
    var modeArray = [Trip.modesOfTransport]()                       //Ordered array to populate table
    
    var chosenDashboardType : DashboardTypeOption?                  //City, Country or Campaign
    
    let modesOfTransport = [Trip.modesOfTransport.walking,Trip.modesOfTransport.running,Trip.modesOfTransport.Bus,Trip.modesOfTransport.Train,Trip.modesOfTransport.Car,Trip.modesOfTransport.Tram, Trip.modesOfTransport.Subway, Trip.modesOfTransport.cycling, Trip.modesOfTransport.Ferry, Trip.modesOfTransport.Plane]
    
    //Local Data
    var timePerMode = [Trip.modesOfTransport:Double]()
    var distPerMode = [Trip.modesOfTransport:Double]()
    var co2PerMode = [Trip.modesOfTransport:Double]()
    var caloriesPerMode = [Trip.modesOfTransport:Double]()
    
    var othersTimePerMode = [Trip.modesOfTransport:Double]()
    var othersDistPerMode = [Trip.modesOfTransport:Double]()
    var othersCo2PerMode = [Trip.modesOfTransport:Double]()
    var othersCaloriesPerMode = [Trip.modesOfTransport:Double]()
    
    var maxValuePerMode = (Trip.modesOfTransport.walking, Double(0))
    
    var sumOthersTime = 0.0
    var sumOthersDist = 0.0
    var sumOthersCo2 = 0.0
    var sumOthersCalories = 0.0
    
    var sumLocalTime = 0.0
    var sumLocalDist = 0.0
    var sumLocalCo2 = 0.0
    var sumLocalCalories = 0.0
    
    var totalUsersOnStats = 0


    
    enum screenTypeOptions : String {
        case COMMUNITY_TIME
        case COMMUNITY_DISTANCE
        case COMMUNITY_CO2
        case COMMUNITY_CALORIES
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "CommunityModeDataTableViewCell", bundle: nil), forCellReuseIdentifier: "CommunityModeDataTableViewCell")
        self.TopBar.backgroundColor = MotivColors.WoortiOrange
        self.BackButton.tintColor = MotivColors.WoortiOrangeT3
        
        switch screenType {
        case screenTypeOptions.COMMUNITY_TIME.rawValue:
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Time_Spent_In_Travel", comment: ""), label: TitleLabel, size: 14)
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Avg_Minutes", comment: ""), label: AvgMinutesLabel, size: 14)
            break;
        case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Travelled_Distance", comment: ""), label: TitleLabel, size: 14)
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Avg_Kilometers", comment: ""), label: AvgMinutesLabel, size: 14)
            break;
        case screenTypeOptions.COMMUNITY_CO2.rawValue:
            MotivFont.motivBoldFontFor(text: NSLocalizedString("CO2_Emissions", comment: ""), label: TitleLabel, size: 14)
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Avg_Kilograms", comment: ""), label: AvgMinutesLabel, size: 14)
            break;
        case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Calories", comment: ""), label: TitleLabel, size: 14)
            MotivFont.motivBoldFontFor(text: NSLocalizedString("Avg_Calories", comment: ""), label: AvgMinutesLabel, size: 14)
            break;
        default:
            MotivFont.motivBoldFontFor(text: "Time spent in travel", label: TitleLabel, size: 14)
            break;
        }
        
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: TitleLabel, color: UIColor.white)
        
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: AvgMinutesLabel, color: MotivColors.WoortiBlackT1)
        
        self.view.backgroundColor = MotivColors.WoortiOrange
        
        
        
        
        // REQUIRED DATA COMPUTATION
        computeLocalUserStats()
        if let stats = getCommunityStatsToShow() {
            computeCommunityStats(stats: stats)
            //FILTER VALUES WITH CITIZENS 0
            
            tableView.dataSource = self
            tableView.delegate = self
            self.tableView.tableFooterView = UIView()
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            self.tableView.backgroundColor = UIColor.clear
        }        
       
        MotivAuxiliaryFunctions.RoundView(view: ContainerView)
    }
    
    func filterModeArray(){
        switch screenType {
        case screenTypeOptions.COMMUNITY_TIME.rawValue:
            modeArray = modeArray.filter( { othersTimePerMode[$0] != nil && othersTimePerMode[$0] != 0.0})
        case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
            modeArray = modeArray.filter( {othersDistPerMode[$0] != nil && othersDistPerMode[$0] != 0.0})
        case screenTypeOptions.COMMUNITY_CO2.rawValue:
            modeArray = modeArray.filter( {othersCo2PerMode[$0] != nil && othersCo2PerMode[$0] != 0.0})
        case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
            modeArray = modeArray.filter( {othersCaloriesPerMode[$0] != nil && othersCaloriesPerMode[$0] != 0.0})
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Dashboard, community table count \(modeArray.count)")
        return modeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityModeDataTableViewCell") as! CommunityModeDataTableViewCell

        let mode = modeArray[indexPath.row]
        let (modeText, modeImage) = Trip.getLabelAndPictureFromModeOfTRansport(mot: mode)
        
        let youRawValue = getYouRawValue(mode: mode)
        let citizensRawValue = getCitizensRawValue(mode: mode)
        
        let youPercent = youRawValue == 0 ? 0 : Int(getYouPercentValue(value: youRawValue))
        let citizensPercent = citizensRawValue == 0 ? 0 : Int(getCitizensPercentValue(value: citizensRawValue))
        
        cell.maxValuePerMode = self.maxValuePerMode
        cell.loadCell(modeText: modeText, modeImage: modeImage, citizensRawValue: citizensRawValue, youRawValue: youRawValue, citizensPercent: citizensPercent, youPercent: youPercent)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /*
     * Get stats from local user. (raw value)
     */
    func getYouRawValue(mode: Trip.modesOfTransport) -> Double {
        switch screenType {
        case screenTypeOptions.COMMUNITY_TIME.rawValue:
            if let value = timePerMode[mode] {
                return Double(value)
            } else {
                return 0
            }
        case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
            if let value = distPerMode[mode] {
                return Double(value)
            } else {
                return 0
            }
        case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
            if let value = caloriesPerMode[mode] {
                return Double(value)
            } else {
                return 0
            }
        case screenTypeOptions.COMMUNITY_CO2.rawValue:
            if let value = co2PerMode[mode] {
                return Double(value / 1000.0)
            } else {
                return 0
            }
        default:
            break
        }
        return 0
    }
    
    /*
     * Get stats from local user. (percentage value)
     */
    func getYouPercentValue(value: Double) -> Double {
        switch screenType {
        case screenTypeOptions.COMMUNITY_TIME.rawValue:
            return Double(value * 100 / sumLocalTime)
        case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
            return Double(value * 100 / sumLocalDist)
        case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
            return Double(value * 100 / sumLocalCalories)
        case screenTypeOptions.COMMUNITY_CO2.rawValue:
            return Double(value * 100 / sumLocalCo2)
        default:
            break
        }
        return 0
    }
    
    /*
     * Get stats from community. (percentage value)
     */
    func getCitizensPercentValue(value: Double) -> Double {
        switch screenType {
        case screenTypeOptions.COMMUNITY_TIME.rawValue:
            return Double(value * 100 / sumOthersTime)
        case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
            return Double(value * 100 / sumOthersDist)
        case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
            return Double(value * 100 / sumOthersCalories)
        case screenTypeOptions.COMMUNITY_CO2.rawValue:
            return Double(value * 100 / sumOthersCo2)
        default:
            break
        }
        return 0
    }
    
    /*
     * Get stats from community. (raw value)
     */
    func getCitizensRawValue(mode: Trip.modesOfTransport) -> Double {
        switch screenType {
        case screenTypeOptions.COMMUNITY_TIME.rawValue:
            return Double(othersTimePerMode[mode] ?? 0)
        case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
            return Double(othersDistPerMode[mode] ?? 0)
        case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
            return Double(othersCaloriesPerMode[mode] ?? 0)
        case screenTypeOptions.COMMUNITY_CO2.rawValue:
            return Double(othersCo2PerMode[mode] ?? 0) / 1000.0
        default:
            break
        }
        return 0
    }
    
    @IBAction func clickBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func computeLocalUserStats(){
        let dataTimeLimit = TransportModeDataViewController.getDateLimitForEraType(type: eraType)
        
        for fulltrip in UserInfo.getFullTrips() {
            if let startDate = fulltrip.startDate, startDate > dataTimeLimit {
                for leg in fulltrip.getTripOrderedList(){
                    if leg.modeConfirmed {
                        let mode = leg.getModeOftransport()
                        if let value = timePerMode[mode] {
                            timePerMode[mode]! = value + Double(leg.duration / 60)
                            distPerMode[mode]! = distPerMode[mode]! + Double(leg.distance / 1000)
                            co2PerMode[mode]! = co2PerMode[mode]! + Double(DashInfo.getCO2FromPart(part: leg))
                            caloriesPerMode[mode]! = caloriesPerMode[mode]! + Double(DashInfo.getCaloriesFromPart(part: leg))
                        } else {
                            timePerMode[mode] = Double(leg.duration / 60)
                            distPerMode[mode] = Double(leg.distance / 1000)
                            co2PerMode[mode] = Double(DashInfo.getCO2FromPart(part: leg))
                            caloriesPerMode[mode] = Double(DashInfo.getCaloriesFromPart(part: leg))
                        }
                    }
                }
            }
        }
        
        print("DASHBOARD_LOCAL_USER_STATS, timePerMode.count=\(timePerMode.keys.count)")
        print("DASHBOARD_LOCAL_USER_STATS, distPerMode.count=\(distPerMode.keys.count)")
        print("DASHBOARD_LOCAL_USER_STATS, co2PerMode.count=\(co2PerMode.keys.count)")
        print("DASHBOARD_LOCAL_USER_STATS, caloriesPerMode.count=\(caloriesPerMode.keys.count)")
        
        applyAveragePerDayToUserMaps()
        
        switch screenType {
            case screenTypeOptions.COMMUNITY_TIME.rawValue:
                checkIfMapHasMaxValue(map: timePerMode)
            case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
                checkIfMapHasMaxValue(map: distPerMode)
            case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
                checkIfMapHasMaxValue(map: caloriesPerMode)
            case screenTypeOptions.COMMUNITY_CO2.rawValue:
                checkIfMapHasMaxValue(map: co2PerMode)
            default:
                break
        }
        
        for value in timePerMode.values {
            sumLocalTime += value
        }
        
        for value in distPerMode.values {
            sumLocalDist += value
        }
        
        for value in co2PerMode.values {
            sumLocalCo2 += value
        }
        
        for value in caloriesPerMode.values {
            sumLocalCalories += value
        }
        
        print("DASHBOARD_LOCAL_USER_STATS, sunLocalTime=\(sumLocalTime)")
        print("DASHBOARD_LOCAL_USER_STATS, sumLocalDist=\(sumLocalDist)")
        print("DASHBOARD_LOCAL_USER_STATS, sumLocalCo2=\(sumLocalCo2)")
        print("DASHBOARD_LOCAL_USER_STATS, sumLocalCalories=\(sumLocalCalories)")
        
        
    }
    
    //Update max progress bar value (citizens or YOU)
    func checkIfMapHasMaxValue(map: [Trip.modesOfTransport:Double]){
        for (key, value) in map {
            if value >= maxValuePerMode.1 {
                maxValuePerMode.0 = key
                maxValuePerMode.1 = value
            }
        }
    }
    
    
    //Calculate stats from the chosen selection in dataSource (country, city, campaign)
    //And time interval (day, days, week, month, year)
    func getCommunityStatsToShow() -> StatsPerTimeInterval? {
        print("Dashboard - get community stats")
        if let globalStats = GlobalStatsManager.instance.statsFromServer {
            print("Dashboard - stats exist")
            if let dataSource = chosenDashboardType {
                
                var statsHolder : StatsHolder?
                var stats : StatsPerTimeInterval        //Final stats relevant to show here
                
                
                //Get stats holder (city, country or campaign by id)
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
                
                switch(eraType){
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
                    stats = statsHolder!.day365!
                    break
                    
                }
                totalUsersOnStats = stats.totalUsers
                if totalUsersOnStats == 0 {
                    totalUsersOnStats = 1
                }
                
                
            return stats
            }
        }
        print("Dashboard - nil stats")
        return nil
    }
    

    func computeCommunityStats(stats: StatsPerTimeInterval) {
        if let correctedModes = stats.correctedModes {
            for mode in correctedModes {
                let modeCode = Trip.getModeOfTransportById(id: mode.mode)
                othersTimePerMode[modeCode] = Double(mode.duration / 60000)
                othersDistPerMode[modeCode] = Double(mode.distance / 1000)
                othersCo2PerMode[modeCode] = Double((mode.distance/1000) * DashInfo.getCO2FromMode(mode: modeCode))
                othersCaloriesPerMode[modeCode] = Double((mode.distance/1000) * Double(DashInfo.getCaloriesFromMode(mode: modeCode)))
                modeArray.append(modeCode)
                
                
            }
        }
        
        applyAveragePerDayToCommunityMaps()
        
        switch screenType {
        case screenTypeOptions.COMMUNITY_TIME.rawValue:
            checkIfMapHasMaxValue(map: othersTimePerMode)
        case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
            checkIfMapHasMaxValue(map: othersDistPerMode)
        case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
            checkIfMapHasMaxValue(map: othersCaloriesPerMode)
        case screenTypeOptions.COMMUNITY_CO2.rawValue:
            checkIfMapHasMaxValue(map: othersCo2PerMode)
        default:
            break
        }
        print("MODE ARRAY COUNT BEFORE=\(modeArray.count)")
        switch screenType {
        case screenTypeOptions.COMMUNITY_TIME.rawValue:
            modeArray = modeArray.sorted(by: { (item1, item2) -> Bool in
                return othersTimePerMode[item1]! > othersTimePerMode[item2]!
            })
            break
        case screenTypeOptions.COMMUNITY_DISTANCE.rawValue:
            modeArray = modeArray.sorted(by: { (item1, item2) -> Bool in
                return othersDistPerMode[item1]! > othersDistPerMode[item2]!
            })
            break
        case screenTypeOptions.COMMUNITY_CALORIES.rawValue:
            modeArray = modeArray.sorted(by: { (item1, item2) -> Bool in
                return othersCaloriesPerMode[item1]! > othersCaloriesPerMode[item2]!
            })
            break
        case screenTypeOptions.COMMUNITY_CO2.rawValue:
            modeArray = modeArray.sorted(by: { (item1, item2) -> Bool in
                return othersCo2PerMode[item1]! > othersCo2PerMode[item2]!
            })
            break
        default:
            break
        }
        
        for value in othersTimePerMode.values {
            sumOthersTime += value
        }
        
        for value in othersDistPerMode.values {
            sumOthersDist += value
        }
        
        for value in othersCo2PerMode.values {
            sumOthersCo2 += value
        }
        
        for value in othersCaloriesPerMode.values {
            sumOthersCalories += value
        }
        
        print("DASHBOARD_COMMUNITY_STATS, sumOthersTime=\(sumOthersTime)")
        print("DASHBOARD_COMMUNITY_STATS, sumOthersDist=\(sumOthersDist)")
        print("DASHBOARD_COMMUNITY_STATS, sumOthersCo2=\(sumOthersCo2)")
        print("DASHBOARD_COMMUNITY_STATS, sumOthersCalories=\(sumOthersCalories)")
        
    }
    
    func applyAveragePerDayToUserMaps() {
        //Get the average values by the chosen time interval
        var timeInterval = 1
        switch eraType {
        case DashInfoHandler.type.Day:
            timeInterval = 1
        case DashInfoHandler.type.ThreeDays:
            timeInterval = 3
        case DashInfoHandler.type.Week:
            timeInterval = 7
        case DashInfoHandler.type.Month:
            timeInterval = 30
        case DashInfoHandler.type.Year:
            timeInterval = 365
        case DashInfoHandler.type.Era:
            timeInterval = 365
        default:
            timeInterval = 365
        }
        
        timePerMode = timePerMode.mapValues { value in
            return value / Double(timeInterval)
        }
        
        
        distPerMode = distPerMode.mapValues { value in
            return value / Double(timeInterval)
        }
        
        
        co2PerMode = co2PerMode.mapValues { value in
            return value / Double(timeInterval)
        }
        
        caloriesPerMode = caloriesPerMode.mapValues { value in
            return value / Double(timeInterval)
        }
    }
    
    func applyAveragePerDayToCommunityMaps() {
        //Get the average values by the chosen time interval
        var timeInterval = 1
        switch eraType {
        case DashInfoHandler.type.Day:
            timeInterval = 1
        case DashInfoHandler.type.ThreeDays:
            timeInterval = 3
        case DashInfoHandler.type.Week:
            timeInterval = 7
        case DashInfoHandler.type.Month:
            timeInterval = 30
        case DashInfoHandler.type.Year:
            timeInterval = 365
        case DashInfoHandler.type.Era:
            timeInterval = 365
        default:
            timeInterval = 365
        }
        
        othersTimePerMode = othersTimePerMode.mapValues { value in
            return value / Double(totalUsersOnStats)
        }
        
        othersDistPerMode = othersDistPerMode.mapValues { value in
            return value / Double(totalUsersOnStats)
        }
        
        othersCo2PerMode = othersCo2PerMode.mapValues { value in
            return value / Double(totalUsersOnStats)
        }
        
        othersCaloriesPerMode = othersCaloriesPerMode.mapValues { value in
            return value / Double(totalUsersOnStats)
        }
    }
    
}
    



