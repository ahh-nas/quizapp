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
import Darwin

class QuizViewController: UIViewController, UIGestureRecognizerDelegate, MCSessionDelegate {
    
    //the json file url
    var QUIZ_URL = ["http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json","http://www.people.vcu.edu/~ebulut/jsonFiles/quiz2.json"]
    var questionArray = [Question]()
    var totalQuestions = 0
    var currentQuestion = -1
    var timeSeconds = 20
    var session : MCSession!
    var peerID : MCPeerID!
    var labels = [UILabel]()
    var scores = [UILabel]()
    var answers = [UILabel]()
    var clockTimer = Timer()
    var numOfSubmissions = 0
    var selectedAnswer = ""
    var submittedAnswer = ""
    var score = 0
    var numberOfPeers = 0
    var i = 0
    
   
    // UI variables
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var totalQuestionLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
   
    @IBOutlet weak var ans_A: UILabel!
    @IBOutlet weak var ans_B: UILabel!
    @IBOutlet weak var ans_C: UILabel!
    @IBOutlet weak var ans_D: UILabel!
    
    //Player images
    @IBOutlet weak var p1: UIImageView!
    @IBOutlet weak var p2: UIImageView!
    @IBOutlet weak var p3: UIImageView!
    @IBOutlet weak var p4: UIImageView!
    
    //Player score labels
    @IBOutlet weak var p1s: UILabel!
    @IBOutlet weak var p2s: UILabel!
    @IBOutlet weak var p3s: UILabel!
    @IBOutlet weak var p4s: UILabel!
    
    //player answer submission labels
    @IBOutlet weak var p1a: UILabel!
    @IBOutlet weak var p2a: UILabel!
    @IBOutlet weak var p3a: UILabel!
    @IBOutlet weak var p4a: UILabel!
    
    @IBOutlet weak var playerWinStatus: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        session.delegate = self
        labels = [ans_A, ans_B, ans_C, ans_D]
        scores = [p1s, p2s, p3s, p4s]
        answers = [p1a, p2a, p3a, p4a]
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
        
        if(numberOfPeers == 2)
        {
            p3.isHidden = true
            p4.isHidden = true
            p3s.isHidden = true
            p4s.isHidden = true
            p3a.isHidden = true
            p4a.isHidden = true
            //print()
        }
        
        if(numberOfPeers == 3)
        {
            p4.isHidden = true
            p4s.isHidden = true
            p4a.isHidden = true
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
        var url = URL(string: QUIZ_URL[0])
        if (i == 0)
        {
            url = URL(string: QUIZ_URL[0])
        }
        if (i == 1)
        {
            url = URL(string: QUIZ_URL[1])
        }
        if (i == 2)
        {
            i = 0
        }
       
        
       
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
        selectedAnswer = String(describing: selection.text!.first!).trimmingCharacters(in: .whitespaces)
        print("selected answer 1: \(selectedAnswer)")
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
            self.selectedAnswer = String(describing: labels[random].text?.first!).trimmingCharacters(in: .whitespaces)
                print("select ans 2: \(self.selectedAnswer)")
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
                        self.selectedAnswer = "A"
                        print("TURNED xA \(self.selectedAnswer)")
                    }
                    
                    if(self.labels[3].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.blue
                        self.labels[2].backgroundColor = UIColor.lightGray
                        self.labels[3].backgroundColor = UIColor.lightGray
                        self.selectedAnswer = "B"

                        print("TURNED yB \(self.selectedAnswer)")
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
                        self.selectedAnswer = "B"

                        print("TURNED yB \(self.selectedAnswer)")
                    }
                    
                    if(self.labels[2].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.lightGray
                        self.labels[2].backgroundColor = UIColor.lightGray
                        self.labels[3].backgroundColor = UIColor.blue
                        self.selectedAnswer = "D"

                        print("TURNED yD \(self.selectedAnswer)")
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
                        self.selectedAnswer = "C"

                        print("TURNED -xA \(self.selectedAnswer)")
                    }
                    
                    if(self.labels[1].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.lightGray
                        self.labels[2].backgroundColor = UIColor.lightGray
                        self.labels[3].backgroundColor = UIColor.blue
                        self.selectedAnswer = "D"

                        print("TURNED -xB \(self.selectedAnswer)")
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
                        self.submittedAnswer = "D"
                        print("TURNED -yB \(self.selectedAnswer)")
                        
                    }
                    
