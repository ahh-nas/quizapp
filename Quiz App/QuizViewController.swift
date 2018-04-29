//
//  QuizViewController.swift
//  Quiz App
//
//  Created by Adrianne Williams on 4/22/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //the json file url
    let QUIZ_URL = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
    var questionArray = [Question]()
    var totalQuestions = 0
    var currentQuestion = -1
    var timeSeconds = 20
    var labels = [UILabel]()
    var clockTimer = Timer()
   
    // UI variables
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var totalQuestionLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
   
    @IBOutlet weak var ans_A: UILabel!
    @IBOutlet weak var ans_B: UILabel!
    @IBOutlet weak var ans_C: UILabel!
    @IBOutlet weak var ans_D: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        labels = [ans_A, ans_B, ans_C, ans_D]
        timerLabel.text = "\(timeSeconds)"
        for index in 0..<labels.count{
            let selectTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.selectAnswerTap(sender:)))
            let submitTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.submitAnswerTap(sender:)))
            selectTapGesture.numberOfTapsRequired = 1
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
    
    /**
     * Selected answer label turns blue.
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
//        if selection.text == questionArray[currentQuestion].correctOption{
//            print("Correct!")
//        }else{
//            print("The correct answer is: \(questionArray[currentQuestion].correctOption)")
//        }
        //invalidate timer
        //  check answer
        // continue
        timeSeconds = 21
        updateQuestion()
    }
    
    //session.connectedpeers>4 error message
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
