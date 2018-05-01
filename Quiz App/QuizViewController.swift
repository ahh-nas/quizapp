//
//  QuizViewController.swift
//  Quiz App
//
//  Created by Adrianne Williams on 4/22/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit
import CoreMotion

class QuizViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //the json file url
    let QUIZ_URL = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
    var questionArray = [Question]()
    var totalQuestions = 0
    var currentQuestion = -1
    var timeSeconds = 20
    var labels = [UILabel]()
    var clockTimer = Timer()
    var numberOfPeers = 0
    
   
    // UI variables
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var totalQuestionLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
   
    @IBOutlet weak var ans_A: UILabel!
    @IBOutlet weak var ans_B: UILabel!
    @IBOutlet weak var ans_C: UILabel!
    @IBOutlet weak var ans_D: UILabel!
    
    //images
    
    @IBOutlet weak var p1: UIImageView!
    @IBOutlet weak var p2: UIImageView!
    @IBOutlet weak var p3: UIImageView!
    @IBOutlet weak var p4: UIImageView!
    
    //scores
    @IBOutlet weak var p1s: UILabel!
    @IBOutlet weak var p2s: UILabel!
    @IBOutlet weak var p3s: UILabel!
    @IBOutlet weak var p4s: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        labels = [ans_A, ans_B, ans_C, ans_D]
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
       

        
        if(numberOfPeers == 2)
        {
            p3.isHidden = true
            p4.isHidden = true
            p3s.isHidden = true
            p4s.isHidden = true
            print()
        }
        
        if(numberOfPeers == 3)
        {
            p4.isHidden = true
            p4s.isHidden = true
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Reads the json file from a url.
     */
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
        if currentQuestion < questionArray.count - 1 {
            currentQuestion += 1
            DispatchQueue.main.async {
                if !self.questionArray.isEmpty {
                    self.questionLabel.text = (self.questionArray[self.currentQuestion].questionSentence)
                    self.currentQuestionNumberLabel.text = "\(self.questionArray[self.currentQuestion].number)"
                    self.totalQuestionLabel.text = "\(self.totalQuestions)"
        
                    self.ans_A.text = self.questionArray[self.currentQuestion].options["A"] as? String
                    self.ans_A.backgroundColor = UIColor.lightGray
                    self.ans_B.text = self.questionArray[self.currentQuestion].options["B"] as? String
                    self.ans_B.backgroundColor = UIColor.lightGray
                    self.ans_C.text = self.questionArray[self.currentQuestion].options["C"] as? String
                    self.ans_C.backgroundColor = UIColor.lightGray
                    self.ans_D.text = self.questionArray[self.currentQuestion].options["D"] as? String
                    self.ans_D.backgroundColor = UIColor.lightGray
                }else{
                    print("No questions available")
                }
            }
        }
    }
    
    /*Selected answer label turns blue.
 */
     
     
    @objc func selectAnswerTap(sender: UITapGestureRecognizer){
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
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        var shakeCounter:Int = 0
        if (event?.subtype == UIEventSubtype.motionShake)
        {
            if(shakeCounter == 0)
            {
            let random = Int(arc4random_uniform(4))
            self.labels[random].backgroundColor = UIColor.blue
            shakeCounter = shakeCounter + 1

            
            if (random == 0)
            {
                self.labels[1].backgroundColor = UIColor.lightGray
                self.labels[2].backgroundColor = UIColor.lightGray
                self.labels[3].backgroundColor = UIColor.lightGray
            }
            
            if (random == 1)
            {
                self.labels[0].backgroundColor = UIColor.lightGray
                self.labels[2].backgroundColor = UIColor.lightGray
                self.labels[3].backgroundColor = UIColor.lightGray
            }

            if (random == 2)
            {
                self.labels[0].backgroundColor = UIColor.lightGray
                self.labels[1].backgroundColor = UIColor.lightGray
                self.labels[3].backgroundColor = UIColor.lightGray
            }
            
            if (random == 3)
            {
                self.labels[0].backgroundColor = UIColor.lightGray
                self.labels[2].backgroundColor = UIColor.lightGray
                self.labels[1].backgroundColor = UIColor.lightGray
            }
            }
        }
    }
    
    
    
    var motionManger = CMMotionManager()
    override func viewDidAppear(_ animated: Bool) {
        motionManger.gyroUpdateInterval = 0.25
        motionManger.startGyroUpdates(to: OperationQueue.current!){data,error in
            if let myData = data
            {
                if (myData.rotationRate.x < -1)
                {
                    if(self.labels[2].backgroundColor == UIColor.blue)
                    {
                    self.labels[0].backgroundColor = UIColor.blue
                    self.labels[1].backgroundColor = UIColor.lightGray
                    self.labels[2].backgroundColor = UIColor.lightGray
                    self.labels[3].backgroundColor = UIColor.lightGray
                    }
                    
                    if(self.labels[3].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.blue
                        self.labels[2].backgroundColor = UIColor.lightGray
                        self.labels[3].backgroundColor = UIColor.lightGray
                    }
                }
                
                if (myData.rotationRate.y > 1)
                {
                    if(self.labels[0].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.blue
                        self.labels[2].backgroundColor = UIColor.lightGray
                        self.labels[3].backgroundColor = UIColor.lightGray
                    }
                    
                    if(self.labels[2].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.lightGray
                        self.labels[2].backgroundColor = UIColor.lightGray
                        self.labels[3].backgroundColor = UIColor.blue
                    }
                }
                
                if (myData.rotationRate.x > 1)
                {
                    if(self.labels[0].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.lightGray
                        self.labels[2].backgroundColor = UIColor.blue
                        self.labels[3].backgroundColor = UIColor.lightGray
                    }
                    
                    if(self.labels[1].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.lightGray
                        self.labels[2].backgroundColor = UIColor.lightGray
                        self.labels[3].backgroundColor = UIColor.blue
                    }
                }
                
                if (myData.rotationRate.y < -1)
                {
                    if(self.labels[1].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.blue
                        self.labels[1].backgroundColor = UIColor.lightGray
                        self.labels[2].backgroundColor = UIColor.lightGray
                        self.labels[3].backgroundColor = UIColor.lightGray
                    }
                    
                    if(self.labels[3].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.lightGray
                        self.labels[2].backgroundColor = UIColor.blue
                        self.labels[3].backgroundColor = UIColor.lightGray
                    }
                }
               
                
                
            
               
            }
        }
        
       /* let headingManger = CMMotionManager()
        
        headingManger.magnetometerUpdateInterval = 1
        headingManger.startMagnetometerUpdates(to: OperationQueue.current!) { (data,error) in
            if let mData = data
            {
                mData.magneticField
                print(mData)
            }
        }*/
    }
    
    
    
    
    /**
     * Selected answer is submitted and quiz moves to the next quesiton.
     */
    @objc func submitAnswerTap(sender: UITapGestureRecognizer){
        let selection = sender.view as! UILabel
        print("submitted answer: \(String(describing: selection.text!))")
        for index in 0..<labels.count{
            if labels[index] == selection{
                labels[index].backgroundColor = UIColor.green
            }else{
                labels[index].backgroundColor = UIColor.lightGray
            }
        }
       
//        clockTimer.invalidate()
        if selection.text == questionArray[currentQuestion].correctOption{
            print("Correct!")
        }else{
            print("The correct answer is: \(questionArray[currentQuestion].correctOption)")
        }
        //invalidate timer
        //  check answer
        // continue
        timeSeconds = 21
        updateQuestion()
    }
    
    /**
     * Game timer is updated.
     */
    @objc func updateClock() {
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
    
    /**
     * Question objects
     */
    struct Question {
        let number: Int
        let correctOption : String
        let questionSentence : String
        let options : [String: Any]
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
