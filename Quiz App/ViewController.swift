//
//  ViewController.swift
//  Quiz App
//
//  Created by The Dreadnought on 4/22/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController{
    
    let gameService = ConnectionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedStart(_ sender: UIButton) {
        let quizStoryboard = UIStoryboard(name: "QuizView", bundle: .main)
        if let quizVC = quizStoryboard.instantiateViewController(withIdentifier: "QuizView") as? QuizViewController {
            self.present(quizVC, animated: true, completion: nil)
        }
    }
}

