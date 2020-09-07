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
 * Handle json response
 */
protocol JsonRequest: class, JsonParseable {
    var url: String {get}
    var endpoint: String {get} //"/sessions"+
    var responseClass: JsonResponse {get set}
    
    func responseFunc(response: String)
    func responseFuncError(response: String)
}

extension JsonRequest {
    
    var url: String {get {return "https://app.motiv.gsd.inesc-id.pt:8000"}} 
    
    func makeRequest(accessToken: String?) {
        
        print("Json to send: \(self.toJsonString())")
        RestModule(urlString: url+endpoint, jsonData: self.toJsonData(), method: RestModule.Method.POST, responseFunction: self, accessToken: accessToken).makeRequest()
    }
    
    func responseFunc(response: String) {
        var jsonResponseStr = response
        if self is getCampaignsByCountryAndCity {
            jsonResponseStr = "{ \"campaign\" : "
            jsonResponseStr.append(response)
            jsonResponseStr.append("}")
        }
        else if self is getCampaignFullList {
            jsonResponseStr = "{ \"campaign\" : "
            jsonResponseStr.append(response)
            jsonResponseStr.append("}")
            
        } else if self is GetUserSettings {
            jsonResponseStr = "{ \"user\" : "
            jsonResponseStr.append(response)
            jsonResponseStr.append("}")
        } else if self is RewardRequest {
            jsonResponseStr = "{ \"reward\" : "
            jsonResponseStr.append(response)
            jsonResponseStr.append("}")
        } else if self is SendRewardStatus {
            jsonResponseStr = "{ \"rewardStatus\" : "
            jsonResponseStr.append(response)
            jsonResponseStr.append("}")
        } else if self is GetAllTimeInfo {
            jsonResponseStr = "{ \"allTimeTripInfo\" : "
            jsonResponseStr.append(response)
            jsonResponseStr.append("}")
        } else if self is GetDashboardStats {
            jsonResponseStr = "{ \"globalDashboardStatus\" : "
            jsonResponseStr.append(response)
            jsonResponseStr.append("}")
        }
        
        
        
//        else if self is RequestJourneyMethod {
//            jsonResponseStr = "{ \"places\" : "
//            jsonResponseStr.append(response)
//            jsonResponseStr.append("}")
//        }
            
//        else if self is GetMySurveysRequest {
//                        jsonResponseStr = "{ \"surveys\" : "
//                        jsonResponseStr.append(response)
//                        jsonResponseStr.append("}")
//        }
        
        print("\n \(jsonResponseStr) \n")
        if response == "" {
            responseClass.handleResponse()
        } else if var methodResponse = responseClass.jsonToClass(json: jsonResponseStr) as? JsonResponse {
            methodResponse.responseHandler = responseClass.responseHandler
            DispatchQueue.global(qos: .utility).async {
                methodResponse.handleResponse()
            }
        } else {
            print("error Parsing to json")
        }
    }
    
    func responseFuncError(response: String) {
        let error = ErrorResponse()
        if let errorMethodResponse = error.jsonToClass(json: response) as? ErrorResponse {
            errorMethodResponse.handleResponse()
        } else {
            responseFunc(response: response)
        }
    }
    
    func setResponseHandler(handler: ResponseHandler) {
        responseClass.responseHandler=handler
    }
}
