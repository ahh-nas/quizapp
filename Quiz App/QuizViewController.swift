//
//  QuizViewController.swift
//  Quiz App
//
//  Created by Adrianne Williams on 4/22/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit
import CoreMotion
import MultipeerConnectivity

class QuizViewController: UIViewController, UIGestureRecognizerDelegate, MCSessionDelegate {
    
    //the json file url
    var QUIZ_URL = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
    var questionArray = [Question]()
    var totalQuestions = 0
    var currentQuestion = -1
    var timeSeconds = 20
    var session : MCSession!
    var peerID : MCPeerID!
    var labels = [UILabel]()
    var clockTimer = Timer()
    var numOfSubmissions = 0
    var submittedAnswer = ""
    var score = 0
   
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
        
        session.delegate = self
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
        timeSeconds = 21
        if currentQuestion < questionArray.count - 1 {
            currentQuestion += 1
            DispatchQueue.main.async {
                if !self.questionArray.isEmpty {
                    self.questionLabel.text = (self.questionArray[self.currentQuestion].questionSentence)
                    self.currentQuestionNumberLabel.text = "\(self.questionArray[self.currentQuestion].number)"
                    self.totalQuestionLabel.text = "\(self.totalQuestions)"
        
                    self.ans_A.text = "A: \(String(describing: self.questionArray[self.currentQuestion].options["A"] as! String))"
                    self.ans_A.backgroundColor = UIColor.lightGray
                    self.ans_B.text = "B: \(String(describing: self.questionArray[self.currentQuestion].options["B"] as! String))"
                    self.ans_B.backgroundColor = UIColor.lightGray
                    self.ans_C.text = "C: \(String(describing: self.questionArray[self.currentQuestion].options["C"] as! String))"
                    self.ans_C.backgroundColor = UIColor.lightGray
                    self.ans_D.text = "D: \(String(describing: self.questionArray[self.currentQuestion].options["D"] as! String))"
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
   
    
    
    /**
     * Selected answer is submitted and quiz moves to the next question.
     */
    @objc func submitAnswerTap(sender: UITapGestureRecognizer){
        let selection = sender.view as! UILabel
        submittedAnswer = selection.text!
        print("submitted answer: \(submittedAnswer)")
        for index in 0..<labels.count{
            if labels[index] == selection{
                labels[index].backgroundColor = UIColor.green
            }else{
                labels[index].backgroundColor = UIColor.lightGray
            }
        }

        let msg = "submit"
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: msg)
        do{
            self.numOfSubmissions += 1
            try session.send(dataToSend, toPeers: session.connectedPeers, with: .reliable)
        }
        catch let err {
            print("Error in sending data \(err)")
        }
        
    }
    
    /**
     * Game timer and questions are updated.
     */
    @objc func updateClock() {
        if timeSeconds > 0 {            // update the timer each second
            timeSeconds -= 1
            timerLabel.text = "\(timeSeconds)"
        }else{
            if isLastQuestion() {       // at the last question & timer reaches 0
                clockTimer.invalidate()
            }else{                      // update the question
               // timeSeconds = 21
                updateQuestion()
            }
        }
        
        // if all players have submitted, update the question
        if numOfSubmissions == session.connectedPeers.count + 1 {
            self.numOfSubmissions = 0
            
            let msg = "next"
            let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: msg)
            do {
                try session.send(dataToSend, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let err {
                print("Error in sending data \(err)")
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
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async(execute: {
            if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String{
                if receivedString == "submit" && peerID != self.peerID {
                    print("other")
                    self.numOfSubmissions += 1
                }
                if receivedString == "next" && peerID != self.peerID{
                    print("other update")
                    if !(self.isLastQuestion()) { // if not the last question
                        // show correct answer
                        UIView.animate(withDuration: 3, animations: {
                            if self.submittedAnswer == self.questionArray[self.currentQuestion].correctOption{
                                self.timerLabel.text = "Correct!"
                            }else{
                               self.timerLabel.text = "Answer is: \(self.questionArray[self.currentQuestion].correctOption)"
                            }
                        }, completion: nil)
                        self.updateQuestion()
                    }else{
                        UIView.animate(withDuration: 3, animations: {
                            if self.submittedAnswer == self.questionArray[self.currentQuestion].correctOption{
                                self.timerLabel.text = "Correct"
                            }else{
                                self.timerLabel.text = "Correct answer is: \(self.questionArray[self.currentQuestion].correctOption)"
                            }
                        }, completion: nil)
                        self.clockTimer.invalidate()
                    }
                }
            }
        })
    }
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Called when a connected peer changes state (for example, goes offline)
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func isLastQuestion()-> Bool{
        if currentQuestion == questionArray.count - 1 {
            return true
        }
        return false
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
