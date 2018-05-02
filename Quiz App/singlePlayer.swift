//
//  singlePlayer.swift
//  Quiz App
//
//  Created by The Dreadnought on 4/26/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit
import CoreMotion
import Darwin


class singlePlayer: UIViewController {
    
    //the json file url
    let QUIZ_URL = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
    var questionArray = [Question]()
    var totalQuestions = 0
    var currentQuestion = -1
    var timeSeconds = 20
    var labels = [UILabel]()
    var clockTimer = Timer()
    var score = 0
    
    // UI variables
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var totalQuestionLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel_A: UILabel!
    @IBOutlet weak var answerLabel_B: UILabel!
    @IBOutlet weak var answerLabel_C: UILabel!
    @IBOutlet weak var answerLabel_D: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        labels = [answerLabel_A, answerLabel_B, answerLabel_C, answerLabel_D]
        timerLabel.text = "\(timeSeconds)"
        scoreLabel.text = "\(score)"
        for index in 0..<labels.count{
             let selectTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.selectAnswerTap(sender:)))
            let submitTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.submitAnswerTap(sender:)))
            //  selectTapGesture.numberOfTapsRequired = 1
            submitTapGesture.numberOfTapsRequired = 2
            labels[index].isUserInteractionEnabled = true
            labels[index].backgroundColor = UIColor.lightGray
              labels[index].addGestureRecognizer(selectTapGesture)
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
    @objc func submitAnswerTap(sender: UITapGestureRecognizer){
        let selection = sender.view as! UILabel
        
        for index in 0..<labels.count{
            if labels[index] == selection{
                labels[index].backgroundColor = UIColor.green
            }else{
                labels[index].backgroundColor = UIColor.lightGray
            }
        }
        for index in 0..<self.labels.count{
            self.labels[index].isUserInteractionEnabled = false
        }
        UIView.animate(withDuration: 30, animations: {
            if String((selection.text?.first!)!).trimmingCharacters(in: .whitespaces) == self.questionArray[self.currentQuestion].correctOption{
                self.score += 1
                self.scoreLabel.text = "\(self.score)"
                self.timerLabel.text = "Correct!"
                
            }else{
                 self.timerLabel.text = "Answer was: \(self.questionArray[self.currentQuestion].correctOption)"
            }
        }, completion: {(finished: Bool) in
            if !(self.isLastQuestion()) {
                self.timeSeconds = 21
                selection.backgroundColor = UIColor.lightGray
                self.updateQuestion()
            }else {
                self.timeSeconds = 2
            }
        })
    }
    
    /**
     * Determines if quiz is on last question
     */
    func isLastQuestion()-> Bool{
        if currentQuestion == questionArray.count - 1 {
            return true
        }
        return false
    }
    
    @objc func selectAnswerTap(sender: UITapGestureRecognizer){
        let selection = sender.view as! UILabel
        
        for index in 0..<labels.count{
            if labels[index] == selection{
                labels[index].backgroundColor = UIColor.blue
            }else{
                labels[index].backgroundColor = UIColor.lightGray
            }
        }
    }
    
    /**
     * Game timer is updated.
     */
    @objc func updateClock() {
        if timeSeconds > 0 {
            timeSeconds -= 1
            timerLabel.text = "\(timeSeconds)"
            scoreLabel.text = "\(score)"
        }else{
            // go to next question
            if isLastQuestion() {
                clockTimer.invalidate()
                self.createAlert(title: "Thank You", message: "For playing our game :)")
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
    
    /**
     * Given a dictionary, question objects are created and added to the
     * question array.
     */
    func parseDictionary(dictionary : [[String: Any]]){
        // for each element in dictionary create a question
        for question in dictionary{
            let newQuestion = Question(number: question["number"] as! Int, correctOption: question["correctOption"] as! String, questionSentence: question["questionSentence"] as! String, options: question["options"] as! [String: Any])
            questionArray.append(newQuestion)
        }
    }
    
    
    /**
     * View labels are updated to the next question.
     */
    func updateQuestion(){
//        timeSeconds = 21
        for index in 0..<self.labels.count{
            self.labels[index].isUserInteractionEnabled = true
        }
        if currentQuestion < questionArray.count - 1 {
            currentQuestion += 1
            DispatchQueue.main.async {
                if !self.questionArray.isEmpty {
                    self.questionLabel.text = (self.questionArray[self.currentQuestion].questionSentence)
                    self.currentQuestionNumberLabel.text = "\(self.questionArray[self.currentQuestion].number)"
                    self.totalQuestionLabel.text = "\(self.totalQuestions)"
                    
                    self.answerLabel_A.text = "A: \(String(describing: self.questionArray[self.currentQuestion].options["A"] as! String))"
                    self.answerLabel_A.backgroundColor = UIColor.lightGray
                    self.answerLabel_B.text = "B: \(String(describing: self.questionArray[self.currentQuestion].options["B"] as! String))"
                    self.answerLabel_B.backgroundColor = UIColor.lightGray
                    self.answerLabel_C.text = "C: \(String(describing: self.questionArray[self.currentQuestion].options["C"] as! String))"
                    self.answerLabel_C.backgroundColor = UIColor.lightGray
                    self.answerLabel_D.text = "D: \(String(describing: self.questionArray[self.currentQuestion].options["D"] as! String))"
                    self.answerLabel_D.backgroundColor = UIColor.lightGray
                }else{
                    print("No questions available")
                }
            }
        }
    }
    func createAlert (title:String, message:String)
    {
        let alert = UIAlertController(title:title,message:message,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Thank You For Making This Wonderful App",style: UIAlertActionStyle.default, handler:{(action)in alert.dismiss(animated : true,completion : nil)
            exit(0)
        }))
        
        self.present(alert,animated: true, completion: nil)
    }
    
    var motionManger = CMMotionManager()
    
    override func viewDidAppear(_ animated: Bool) {
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


