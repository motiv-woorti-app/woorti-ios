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

/**
* Retrieve DashInfo (e.g., co2/calories spent) for the specified period.
* var processedValues: Dictionary with DashInfo per period
*/
class DashInfoHandler {
    
    var processedValues = [type: (Date, DashInfo)]()
    
    enum type: Int {
        case Day, ThreeDays, Week, Month, Year, Era
    }
    
    /**
    * - parameter: time (Day, ThreeDays, Week, Month, Year, Era
    * Returns DashInfo associated with the time period
    */
    func getInfoForTime(time: type) -> DashInfo {
        let user = MotivUser.getInstance()!
        if let value = processedValues[time],
            Calendar.current.date(byAdding: .hour, value: 11, to: value.0)! < Date() {
            return value.1
        }
        
        switch time {
        case .Era:
            return joinDashInfosForTime(DashboardInfos: user.getAllDashboardInformations(), time: .Era)
        case .Year:
            return user.getYearlyInfoForLastYear()
        default:
            return processTripsForTime(time: time)
        }
    }
    
    /**
    * - parameter: DashboardInfos: DashInfo Array
    * - parameter: time: time period
    * Merge multiple DashInfo objects
    */
    func joinDashInfosForTime(DashboardInfos: [DashInfo], time: type) -> DashInfo {
        let returnDi = DashInfo.getDashInfo(context: UserInfo.context!)!
        returnDi.type = Double(time.rawValue)
        
        return DashboardInfos.reduce(returnDi) { (prev, dashInfo) -> DashInfo in
            prev.joinFrom(di: dashInfo)
            return prev
        }
    }
    
    /**
    * Calculate DashInfo for the given time period
    */
    func processTripsForTime(time: type) -> DashInfo {
        let trips = UserInfo.getFullTrips().reversed() // get the list of full trips from latest to furthest
        var threshold = Date()
        switch time {
        case .Day:
            threshold = Calendar.current.date(byAdding: .day, value: -1, to: threshold)!
        case .ThreeDays:
            threshold = Calendar.current.date(byAdding: .day, value: -3, to: threshold)!
        case .Week:
            threshold = Calendar.current.date(byAdding: .day, value: -7, to: threshold)!
        case .Month:
            threshold = Calendar.current.date(byAdding: .month, value: -1, to: threshold)!
        default:
            threshold = Calendar.current.date(byAdding: .day, value: -1, to: threshold)!
        }
        let returnDi = DashInfo.getDashInfo(context: UserInfo.context!)!
        for trip in trips {
            if threshold < trip.startDate ?? Date() && validatedFT(ft: trip) {
                returnDi.addInfoFromFT(ft: trip)
            }
        }
        processedValues[time] = (Date(), returnDi)
        return returnDi
    }
    
    func validatedFT(ft: FullTrip) -> Bool {
        return ft.confirmed
    }
    
}
