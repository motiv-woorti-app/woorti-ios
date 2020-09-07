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
 * Show stats for the local user (time, dist, co2 consumed, calories) by time (day, week, month...) and transport mode. 
 */
class TransportModeDataViewController: GenericViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var TopBar: UIView!
    
    @IBOutlet weak var BackButton: UIButton!
    
    var screenType = screenTypeOptions.YOU_TIME.rawValue
    var eraType = DashInfoHandler.type.Day
    
    let modesOfTransport = [Trip.modesOfTransport.walking,Trip.modesOfTransport.running,Trip.modesOfTransport.Bus,Trip.modesOfTransport.Train,Trip.modesOfTransport.Car,Trip.modesOfTransport.Tram, Trip.modesOfTransport.Subway, Trip.modesOfTransport.cycling, Trip.modesOfTransport.Ferry, Trip.modesOfTransport.Plane]
    
    //Real data
    var timePerMode = [Trip.modesOfTransport:Double]()
    var distPerMode = [Trip.modesOfTransport:Double]()
    var co2PerMode = [Trip.modesOfTransport:Double]()
    var caloriesPerMode = [Trip.modesOfTransport:Double]()
    
    var modeArray = [Trip.modesOfTransport]()
    
    var sumTotalTime = 0.0
    var sumTotalDist = 0.0
    var sumTotalCo2 = 0.0
    var sumTotalCalories = 0.0
    
    enum screenTypeOptions : String {
        case YOU_TIME
        case YOU_DISTANCE
        case YOU_CO2
        case YOU_CALORIES
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "ModeDataTableViewCell", bundle: nil), forCellReuseIdentifier: "ModeDataTableViewCell")
        
        let dataTimeLimit = TransportModeDataViewController.getDateLimitForEraType(type: eraType)
        
        sumTotalTime = 0.0
        sumTotalDist = 0.0
        sumTotalCalories = 0.0
        sumTotalCo2 = 0.0
        
        for fulltrip in UserInfo.getFullTrips() {
            if let startDate = fulltrip.startDate, startDate > dataTimeLimit {
                for leg in fulltrip.getTripOrderedList(){
                    if leg.modeConfirmed {
                        let mode = leg.getModeOftransport()
                        if let value = timePerMode[mode] {
                            timePerMode[mode]! = value + Double(leg.duration)
                            distPerMode[mode]! = distPerMode[mode]! + Double(leg.distance)
                            co2PerMode[mode]! = co2PerMode[mode]! + Double(DashInfo.getCO2FromPart(part: leg))
                            caloriesPerMode[mode]! = caloriesPerMode[mode]! + Double(DashInfo.getCaloriesFromPart(part: leg))
                        } else {
                            timePerMode[mode] = Double(leg.duration)
                            distPerMode[mode] = Double(leg.distance)
                            co2PerMode[mode] = Double(DashInfo.getCO2FromPart(part: leg))
                            caloriesPerMode[mode] = Double(DashInfo.getCaloriesFromPart(part: leg))
                            modeArray.append(mode)
                        }
                        sumTotalTime += Double(leg.duration) / 3600
                        sumTotalDist += Double(leg.distance) / 1000
                        sumTotalCo2 += Double(DashInfo.getCO2FromPart(part: leg)) / 1000
                        sumTotalCalories += Double(DashInfo.getCaloriesFromPart(part: leg))
                    }
                }
            }
        }
        
        print("Dashboard, sumTotalTime = \(sumTotalTime), sumTotalDist= \(sumTotalDist), sumTotalCo2=\(sumTotalCo2), sumTotalCalories=\(sumTotalCalories)")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.TopBar.backgroundColor = MotivColors.WoortiOrange
        
        self.BackButton.tintColor = MotivColors.WoortiOrangeT3
        
        switch screenType {
        case screenTypeOptions.YOU_TIME.rawValue:
             MotivFont.motivBoldFontFor(text: "Time spent in travel", label: TitleLabel, size: 14)
            break;
        case screenTypeOptions.YOU_DISTANCE.rawValue:
             MotivFont.motivBoldFontFor(text: "Travelled Distance", label: TitleLabel, size: 14)
            break;
        case screenTypeOptions.YOU_CO2.rawValue:
            MotivFont.motivBoldFontFor(text: "CO2 emissions", label: TitleLabel, size: 14)
            break;
        case screenTypeOptions.YOU_CALORIES.rawValue:
            MotivFont.motivBoldFontFor(text: "Calories", label: TitleLabel, size: 14)
            break;
        default:
            MotivFont.motivBoldFontFor(text: "Time spent in travel", label: TitleLabel, size: 14)
            break;
        }
        
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: TitleLabel, color: UIColor.white)
        
        self.view.backgroundColor = MotivColors.WoortiOrange
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        MotivAuxiliaryFunctions.RoundView(view: tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timePerMode.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModeDataTableViewCell") as! ModeDataTableViewCell
        
        let mode = modeArray[indexPath.row]
        
        let (modeText, modeImage) = Trip.getLabelAndPictureFromModeOfTRansport(mot: mode)
        
        var leftValueText = ""
        var rightValueText = ""
        
        switch screenType {
            case screenTypeOptions.YOU_TIME.rawValue:
                let leftValue = (timePerMode[mode]!/3600)
                leftValueText = String(format: "%.1f hrs", leftValue)
                rightValueText = "\(Int((leftValue/sumTotalTime) * 100))%"
                break;
            case screenTypeOptions.YOU_DISTANCE.rawValue:
                let leftValue = (distPerMode[mode]!/1000)
                leftValueText = String(format: "%.1f km", leftValue)
                rightValueText = "\(Int((leftValue/sumTotalDist) * 100))%"
                break;
            case screenTypeOptions.YOU_CO2.rawValue:
                let leftValue = co2PerMode[mode]!
                leftValueText = String(format: "%.1f kg", leftValue)
                rightValueText = "\(Int((leftValue/sumTotalCo2) * 100))%"
                break;
            case screenTypeOptions.YOU_CALORIES.rawValue:
                let leftValue = caloriesPerMode[mode]!
                leftValueText = String(format: "%.1f cal", leftValue)
                rightValueText = "\(Int((leftValue/sumTotalCalories) * 100))%"
                break;
            default:
                break;
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
    
    
}

