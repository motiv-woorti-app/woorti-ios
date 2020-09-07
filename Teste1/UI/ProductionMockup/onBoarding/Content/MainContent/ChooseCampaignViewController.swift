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
import CoreData
import CoreLocation

/*
 * Onboarding view to select the public campaigns that the user wants to join.
 */
class ChooseCampaignViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {
    
    var Campaigns = [MockCampaign]()
    var selectedCampaigns = [MockCampaign]()
    
    static let CAMPAIGN_REQUEST_FINISHED = "ChooseCampaignViewControllercamapignRequestFinished"
    
    @IBOutlet weak var contentPage: UIView!
    @IBOutlet weak var TitleLAbel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var campaignTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.campaignTableView.delegate = self
        self.campaignTableView.dataSource = self
        
        MotivAuxiliaryFunctions.RoundView(view: self.contentPage)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next", comment: "", boldText: true, size: 17, disabled: false, CompleteRoundCorners: true)
        // Do any additional setup after loading the view.
        let user = MotivUser.getInstance()
    
        MotivFont.motivBoldFontFor(key: "Wait_While_Searching_Local_Studies" , comment:"message: Please wait while Woorti searches for local studies", label: self.TitleLAbel, size: 15)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.TitleLAbel, color: MotivColors.WoortiOrange)
        self.view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: ChooseCampaignViewController.CAMPAIGN_REQUEST_FINISHED), object: nil)
        
        
        //Request server the available campaigns for the user
        let campaignsRequest = getCampaignsByCountryAndCity()
        campaignsRequest.city = user?.city ?? ""
        campaignsRequest.country = user?.country ?? ""
        MotivRequestManager.getInstance().requestCampaignsByCityAndCountry(request: campaignsRequest)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Campaigns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseCampaignTableViewCell") as! ChooseCampaignTableViewCell
        let campaign = Campaigns[indexPath.row]
        cell.loadCampaign(title: campaign.name, body: campaign.campaignDescription)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChooseCampaignTableViewCell
        if cell.selectThisCampaign() {
            selectedCampaigns.append(Campaigns[indexPath.row])
        } else {
            let campaign = Campaigns[indexPath.row]
            selectedCampaigns = Campaigns.filter { (mc) -> Bool in
                return (mc.campaignDescription != campaign.campaignDescription && mc.name != campaign.name)
            }
        }
    }

    @IBAction func selectCampaigns(_ sender: Any) {
        let user = MotivUser.getInstance()
        user?.campaigns = NSSet(array: self.selectedCampaigns)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeTochooseAge.rawValue), object: nil)
    }
    
    /*
     * Update campagins available with data received from server
     */
    @objc func reloadData(){
        self.Campaigns = UserInfo.campaigns
        if self.Campaigns.count < 1 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeTochooseAge.rawValue), object: nil)
        }
        
        var campaignsToShow = self.Campaigns.filter( {$0.city != "Any by radius"} )
        
        let campaignsToCheck = self.Campaigns.filter( {$0.city == "Any by radius"} )
        
        if let currentLocation = DetectLocationModule.lastLocationAnyAccuracy {
            print("Location exists")
            for campaign in campaignsToCheck {
                if let radius = campaign.radius, let location = campaign.location {
                    let distance = currentLocation.distance(from: CLLocation(latitude: location.lat, longitude: location.lon))
                    if distance <= radius {
                        print("MockCampaign, distance to campaign location = \(distance)")
                        print("MockCampaign inside our radius, name=" + campaign.name)
                        campaignsToShow.append(campaign)
                    }
                }
            }
        }
        
        
        self.Campaigns = campaignsToShow
        
        if self.Campaigns.count < 1 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeTochooseAge.rawValue), object: nil)
        } else {
            DispatchQueue.main.async {
                MotivFont.motivBoldFontFor(key: "Studies_Title", comment: "message: There are these studies going near you. Which one(s) do you want to contribute with data to?", label: self.TitleLAbel, size: 15)
                self.campaignTableView.reloadData()
            }
        }
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//receive from server!!!!!
class MockCampaign: NSManagedObject, JsonParseable {
    public static let entityName = "MockCampaign"
    public static let titleForDefaultCampaign = "dummyCampaignID"
    private static var defaultCampaign: MockCampaign?
    
