//
//  QuizViewController.swift
//  Quiz App
//
//  Created by Adrianne Williams on 4/22/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    //the json file url
    let QUIZ_URL = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
    var questionArray = [Question]()
    var totalQuestions = 0
    var currentQuestion = 0

    // UI variables
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var totalQuestionLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel_A: UILabel!
    @IBOutlet weak var answerLabel_B: UILabel!
    @IBOutlet weak var answerLabel_C: UILabel!
    @IBOutlet weak var answerLabel_D: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getJsonFromUrl()
        answerLabel_A.isUserInteractionEnabled = true
        
        answerLabel_B.isUserInteractionEnabled = true
        answerLabel_C.isUserInteractionEnabled = true
        answerLabel_D.isUserInteractionEnabled = true
        
        //add tap gesture to answer labels
            // single tap selects answer
            // double tap submits answer if one is selected
        
        //selected answer variable
        
        // need way to determine when all players have submited answer
            // when all players submit answer move to next question
        
        // add timer to the screen
            // every 20 seconds move to the next question (restart timer)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            print("total questions = \(self.totalQuestions)")
            print(dictionary)
            self.updateQuestion()
        } catch let error as NSError {
            print(error)
        }
    }).resume()
    }
    
    func parseDictionary(dictionary : [[String: Any]]){
        // for each element in dictionary create a question
        
        for question in dictionary{
            let newQuestion = Question(number: question["number"] as! Int, correctOption: question["correctOption"] as! String, questionSentence: question["questionSentence"] as! String, options: question["options"] as! [String: Any])
            questionArray.append(newQuestion)
        }
        
    }
     struct Question {
        let number: Int
        let correctOption : String
        let questionSentence : String
        let options : [String: Any]
     }
    
    func updateQuestion(){
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
