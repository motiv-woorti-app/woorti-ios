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
* Class to perform request for public campaigns available
*/
class getCampaignFullList: JsonRequest {
    var responseClass: JsonResponse = getCampaignObjectsOnCampaigns()
    var endpoint = "/api/user/campaigns/objects"
    var url: String {get {return "https://app.motiv.gsd.inesc-id.pt:8000"}}
    
    var voided = Double(0)
    
    func makeRequest(accessToken: String?){
        print("--- Make request campaigns")
        RestModule(urlString: url + endpoint, jsonData: Data(), method: RestModule.Method.GET, responseFunction: self, accessToken: accessToken).makeRequest()
    }
    
    enum CodingKeys: String, CodingKey {
        case voided
    }
    
}

class getCampaignFullListHandler: ResponseHandler {
    func handleResponse(resp: JsonResponse) {
        if let campaigns = resp as? getCampaignObjectsOnCampaigns {
            
            if let user = MotivUser.getInstance(), campaigns.campaign.count > 0 {
                user.setCampaigns(newCampaigns: NSSet(array: campaigns.campaign))
            }
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChooseCampaignViewController.CAMPAIGN_REQUEST_FINISHED), object: nil)
        }
    }
}

class getCampaignObjectsOnCampaigns: JsonResponse {
    var responseHandler: ResponseHandler? = getCampaignFullListHandler()
    var campaign = [MockCampaign]()
    
    enum CodingKeys: String, CodingKey {
        case campaign
    }
    
}