                    if(self.labels[3].backgroundColor == UIColor.blue)
                    {
                        self.labels[0].backgroundColor = UIColor.lightGray
                        self.labels[1].backgroundColor = UIColor.lightGray
                        self.labels[2].backgroundColor = UIColor.blue
                        self.labels[3].backgroundColor = UIColor.lightGray
                        self.selectedAnswer = "C"

                        print("TURNED -yD \(self.selectedAnswer)")
                    }
                }
                self.motionManger.accelerometerUpdateInterval = 0.25
                self.motionManger.startAccelerometerUpdates(to: OperationQueue.current!){(data,error)in
                 if let myAData = data{
                    if (myData.rotationRate.z > 3 || myData.rotationRate.z < -3 || myAData.acceleration.z > -0.5)
                {
                    self.submittedAnswer = self.selectedAnswer
                    print("submitted answer cmotion 3: \(self.submittedAnswer)")
                    for index in 0..<self.labels.count
                    {
                        if String(describing: self.labels[index].text?.first!).trimmingCharacters(in: CharacterSet.whitespaces) == self.submittedAnswer {
                            self.labels[index].backgroundColor = UIColor.green
                        }
                        else{
                            self.labels[index].backgroundColor = UIColor.lightGray
                        }
                    }
                    
                    let msg = "submit"
                    let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: msg)
                    do
                    {
                        self.numOfSubmissions += 1
                        try self.session.send(dataToSend, toPeers: self.session.connectedPeers, with: .reliable)
                        for index in 0..<self.labels.count{
                            self.labels[index].isUserInteractionEnabled = false
                        }
                    }
                    catch let err {
                        print("Error in sending data \(err)")
                    }
                }
                }
            }
                
            }
        }
    }
   
    
    
    /**
     * Selected answer is submitted and quiz moves to the next question.
     */
    
    @objc func submitAnswerTap(sender: UITapGestureRecognizer){
        let selection = sender.view as! UILabel
        submittedAnswer = String(selection.text!.first!).trimmingCharacters(in: CharacterSet.whitespaces)


        print("submitted answer tap 4: \(submittedAnswer)")
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
             for index in 0..<labels.count{
                labels[index].isUserInteractionEnabled = false
            }
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
            }else{                      // update the question when timer reaches 0
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
    
    func calculateScore(){
        self.score += 1
        self.scores[0].text = "\(score)"
       
        // send score to other players
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: self.score)
        do{
            try session.send(dataToSend, toPeers: session.connectedPeers, with: .reliable)
        }
        catch let err {
            print("Error in sending data \(err)")
        }
    }
    
    func showAnswer(){
        self.answers[0].text = "\(submittedAnswer)"
        // send score to other players
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: submittedAnswer)
        do{
            try session.send(dataToSend, toPeers: session.connectedPeers, with: .reliable)
        }
        catch let err {
            print("Error in sending data \(err)")
        }
    }
    
    
    func showWinner(){
        let maxscore = Int((scores.max{a, b in Int(a.text!)! < Int(b.text!)!}?.text!)!)!
        if Int(p1s.text!)! == maxscore {
            self.playerWinStatus.image = #imageLiteral(resourceName: "winner")
        }else{
             self.playerWinStatus.image = #imageLiteral(resourceName: "you_lose")
        }

    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async(execute: {
            if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String{
                if receivedString == "submit" && peerID != self.peerID {
                    //print("other")
                    self.numOfSubmissions += 1
                }
                if receivedString == "next" && peerID != self.peerID {
                    
                    UIView.animate(withDuration: 3, animations: {
                        if self.submittedAnswer == self.questionArray[self.currentQuestion].correctOption{
                            self.timerLabel.text = "Correct!"
                            self.calculateScore()
                            self.showAnswer()
                            
                        }else{
                           self.timerLabel.text = "Answer was: \(self.questionArray[self.currentQuestion].correctOption)"
                        }
                        //calculate & update score
                    }, completion: {(finished: Bool) in
                        if !(self.isLastQuestion()) {
                            
                            self.updateQuestion()
                        }else{
                            self.showWinner()
                             self.timeSeconds = 1
                            self.createAlert(title: "Having Fun?", message: "Would you like to play another game?")
                        }
                    })
                }
                 if receivedString == "A" || receivedString == "B" || receivedString == "C" || receivedString == "D" {
                    for index in 0..<self.session.connectedPeers.count{
                        if peerID == self.session.connectedPeers[index]{
                            self.answers[index + 1].text = "\(self.submittedAnswer)"
                        }
                    }

                }
            }
            
            if let receivedInt = NSKeyedUnarchiver.unarchiveObject(with: data) as? Int{
                for index in 0..<self.session.connectedPeers.count{
                    if peerID == self.session.connectedPeers[index]{
                        self.scores[index + 1].text = "\(receivedInt)"
                    }
                }
            }
        })
    }
    
    func createAlert (title:String, message:String)
    {
        let alert = UIAlertController(title:title,message:message,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Yes",style: UIAlertActionStyle.default, handler:{(action)in alert.dismiss(animated : true,completion : nil)
            self.i = self.i + 1
            self.viewDidLoad()
        }))
        alert.addAction(UIAlertAction(title:"No",style: UIAlertActionStyle.default, handler:{(action)in alert.dismiss(animated : true,completion : nil)
            exit(0)
        }))
        self.present(alert,animated: true, completion: nil)
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
