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

/*
 * Singleton class responsible to send and coordinate requests to the server.
 */
class MotivRequestManager {
    
    static private var instance: MotivRequestManager?
    private var token: String
    private var sendtripBgTask: FiniteBackgroundTask? = nil
    public var tripBeingSentToServer = false
    
    public static func getInstance(token: String = "") -> MotivRequestManager {
        if instance == nil {
            instance = MotivRequestManager(token: token)
        } else if token == "" {
            return instance!
        } else if(instance!.token != token) {
            instance = MotivRequestManager(token: token)
        }
        return instance!
    }
    
    private init(token: String){
        self.token = token
    }
    
    /*
    * Initiate request to send trip
    */
    public func sendTrip(trip: FullTrip) -> Bool {

            if(trip.validationDate == nil){
                trip.validationDate = Date()
            }
            
            DispatchQueue.global(qos: .background).async {
                trip.makeRequest(accessToken: self.token)
            }
        return true

    }
    
    /*
    * Initiate request to get campaigns by city and country
    */
    public func requestCampaignsByCityAndCountry(request: getCampaignsByCountryAndCity) {
        DispatchQueue.global(qos: .background).async {
            request.makeRequest(accessToken: self.token)
        }
    }
    
    /*
    * Request user's campaigns
    */
    public func requestCampaignsFullList() {
        DispatchQueue.global(qos: .background).async {
            getCampaignFullList().makeRequest(accessToken: self.token)
        }
    }
    
    /*
    * Sync reward status with server
    */
    public func syncRewardStatusWithServer() {
        DispatchQueue.global(qos: .background).async {
            SendRewardStatus().makeRequest(accessToken: self.token)
        }
    }
    
    /*
    * Request rewards that are available to the user.
    */
    public func requestRewards() {
        DispatchQueue.global(qos: .background).async {
            RewardRequest().makeRequest(accessToken: self.token)
        }
    }
    
    /*
    * Send local user settings to the server.
    * Server will decide if these are old or updated settings and act accordingly.
    */
    public func requestSaveUserSettings() {
        DispatchQueue.global(qos: .background).async {
            SendUserSettings().makeRequest(accessToken: self.token)
        }
    }
    
    /*
    * Request global stats that consist in the total trips and days with trips
    */
    public func requestAllTimeInfo() {
        DispatchQueue.global(qos: .background).async {
            GetAllTimeInfo().makeRequest(accessToken: self.token)
        }
    }
    
    /*
    * Request information to fill dashboard if it isn't stored locally.
    */
    public func requestDashboardStats() {
        DispatchQueue.global(qos: .background).async {
            if let stats = GlobalStatsManager.instance.statsFromServer {
                
            } else {
                GetDashboardStats().makeRequest(accessToken: self.token)
            }
            
        }
    }
    
    /*
    * Request the most updated version of user settings from server
    */
    public func getUserSettings() {
        if let token = MotivUser.getInstance()?.getToken() {
            DispatchQueue.global(qos: .utility).async {
                GetUserSettings().makeRequest(accessToken: token)
            }
        }
    }   
    
    /*
    * request new surveys to the server.
    * This request contains the ID of the most recent survey.
    * Server will only return surveys with a higher ID.
    */
    public func UpdateMySurveys() {
        DispatchQueue.global(qos: .background).async {
            let request = GetMySurveysRequest()
            request.lastSurveyGlobalID = -1
            for survey in UserInfo.getSurveys() {
                if survey.globalSurveyTimestamp > request.lastSurveyGlobalID {
                    request.lastSurveyGlobalID = survey.globalSurveyTimestamp
                }
            }
            request.makeRequest(accessToken: self.token)
        }
    }
    
    /*
    * There is one survey for reporting issues.
    * This method updates reporting survey.
    */
    public func UpdateMyReprotingSurvey() {
        DispatchQueue.global(qos: .background).async {
            let request = GetReportingSurveysRequest()
            request.makeRequest(accessToken: self.token)
        }
    }
    
    /*
    * Send the answered surveys to the server.
    */
    public func sendAnswers() {
        if let token = MotivUser.getInstance()?.getToken() {
            DispatchQueue.global(qos: .utility).async {
                let sendAnswers = SendAnsweredSurveysRequest()
                sendAnswers.makeRequest(accessToken: token)
            }
        }
    }
    
    /*
    * Send reporting survey
    */
    public func sendReport() {
        if let token = MotivUser.getInstance()?.getToken() {
            DispatchQueue.global(qos: .utility).async {
                var request = SendAnsweredReportingRequest()
                request.makeRequest(accessToken: token)
            }
        }
    }
    
    /*
    *Send trip summaries. Each summary is associated with one trip, with the relevant details of the trip (distance, time, legs).
    */
    public func sendSummaries(tripSummaries: [TripSummary]) {
        if let token = MotivUser.getInstance()?.getToken() {
            DispatchQueue.global(qos: .utility).async {
                var request = SendSummaries()
                request.tripSummaries = tripSummaries
                request.makeRequest(accessToken: token)
            }
        }
    }
    
    //MARK: background tasks
    /*
    * Create background task to send trip
    */
    private func startSendTrip() -> Bool {
        if self.sendtripBgTask == nil {
            self.sendtripBgTask = FiniteBackgroundTask()
            self.sendtripBgTask?.registerBackgroundTask(withName: "SendTripBGTask")
            return true
        } else {
            print("error starting new task")
            return false
        }
    }
    
    /*
    * Stop task to send trip
    */
    public func endSendTrip() {
        if self.sendtripBgTask != nil {
            self.sendtripBgTask?.endBackgroundTask()
            self.sendtripBgTask = nil
        }
    }
}
