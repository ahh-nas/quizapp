//
//  singlePlayer.swift
//  Quiz App
//
//  Created by The Dreadnought on 4/26/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit
import CoreMotion

class singlePlayer: UIViewController {
    
    //the json file url
    let QUIZ_URL = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
    var questionArray = [Question]()
    var totalQuestions = 0
    var currentQuestion = -1
    var timeSeconds = 20
    var labels = [UILabel]()
    var clockTimer = Timer()
    
    // UI variables
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var totalQuestionLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel_A: UILabel!
    @IBOutlet weak var answerLabel_B: UILabel!
    @IBOutlet weak var answerLabel_C: UILabel!
    @IBOutlet weak var answerLabel_D: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        labels = [answerLabel_A, answerLabel_B, answerLabel_C, answerLabel_D]
        timerLabel.text = "\(timeSeconds)"
        for index in 0..<labels.count{
            // let selectTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.selectAnswerTap(sender:)))
            let submitTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.submitAnswerTap(sender:)))
            //  selectTapGesture.numberOfTapsRequired = 1
            submitTapGesture.numberOfTapsRequired = 2
            labels[index].isUserInteractionEnabled = true
            labels[index].backgroundColor = UIColor.lightGray
            //  labels[index].addGestureRecognizer(selectTapGesture)
            labels[index].tag = index
            labels[index].addGestureRecognizer(submitTapGesture)
        }
        
        clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateClock), userInfo: nil, repeats: true)
        
        getJsonFromUrl()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Question objects
     */
    struct Question {
        let number: Int
        let correctOption : String
        let questionSentence : String
        let options : [String: Any]
    }
    
    /**
     * Selected answer is submitted and quiz moves to the next quesiton.
     */
    func submitAnswerTap(sender: UITapGestureRecognizer){
        let selection = sender.view as! UILabel
        print("submitted answer: \(String(describing: selection.text!))")
        for index in 0..<labels.count{
            if labels[index] == selection{
                labels[index].backgroundColor = UIColor.green
            }else{
                labels[index].backgroundColor = UIColor.lightGray
            }
        }
        
        if selection.text == questionArray[currentQuestion].correctOption{
            print("Correct!")
        }else{
            print("The correct answer is: \(questionArray[currentQuestion].correctOption)")
        }
        
        timeSeconds = 21
        updateQuestion()
    }
    
    /**
     * Game timer is updated.
     */
    func updateClock() {
        if timeSeconds > 0 {
            timeSeconds -= 1
            timerLabel.text = "\(timeSeconds)"
        }else{
            // go to next question
            if currentQuestion == questionArray.count - 1 {
                clockTimer.invalidate()
            }else {
                timeSeconds = 20
                updateQuestion()
            }
        }
    }
    
    //this function is fetching the json from URL
    func getJsonFromUrl(){
        let url = URL(string: QUIZ_URL)
        
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                self.totalQuestions = json["numberOfQuestions"] as! Int
                let dictionary = json["questions"] as? [[String: Any]] ?? []
                self.parseDictionary(dictionary: dictionary)
                self.updateQuestion()
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    
    func parseDictionary(dictionary : [[String: Any]]){
        // for each element in dictionary create a question
        for question in dictionary{
            let newQuestion = question(number: question["number"] as! Int, correctOption: question["correctOption"] as! String, questionSentence: question["questionSentence"] as! String, options: question["options"] as! [String: Any])
            questionArray.append(newQuestion)
        }
    }
    
    
    func updateQuestion(){
        if currentQuestion < questionArray.count - 1 {
            currentQuestion += 1
        DispatchQueue.main.async {
            if !self.questionArray.isEmpty {
                self.questionLabel.text = (self.questionArray[self.currentQuestion].questionSentence)
                self.currentQuestionNumberLabel.text = "\(self.questionArray[self.currentQuestion].number)"
                self.totalQuestionLabel.text = "\(self.totalQuestions)"
                
                self.self.answerLabel_A.text = self.questionArray[self.currentQuestion].options["A"] as? String
                self.self.answerLabel_B.text = self.questionArray[self.currentQuestion].options["B"] as? String
                self.answerLabel_C.text = self.questionArray[self.currentQuestion].options["C"] as? String
                self.answerLabel_D.text = self.questionArray[self.currentQuestion].options["D"] as? String
            }else{
                print("No questions available")
            }
        }
    }
    
    
    func selectAnswerTap(sender: UITapGestureRecognizer){
        let selection = sender.view as! UILabel
        print("selected answer: \(String(describing: selection.text!))")
        for index in 0..<labels.count{
            if labels[index] == selection{
                labels[index].backgroundColor = UIColor.blue
            }else{
                labels[index].backgroundColor = UIColor.lightGray
            }
        }
    }
    
    var motionManger = CMMotionManager()
    
        func viewDidAppear(_ animated: Bool) {
        motionManger.gyroUpdateInterval = 1
        motionManger.startGyroUpdates(to: OperationQueue.current!){data,error in
            if let myData = data
            {
                if (myData.rotationRate.x < -0.25 && myData.rotationRate.y < -0.25)
                {
                    self.labels[0].backgroundColor = UIColor.blue
                    self.labels[1].backgroundColor = UIColor.lightGray
                    self.labels[2].backgroundColor = UIColor.lightGray
                    self.labels[3].backgroundColor = UIColor.lightGray
                }
                
                if (myData.rotationRate.x < -0.25 && myData.rotationRate.y > 0.25)
                {
                    self.labels[0].backgroundColor = UIColor.lightGray
                    self.labels[1].backgroundColor = UIColor.blue
                    self.labels[2].backgroundColor = UIColor.lightGray
                    self.labels[3].backgroundColor = UIColor.lightGray
                }
                
                if (myData.rotationRate.x > 0.25 && myData.rotationRate.y < -0.25)
                {
                    self.labels[0].backgroundColor = UIColor.lightGray
                    self.labels[1].backgroundColor = UIColor.lightGray
                    self.labels[2].backgroundColor = UIColor.blue
                    self.labels[3].backgroundColor = UIColor.lightGray
                }
                
                if (myData.rotationRate.x > 0.25 && myData.rotationRate.y > 0.25)
                {
                    self.labels[0].backgroundColor = UIColor.lightGray
                    self.labels[1].backgroundColor = UIColor.lightGray
                    self.labels[2].backgroundColor = UIColor.lightGray
                    self.labels[3].backgroundColor = UIColor.blue
                }
                
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

}
