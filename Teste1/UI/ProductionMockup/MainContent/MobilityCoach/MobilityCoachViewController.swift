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
import Charts
import CoreLocation
import CoreData

/*
* DEPRECATED This feature was removed at some point
*/
class MobilityCoachViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {

    var lessons = [Lesson]()
    var selectedLesson: Lesson?
    var fadeView: UIView?
    @IBOutlet weak var yourMobilityJourney: UILabel!
    
    @IBOutlet weak var imagesColectionView: UICollectionView!
    
    //Chart
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var topContentView: UIView!
    
    @IBOutlet weak var yourMobilityGoalView: UIView!
    @IBOutlet weak var topContentYourScoreLabel: UILabel!
    @IBOutlet weak var topContentYourScoreScore: UILabel!
    @IBOutlet weak var yourMobilityJourneyLabel: UILabel!
    
    // Suggested Trip
    @IBOutlet weak var sAlternativeTripView: UIView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var suggestedTripWhiteView: UIView!
    @IBOutlet weak var co2Label: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var SuggestedTimeIcon: UIImageView!
    @IBOutlet weak var suggestedTimeLabel: UILabel!
    @IBOutlet weak var typeScore: UILabel!
    @IBOutlet weak var percentageValue: UILabel!
    @IBOutlet weak var percentage: UILabel!
    
    var score = 50
    var type: Int?
    
    
    public static let MobilityCoachSetGoalPopUp = "MobilityCoachSetGoalPopUp"
    public static let MobilityCoachRefresh = "MobilityCoachRefresh"
    
    @IBOutlet weak var YourTableName: UITableView!
    
    @IBOutlet var popOver: UIView!
    @IBOutlet weak var popOverBeginButton: UIButton!
    
    @IBOutlet weak var yourMobilityView: UIView!
    @IBOutlet weak var mobilityViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mobilityGoalConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestedAlternativeTripsContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        lessons = Lesson.testLessons()
        YourTableName.delegate = self
        YourTableName.dataSource = self
        