    @NSManaged var name: String
    @NSManaged var campaignDescription: String
    @NSManaged var country: String
    @NSManaged var city: String
    @NSManaged var campaignId: String
    
    @NSManaged var pointsWorth: Double
    @NSManaged var pointsTripPurpose: Double
    @NSManaged var pointsTransportMode: Double
    @NSManaged var pointsAllInfo: Double
    @NSManaged var pointsActivities: Double
    
    var radius : Double?
    var location : LocationFromServer?
    
    convenience init(title: String, body: String, country: String, city: String) {
        let context = UserInfo.context!
        let entity = NSEntityDescription.entity(forEntityName: MockCampaign.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.name=title
        self.campaignDescription=body
        self.country=country
        self.city=city
        self.campaignId=title
        
        self.pointsWorth = Double(5)
        self.pointsTripPurpose = Double(20)
        self.pointsTransportMode = Double(5)
        self.pointsAllInfo = Double(15)
        self.pointsActivities = Double(5)
    }
    
    static func getMockCampaign(title: String, body: String, country: String, city: String) -> MockCampaign {
        let context = UserInfo.context!
        var campaign: MockCampaign? = nil
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            campaign = MockCampaign(title: title, body: body, country: country, city: city)
        }
        UserInfo.ContextSemaphore.signal()
        return campaign!
    }
    
    static func getDefaultCampaign() -> MockCampaign {
        if defaultCampaign == nil {
            defaultCampaign = MockCampaign.getMockCampaign(title: MockCampaign.titleForDefaultCampaign, body: "no info", country: "no info", city: "no info")
        }
        return defaultCampaign!
    }
    
    enum CodingKeysSpec: String, CodingKey {
        case name
        case campaignDescription
        case country
        case city
        case campaignId
        case pointsWorth
        case pointsTripPurpose
        case pointsTransportMode
        case pointsAllInfo
        case pointsActivities
        case radius
        case location
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: MockCampaign.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let name = try container.decodeIfPresent(String.self, forKey: .name),
//            let body = try container.decodeIfPresent(String.self, forKey: .body),
            let country = try container.decodeIfPresent(String.self, forKey: .country),
            let city = try container.decodeIfPresent(String.self, forKey: .city),
            let id = try container.decodeIfPresent(String.self, forKey: .campaignId) {
            
            self.name = name
            self.campaignDescription = ""
            if let campaignDescription = try container.decodeIfPresent(String.self, forKey: .campaignDescription) {
                self.campaignDescription = campaignDescription
            }
            self.country = country
            self.city = city
            self.campaignId = id
            
            self.pointsWorth = try container.decodeIfPresent(Double.self, forKey: .pointsWorth) ?? Double(5)
            self.pointsTripPurpose = try container.decodeIfPresent(Double.self, forKey: .pointsTripPurpose) ?? Double(20)
            self.pointsTransportMode = try container.decodeIfPresent(Double.self, forKey: .pointsTransportMode) ?? Double(5)
            self.pointsAllInfo = try container.decodeIfPresent(Double.self, forKey: .pointsAllInfo) ?? Double(15)
            self.pointsActivities = try container.decodeIfPresent(Double.self, forKey: .pointsActivities) ?? Double(5)
            
            if let radius = try container.decodeIfPresent(Double.self, forKey: .radius),
                let campaignLocation = try container.decodeIfPresent(LocationFromServer.self, forKey: .location) {
                print("MockCampaign, got radius")
                self.location = campaignLocation
                self.radius = radius
                
            }
            
        }
    }
    
    public func getID() -> String {
        return self.campaignId
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        
        try container.encode(self.name, forKey: .name)
        try container.encode(self.campaignDescription, forKey: .campaignDescription)
        try container.encode(self.country, forKey: .country)
        try container.encode(self.city, forKey: .city)
    }
}

//Class that represents Campaign target location (by radius)
class LocationFromServer : JsonParseable {
    
    var lat : Double
    var lon : Double
    
    enum CodingKeysSpec: String, CodingKey {
        case lat
        case lon
    }
    
    init() {
        lat = 0.0
        lon = 0.0
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let lat = try container.decodeIfPresent(Double.self, forKey: .lat),
            let lon = try container.decodeIfPresent(Double.self, forKey: .lon) {
            self.lat = lat
            self.lon = lon
        }
        
    }
}
