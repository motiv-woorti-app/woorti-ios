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
* DEPRECATED This feature was removed at some point
*/
class YourMobilityCollectionViewCell: UICollectionViewCell {
    
    //Top content
    //@IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var topContentView: UIView!
    
    @IBOutlet weak var topContentYourScoreLabel: UILabel!
    @IBOutlet weak var topContentYourScoreScore: UILabel!
    
    //Bottom content
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var imageText: UILabel!
    
    @IBOutlet weak var currentScoreText: UILabel!
    @IBOutlet weak var currentScoreSlider: UISlider!
    
    @IBOutlet weak var yourGoalText: UILabel!
    @IBOutlet weak var yourGoalSlider: UISlider!
    
    @IBOutlet weak var gainText: UILabel!
    @IBOutlet weak var minutesGainedText: UILabel!
    
    @IBOutlet weak var setGoalButton: UIButton!
    
    var type: Int?
    var loaded = false
    
    var score: Int = 0
    
    var vc: YourMobilityViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        currentScoreSlider.thumbTintColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        currentScoreSlider.isEnabled = false
        
        //lineChart.delegate = self
        //lineChart.layer.cornerRadius = 9
        bottomContentView.layer.cornerRadius = 9
        topContentView.layer.cornerRadius = 9
        
        setGoalButton.layer.cornerRadius = (setGoalButton.bounds.height / 2)
        
        setUpChart()
        
        loaded = true
        loadView()
        
        
        //        let data = LineChartData(
        //        lineChart.lineData
    }
    
    public func setType(type: Int, vc: YourMobilityViewController){
        self.type = type
        self.vc = vc
        loadView()
    }
    
    private func loadView() {
        if let type = type, loaded {
            
            switch type {
            case 0: //productivity
                score = 50
                
                topContentYourScoreLabel.text = "Your productivity score"
                topContentYourScoreScore.text = "\(score)%"
                
//                @IBOutlet weak var bottomImage: UIImageView!
                imageText.text = "Set a productivity goal of 80% and we will help you gain up to 30 mins of productivity per day"
                
                currentScoreText.text = "Your current score: \(score)%"
                currentScoreSlider.value = Float(score)/100
                
                self.yourGoalText.text = "Your goal: \(Int(self.yourGoalSlider.value * 100))%"
//                yourGoalSlider.value = Float(score)/100
//                yourGoalSlider.value = Float(score)
                
//                @IBOutlet weak var yourGoalText: UILabel!
//                @IBOutlet weak var yourGoalSlider: UISlider!
                
                gainText.text = "gain in productivity (mins)"
                minutesGainedText.text = "30 minutes"
                
                setGoalButton.titleLabel?.text = "Set a goal for productivity"
                bottomImage.image = UIImage(named: "ProductiveSquirel")
                break
            case 1: //activity
                score = 10
                
                topContentYourScoreLabel.text = "Your activity score"
                topContentYourScoreScore.text = "\(score)%"
                //                @IBOutlet weak var bottomImage: UIImageView!
                imageText.text = "Set a activity goal of 60% and we will help you gain up to 60 mins of life per day. Yep! You're welcome chico"
                
                currentScoreText.text = "Your current score: \(score)%"
                currentScoreSlider.value = Float(score)/100
                
                self.yourGoalText.text = "Your goal: \(Int(self.yourGoalSlider.value * 100))%"
//                yourGoalSlider.value = Float(score)/100
                //                yourGoalSlider.value = Float(score)
                
                //                @IBOutlet weak var yourGoalText: UILabel!
                //                @IBOutlet weak var yourGoalSlider: UISlider!
                
                gainText.text = "gain in life (mins)"
                minutesGainedText.text = "60 minutes"
                
                setGoalButton.titleLabel?.text = "Set a goal for activity"
                bottomImage.image = UIImage(named: "activitySquirel")
                break
            case 2:
                score = 30
                
                topContentYourScoreLabel.text = "Your relaxing score"
                topContentYourScoreScore.text = "\(score)%"
                //                @IBOutlet weak var bottomImage: UIImageView!
                imageText.text = "Set a relaxing goal of 50% and we will help you gain up to 15 mins of \"me\" time. Deep breath. Whoosa!"
                
                currentScoreText.text = "Your current score: \(score)%"
                currentScoreSlider.value = Float(score)/100
                
                self.yourGoalText.text = "Your goal: \(Int(self.yourGoalSlider.value * 100))%"
//                yourGoalSlider.value = Float(score)/100
                //                yourGoalSlider.value = Float(score)
                
                //                @IBOutlet weak var yourGoalText: UILabel!
                //                @IBOutlet weak var yourGoalSlider: UISlider!
                
                gainText.text = "gain in \"me\" time (mins)"
                minutesGainedText.text = "15 minutes"
                
                setGoalButton.titleLabel?.text = "Set a goal for relaxing"
                bottomImage.image = UIImage(named: "RelaxingSquirel")
                break
            default:
                break
            }
            loadChart()
        }
    }
    
    @IBAction func SliderValueChanged(_ sender: Any) {
        self.yourGoalText.text = "Your goal: \(Int(self.yourGoalSlider.value * 100))%"
    }
    
    func loadChart(){
        /*
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
        
        self.lineChart.data = linechartdata*/
    }
    
    func setUpChart() {
        /*
        let linesAndTextColor = UIColor(red: 251/255, green: 232/255, blue: 193/255, alpha: 1)
        let backgroundColor = UIColor(red: 221/255, green: 131/255, blue: 48/255, alpha: 1)
//        let circleHoleCollor = UIColor(red: 242/255, green: 174/255, blue: 70/255, alpha: 1)
        
        self.lineChart.isUserInteractionEnabled = false
        self.lineChart.gridBackgroundColor = backgroundColor
        self.topContentView.backgroundColor = backgroundColor
        //        self.lineChart.gridBackgroundColor = UIColor.red
        self.lineChart.drawGridBackgroundEnabled = true
        self.lineChart.legend.enabled = false
        self.lineChart.chartDescription?.enabled = false
        //        self.lineChart.backgroundColor = backgroundColor
        
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
 */
    }
    
    @IBAction func setGoalButton(_ sender: Any) {
        if let vc = self.vc,
            let type = self.type {
            vc.popUp(type: type)
        }
    }
}