        loadLessons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(popup), name: NSNotification.Name(rawValue: MobilityCoachViewController.MobilityCoachSetGoalPopUp), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: MobilityCoachViewController.MobilityCoachRefresh), object: nil)
        
        let frame = self.view.bounds
        self.popOver.bounds = CGRect(x: 0, y: 0, width: frame.width - 60, height: frame.height - 200)
        self.popOver.layer.cornerRadius = (self.popOver?.bounds.height ?? 0)/14
        self.popOverBeginButton?.layer.cornerRadius = (self.popOverBeginButton?.bounds.height ?? 0)/2
    
        
        //Chart
        lineChart.delegate = self
        lineChart.layer.cornerRadius = 9
        topContentView.layer.cornerRadius = 9
    
        MotivFont.motivRegularFontFor(key: "Your_Mobility_Journey", comment: "", label: yourMobilityJourney, size: 17)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: yourMobilityJourney, color: MotivColors.WoortiOrange)
        
        MotivFont.motivRegularFontFor(key: "Your_Mobility_Journey", comment: "", label: yourMobilityJourneyLabel, size: 17)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: yourMobilityJourneyLabel, color: MotivColors.WoortiOrange)
        
        refresh()
    
    }
    
    @objc func refresh() {
        if let user = MotivUser.getInstance(), user.hasSetGoal == true {
            mobilityGoalConstraint.constant = 169
            sAlternativeTripView.isHidden = false
            suggestedAlternativeTripsContraint.constant = 233
            yourMobilityGoalView.isHidden = false
            self.imagesColectionView.register(UINib.init(nibName: "IconImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IconImageCollectionViewCell")
            type = 0
            setUpChart()
            loadChartView()
            
            var loaded = false
            
        } else {
            mobilityGoalConstraint.constant = 0 //169
            sAlternativeTripView.isHidden = true
            suggestedAlternativeTripsContraint.constant = 0 //233
            yourMobilityGoalView.isHidden = true
        }
        
        if let user = MotivUser.getInstance(),
            !user.hasSetGoal && (Date().timeIntervalSince1970 - user.registerDate.timeIntervalSince1970) > 30 {
 
 
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.DisableGoalPopupImage.rawValue), object: nil)

        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.DisableGoalPopupImage.rawValue), object: nil)
        }
    }
    
    //chart
    private func loadChartView() {
        if let type = type {
            
            switch type {
            case 0: //productivity
                score = 50
                
                topContentYourScoreLabel.text = "Your productivity score"
                topContentYourScoreScore.text = "\(score)%"
                break
            case 1: //activity
                score = 10
                
                topContentYourScoreLabel.text = "Your activity score"
                topContentYourScoreScore.text = "\(score)%"
                break
            case 2:
                score = 30
                
                topContentYourScoreLabel.text = "Your relaxing score"
                topContentYourScoreScore.text = "\(score)%"
                break
            default:
                break
            }
            loadChart()
        }
    }
    
    func setUpChart() {
        
        let linesAndTextColor = UIColor(red: 251/255, green: 232/255, blue: 193/255, alpha: 1)
        let backgroundColor = UIColor(red: 221/255, green: 131/255, blue: 48/255, alpha: 1)

        
        self.lineChart.isUserInteractionEnabled = false
        self.lineChart.gridBackgroundColor = backgroundColor
        self.topContentView.backgroundColor = backgroundColor

        self.lineChart.drawGridBackgroundEnabled = true
        self.lineChart.legend.enabled = false
        self.lineChart.chartDescription?.enabled = false

        
        self.lineChart.xAxis.granularity = Double(1)
        self.lineChart.xAxis.gridColor = linesAndTextColor.withAlphaComponent(0.5)
        self.lineChart.xAxis.axisLineColor = linesAndTextColor
        self.lineChart.xAxis.labelTextColor = linesAndTextColor
        self.lineChart.xAxis.labelPosition = .bottom
        self.lineChart.xAxis.labelCount = 10
        
        self.lineChart.leftAxis.axisMinimum = 0 //linechartdata.yMin
        self.lineChart.leftAxis.axisMaximum = 100 //linechartdata.yMax
        self.lineChart.leftAxis.granularity = Double(1)
        self.lineChart.leftAxis.axisLineColor = linesAndTextColor
        self.lineChart.leftAxis.drawGridLinesEnabled = false
        self.lineChart.leftAxis.drawLabelsEnabled = false
        
        self.lineChart.rightAxis.gridColor = backgroundColor
        self.lineChart.rightAxis.axisLineColor = backgroundColor
        self.lineChart.rightAxis.labelTextColor = backgroundColor
        self.lineChart.rightAxis.enabled = false
    }
    
    func loadChart(){
        
        let values = [(1, score),(2, score),(3, score)]
        
        var dataEntries = [ChartDataEntry]()
        
        for (l,v) in values {
            dataEntries.append(ChartDataEntry(x: Double(l), y: Double(v)))
        }
        
        let linesAndTextColor = UIColor(red: 251/255, green: 232/255, blue: 193/255, alpha: 1)
        //        let backgroundColor = UIColor(red: 221/255, green: 131/255, blue: 48/255, alpha: 1)
        let circleHoleCollor = UIColor(red: 242/255, green: 174/255, blue: 70/255, alpha: 1)
        
        let lineCharDataSet = LineChartDataSet(values: dataEntries, label: nil)
        lineCharDataSet.circleColors = [UIColor.black]
        lineCharDataSet.colors = [linesAndTextColor]
        lineCharDataSet.drawCircleHoleEnabled = true
        lineCharDataSet.circleHoleColor = circleHoleCollor
        lineCharDataSet.axisDependency = .left
        lineCharDataSet.drawValuesEnabled = false
        
        let linechartdata = LineChartData(dataSets: [lineCharDataSet])
        self.lineChart.xAxis.axisMinimum = linechartdata.xMin
        self.lineChart.xAxis.axisMaximum = linechartdata.xMin + Double(9)
        
        self.lineChart.data = linechartdata
    }
    
    
    //popup
    @objc func popup(){
        closePopup()
        self.fadeView = UIView(frame: self.view.bounds)
        fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(fadeView!)
        fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePopup)))
        
        self.view.addSubview(self.popOver)
        self.popOver.center = self.view.center
    }
    
    @objc func closePopup() {
        self.fadeView?.removeFromSuperview()
        self.popOver?.removeFromSuperview()
    }
    
    //lessons
    func loadLessons(){
//        getLessonsToshow
        if let user = MotivUser.getInstance() {
            lessons = user.getLessonsToshow()
          
    //        lessons = Lesson.testLessons()
            
    //        lessons.append(Lesson.getNextDayLesson(number: lessons.count + 1))
            lessons = lessons.reversed()
            DispatchQueue.main.async {
                self.YourTableName.reloadData()
    //            self.mobilityViewHeightConstraint.constant = self.getHeightFromSubViews(view: self.yourMobilityView)
                self.mobilityViewHeightConstraint.constant = CGFloat( 79 *  self.lessons.count)
            }
        }
    }
    
    @IBAction func clickBegin(_ sender: Any) {
        self.closePopup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableViewCell") as! LessonTableViewCell
        
        var type = Lesson.cellType.full
        
//        if indexPath.row < lessons.count - 2 {
//            type = Lesson.cellType.faded
//        } else if indexPath.row == lessons.count - 1 {
//            type = Lesson.cellType.next
//        }
        
        
        let lesson = lessons[indexPath.row]
        let nextlesson = Lesson.getNextDayLesson(number: 0)
        let firstLesson = lessons[0]
        
        if lesson.subTitle == nextlesson.subTitle {
            type = Lesson.cellType.next
        } else if firstLesson.subTitle == nextlesson.subTitle {
            if indexPath.row > 1 {
                type = Lesson.cellType.faded
            }
        } else if indexPath.row > 0 {
            type = Lesson.cellType.faded
        }
        
        if indexPath.row == 0 {
            cell.loadCell(lesson: lesson, type: type, first: true)
        } else if indexPath.row == lessons.count - 1 {
            cell.loadCell(lesson: lesson, type: type, last: true)
        } else {
            cell.loadCell(lesson: lesson, type: type)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let lesson = self.lessons[indexPath.row]
        if lesson.text != Lesson.getNextDayLesson(number: 0).text {
            self.selectedLesson = lesson
            self.performSegue(withIdentifier: "LessonViewController", sender: nil)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segue.destination {
        case let lessonVC as LessonViewController:
            if let lesson = self.selectedLesson {
                lessonVC.loadLesson(lesson: lesson)
                self.selectedLesson = nil
            }
        default:
            break
        }
        
    }
}

@objc class Lesson: NSManagedObject {
//    , NSCoding, JsonParseable {
    private static let entityName = "Lesson"
    
    @NSManaged var thumbImage: String
    @NSManaged var image: String
    @NSManaged var title: String
    @NSManaged var subTitle: String
    @NSManaged var text: String
    @NSManaged var read: Date?
    @NSManaged var order: Double
    
    convenience init(thumbImage: String, image: String, title: String, subTitle: String, text: String, order: Double) {
        let entity = NSEntityDescription.entity(forEntityName: Lesson.entityName, in: UserInfo.context!)!
        self.init(entity: entity, insertInto: UserInfo.context!)
        
        self.thumbImage = thumbImage
        self.image = image
        self.title = title
        self.subTitle = subTitle
        self.text = text
        self.read = nil
        self.order = order
    }
    
    static func getLesson(thumbImage: String, image: String, title: String, subTitle: String, text: String, order: Double) -> Lesson {
        var lesson: Lesson?
        lesson = Lesson(thumbImage: thumbImage, image: image, title: title, subTitle: subTitle, text: text, order: order)
        return lesson!
    }
    
//    enum CodingKeys: String, CodingKey {
//        case thumbImage
//        case image
//        case title
//        case subTitle
//        case text
//        case read
//    }
    
    func getThumbImage() -> UIImage {
        return UIImage(named: thumbImage)!
    }
    
    func getImage() -> UIImage {
        return UIImage(named: image)!
    }

//    required convenience init(coder decoder: NSCoder) {
//        if let thumbImage = (decoder.decodeObject(forKey: CodingKeys.thumbImage.rawValue) as? String),
//            let image = (decoder.decodeObject(forKey: CodingKeys.image.rawValue) as? String),
//            let title = (decoder.decodeObject(forKey: CodingKeys.title.rawValue) as? String),
//            let subTitle = (decoder.decodeObject(forKey: CodingKeys.subTitle.rawValue) as? String),
//            let text = (decoder.decodeObject(forKey: CodingKeys.text.rawValue) as? String) {
//
//            self.init(thumbImage: thumbImage, image: image, title: title, subTitle: subTitle, text: text)
//        } else {
//            self.init(thumbImage: "baseline_adjust_black", image: "baseline_adjust_black", title: "Lesson", subTitle: "Coming tomorrow", text: "No Text")
//        }
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(self.thumbImage, forKey: CodingKeys.thumbImage.rawValue)
//        coder.encode(self.image, forKey: CodingKeys.image.rawValue)
//        coder.encode(self.title, forKey: CodingKeys.title.rawValue)
//        coder.encode(self.subTitle, forKey: CodingKeys.subTitle.rawValue)
//        coder.encode(self.text, forKey: CodingKeys.text.rawValue)
//        coder.encode(self.read, forKey: CodingKeys.read.rawValue)
//    }
    
    enum cellType {
        case faded
        case full
        case next
    }
    
    func readLesson() {
//        self.read = UtilityFunctions.getDateFromDateTimeWithHourAndMinute(date: Date(), dayDistance: 0)
        self.read = Date()
        
        UserInfo.context?.refresh(MotivUser.getInstance()!, mergeChanges: true)
        UserInfo.appDelegate!.saveContext()
    }
    
    func lessonWasRead() -> Bool {
        return self.read != nil
    }
    
    static func getLessonsForStoryStatefull(stories: [StoryStateful]) -> [Lesson] {
        let lessons = Lesson.testLessons()
        for story in stories {
            let order = story.storyID
            if story.readTimestamp == 0 {
                // if empty don't add
                continue
            }
            for lesson in lessons {
                if lesson.order == order {
                    lesson.read = Date(timeIntervalSince1970: (story.readTimestamp / 1000))
                    break
                }
            }
        }
        
        return lessons
    }
    
    static func loadLessonsIfNecessary(userLessons: [Lesson]) -> [Lesson] {
       
        var lessons = Lesson.testLessons()
        var ind = 0
        
        for lesson in userLessons.sorted(by: { (l1, l2) -> Bool in
            l1.order < l2.order
        }) {
            if lessons.count <= ind {
                break
            }
            if(Int(lesson.order) == ind) {
                lessons[ind].read = lesson.read
                ind += 1
            }
            
        }

        
        return lessons
        
    }
    
    static func testLessons() -> [Lesson] {
        var lessons = [Lesson]()
        
        let storyID1 = String(format: NSLocalizedString("Story", comment: ""), "1")
        let title1 =  NSLocalizedString("story_1_title_chiaras_new_train_ride", comment: "")
        let text1 =  NSLocalizedString("story_1_text_chiaras_train_ride", comment: "")
        lessons.append(Lesson.getLesson(thumbImage: "Chiaras_new_train_ride", image: "Chiaras_new_train_ride", title: storyID1, subTitle: title1, text: text1, order: Double(0)))
        
//        lessons.append(Lesson.getLesson(thumbImage: "Chiaras_new_train_ride", image: "Chiaras_new_train_ride", title: "Lesson 1", subTitle: "Chiara's new train ride", text: """
//Chiara, her husband and their two kids moved recently from the center to the outskirts of Brussels. She takes her children to the kindergarten and school by cargo bike and then rides to the train station, where she gets a 25 minute ride to work at the center of the city. This was a big change in her commute, and Chiara wasn't too happy about spending more time of her day commuting, but she started enjoying the time at the train. Sitting by herself, she could relax and do something that she would not otherwise do.
//Chiara started to take this time to read a book. But after some time, she felt that 25 minutes each time were not enough to really get into the story.
//She then tried reading a magazine, but because she prefers long, in-depth, articles, the same problem happened.
//So, she just started checking what was happening on Facebook. It got her so much drawn into the contents that sometimes she almost forgot to leave at the right station. Chiara decided that accelerating her brain and heart so much wasn't the best way to start a day.
//So, she finally tried something that worked. Because they moved to a Dutch speaking area, she felt like learning the language. Using a language learning app, the time at the train was enough for two or three lessons each ride. It also gives the right cadency for language learning: a little bit each day, steadily leading her to a better connection to the people in her new neighborhood.
//
//Chiara's best fit was a function of the amount of time she had and what she felt doing in this phase of her life.
//
//What about you? What is the best fit for your travel time?
//""", order: Double(0)))
        
        let storyID2 = String(format: NSLocalizedString("Story", comment: ""), "2")
        let title2 =  NSLocalizedString("story_2_title_the_best_way_to_get_great_ideas_while_moving_p1", comment: "")
        let text2 =  NSLocalizedString("story_2_text_the_best_way_to_get_great_ideas_while_moving_p1", comment: "")
        lessons.append(Lesson.getLesson(thumbImage: "greatideas_part1", image: "greatideas_part1", title: storyID2, subTitle: title2, text: text2, order: Double(1)))
        
//        lessons.append(Lesson.getLesson(thumbImage: "greatideas_part1", image: "greatideas_part1", title: "Lesson 2", subTitle: "The best way of getting great ideas while moving", text: """
//Did you notice any activities where new interesting ideas pop-up in your head more easily? When interviewed about what was the most productive part of his day, Elon Musk replied: “when I'm taking the shower”. He's not the only one; loads of people report that many of their best ideas appear to them when they're showering!
//What about when we're moving? Is there any moment which tends to be especially productive for people?
//As a matter a fact, there is one way of moving from one place to another that seems to be particularly good if you want to wander into new ideas. Several bright thinkers seemed to have discovered this advantage and purposefully moved in that form of moving when they wanted to have better thoughts about something.
//Hint: some of them, like xx, yy and xx, lived when there were no motorized vehicles around…
//Hint 2: It is a form of moving that activates the brain.
//
//What's your guess? Check out what it is on tomorrow's story… :)
//""", order: Double(1)))
        
        let storyID3 = String(format: NSLocalizedString("Story", comment: ""), "3")
        let title3 =  NSLocalizedString("story_3_title_the_best_way_to_get_great_ideas_while_moving_p2", comment: "")
        let text3 =  NSLocalizedString("story_3_text_the_best_way_to_get_great_ideas_while_moving_p2", comment: "")
        lessons.append(Lesson.getLesson(thumbImage: "greatideas_part2", image: "greatideas_part2", title: storyID3, subTitle: title3, text: text3, order: Double(2)))
        
//        lessons.append(Lesson.getLesson(thumbImage: "greatideas_part2", image: "greatideas_part2", title: "Lesson 3", subTitle: "The best way of getting great ideas while moving - part 2", text: """
//So, what is the form of moving that all the thinkers mentioned in the previous story did to make them have better ideas?
//Walking!
//Yes, Steve Jobs for example went for lonely walks around Apple's office in Palo Alto just to think better. He also did meetings with people in that way. Instead of an office room, he brought them for a walk.
//But is there any scientific explanation for this, or were these just random phenomena?
//Well, there are studies that show that when humans walk, there are parts of their brain  which become more activated. A study with school children showed that children that arrived in the morning to perform a test, had their brain much more active if they had arrived walking than if they had arrived by car.
//Of course, for the brain to be free for ideas while walking, it seems to be important that there are no major environmental disturbances that oblige you to pay attention to where your going, like obstacles, traffic or too much noise. Cities designed with better conditions for walking are better cities for generating great ideas!
//To promote productive walking meetings, someone had a bright idea (maybe she was walking or showering, we don't really know!): To build an APP which would define paths in the city that were particularly good for walking meetings. This app is called Weeting and has meeting walking routes for several cities in The Netherlands.
//
//How good are your walking paths for thinking?
//""", order: Double(2)))
        
        let storyID4 = String(format: NSLocalizedString("Story", comment: ""), "4")
        let title4 =  NSLocalizedString("story_4_title_the_7_shades_of_pedros_cycling_time", comment: "")
        let text4 =  NSLocalizedString("story_4_text_the_7_shades_of_pedros_cycling_time", comment: "")
        lessons.append(Lesson.getLesson(thumbImage: "7shadesBicyclePedro", image: "7shadesBicyclePedro", title: storyID4, subTitle: title4, text: text4, order: Double(3)))
        
//        lessons.append(Lesson.getLesson(thumbImage: "7shadesBicyclePedro", image: "7shadesBicyclePedro", title: "Lesson 4", subTitle: "The 7 shades of Pedro's cycling time", text: """
//1. Pedro did it as a statement. He started cycling to work at a time when it was still something truly odd in Lisbon. As he passed, old men in the street yelled to him “GO, CYCLIST, GO” as if he were in the Tour. Car drivers honked “GET OUT OF THE ROAD”.
//He believed that people should be able to use their bike to move around in the city, and he was that pioneer hero that gave the example to the future generations of bike commuters.
//He also wanted to prove that cycling was fast, and so he started to chose the quicker paths even if they had heavy traffic, just to save 5 minutes. The less time it took, the better.
//2. As the statement effect faded, he started noticing more the stressful part of it and the occasional sweat. He was so used to pedal hard that it took him a year to get used to ride at a slower pace. He came to appreciate the Dutch style, relaxed way of cycling. He chose again the calmer routes.
//3. After having children, he took each of them to kindergarten and school before starting the 35 minute ride to work. The only alternative to do this was the car, and he started getting fed up of having no choices. “I miss it when I could go by metro and relax”. And so he took the metro whenever he didn't have to take the kids.
//4. When his wife could again take the kids on some days, he recovered part of the pleasure of cycling, but he still felt it to be consuming his time unproductively. He had got used to taking his public transport time to think and read.
//5. One day, as he was cooking dinner, Pedro decided to hear a podcast. He loved it and thought how much better this made his cooking time. He would learn things and hear stories from other people. He started enjoying cooking time.
//It took him again another year to understand that he could do the same in his routine cycling time. His cycling routes became even more slow and long. Each 5 more minutes riding were 5 minutes of podcast pleasure.
//6. Later, Pedro changed job and started working from home. His belly suddenly increased size, as he stopped doing the now 45 minute ride to work. Looking at his increased belly, Pedro realized that the cycling to work over the past years had kept him fit. He started seizing every opportunity (like going to meetings) to go by bike.
//7. But his cycling time was about to improve even more. As his children grew up, he realized that the travel time to school with them were part of the best moments of his live. His children showed that they loved going with him, asked dozens of questions and told him about the latest news at the school. This made his cycling time more worthwhile than anything else.
//""", order: Double(3)))
        
        let storyID5 = String(format: NSLocalizedString("Story", comment: ""), "5")
        let title5 =  NSLocalizedString("story_5_title_stopping_or_not_stopping_in_a_moving_walkway", comment: "")
        let text5 =  NSLocalizedString("story_5_text_stopping_or_not_stopping_in_a_moving_walkway", comment: "")
        lessons.append(Lesson.getLesson(thumbImage: "movingwalkway", image: "movingwalkway", title: storyID5, subTitle: title5, text: text5, order: Double(4)))
        
//        lessons.append(Lesson.getLesson(thumbImage: "movingwalkway", image: "movingwalkway", title: "Lesson 5", subTitle: "Stopping, or not stopping, in a moving walkway?", text: """
//Have you noticed that some people stop in moving walkways or stairways, while others keep walking?
//What do you think is the reason for this distinct behaviour?
//Do you prefer when other people walk, or when they stand?
//If the answer that came into your head seems straight obvious, think again. It might not be that simple.
//Next time you go on a moving walkway, try observing people that either walk or stand. Just by looking at them, you might get pretty good hints about the why. If you keep imagining, you might also have a journey into what might be their whole story. It’s fun!
//
//Stoppint, or not stopping, in a moving walkway? Read our full story here:
//"""
////            https://motivproject.eu/news/detail/stopping-or-not-stopping-in-a-moving-walkway.html
////"""
//, order: Double(4)))
        
        let storyID6 = String(format: NSLocalizedString("Story", comment: ""), "6")
        let title6 =  NSLocalizedString("story_6_title_virtual_travel_time", comment: "")
        let text6 =  NSLocalizedString("story_6_text_virtual_travel_time", comment: "")
        
        lessons.append(Lesson.getLesson(thumbImage: "virtualtraveltime", image: "virtualtraveltime", title: storyID6, subTitle: title6, text: text6, order: Double(5)))
        
//
//        lessons.append(Lesson.getLesson(thumbImage: "virtualtraveltime", image: "virtualtraveltime", title: "Lesson 6", subTitle: "Virtual travel time", text: """
//Have you heard of the “virtual travel time”?
//No, it’s not about travelling in virtual reality. It’s something more concrete.
//How much time do you exactly take travelling from point A to point B? You’ll probably say: well it’s my journey time, of course!
//Well, from a certain perspective, it isn’t. It might even actually be much more than that…
//Think about it: to travel from point A to point B, you probably had to spend some money. If you’re travelling by car, that is all the costs associated to riding and possessing a car. I you’re going by public transport, that’s the cost of your ticket. Even if you’re walking, you’re at least wearing your shows, and you’ll end up having to replace them more quickly.
//But what does money have to do with travel time?
//How do you get money? You (or someone for you) has to work to gain it. And working takes you time. So, the time of your travel is not only the time you spend travelling, it’s also the time you spend earning the money necessary for travelling.
//For example, take a car. On average a car costs, all expenses included, 350 euros a month. The amount of work that you have to put in monthly to pay that car, add it to your travel time of the trips for that month. That’s your virtual travel time.
//If your fortunate, you might say that working is not loss of time, because you love working. And you might also say the same about travelling to work, maybe. Yes, that makes the issue even more complicated.
//"""
////Tell us your thoughts!
////https://www.facebook.com/MotivProject.eu/
////https://twitter.com/MoTiV_Project
////"""
//, order: Double(5)))
        
        
        
//        lessons.append(Lesson.getLesson(thumbImage: "lesson2Thumb", image: "lesson2Image", title: "Lesson 2", subTitle: "Walking and innovation", text: "Steve Jobs used to take walking journeys. He felt this was better to come up with good ideas \n\n Researchers from Stanford University’s Graduate School of Education found that study participants gave more creative responses to questions meant to gauge creative thinking when they were walking, versus sitting.", order: Double(1)))
        return lessons
    }
    
    static func getNextDayLesson(number: Int) -> Lesson {
        let storyID = String(format: NSLocalizedString("Story", comment: ""), String(number))
        return Lesson.getLesson(thumbImage: "baseline_adjust_black", image: "baseline_adjust_black", title: storyID, subTitle: NSLocalizedString("Coming_Tomorrow", comment: ""), text: "No Text",order: Double(number))
    }
}
