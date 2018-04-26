//
//  ViewController.swift
//  Quiz App
//
//  Created by The Dreadnought on 4/22/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var session: MCSession!
    var peerID: MCPeerID!
    var toggleValue:Int = 0
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.browser = MCBrowserViewController(serviceType: "chat", session: session)
        self.assistant = MCAdvertiserAssistant(serviceType: "chat", discoveryInfo: nil, session: session)
        
        assistant.start()
        session.delegate = self
        browser.delegate = self
        
    }
    
    func createAlert (title:String, message:String)
    {
        let alert = UIAlertController(title:title,message:message,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.default, handler:{(action)in alert.dismiss(animated : true,completion : nil)}))
        self.present(alert,animated: true, completion: nil)
    }

    
    @IBAction func toggle(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0)
        {toggleValue=0}
        if (sender.selectedSegmentIndex == 1)
        {toggleValue=1}
    }
    

    @IBAction func pressedStart(_ sender: Any)
    {   if(toggleValue == 1)
        {
            if (session.connectedPeers.count+1>4){
                createAlert(title: "Sorry", message: "Too many players have connected, the max number of players is 4")
            }
        
            if (session.connectedPeers.count+1<2){
                createAlert(title: "Sorry", message: "Not enough players have connected, the minimum number of players is 2")
            
            }
        
            if (session.connectedPeers.count+1>=2 && session.connectedPeers.count<=4)
                {
                let quizStoryboard = UIStoryboard(name: "QuizView", bundle: .main)
                if let quizVC = quizStoryboard.instantiateViewController(withIdentifier: "QuizView") as? QuizViewController {
                self.present(quizVC, animated: true, completion: nil)
                    }
                }
        }
        
        if(toggleValue == 0)
        {
            createAlert(title: "single player", message: "needs to be implemented")
           //add new screen for single player
        }
    }
    
    
    
    
   
    @IBAction func connect(_ sender: UIButton) {
    
        present(browser, animated: true, completion: nil)
        
    }
    
    
 
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
   
        dismiss(animated: true, completion: nil)
    }
   
    
    
    
    

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        print("inside didReceiveData")
        

        DispatchQueue.main.async(execute: {
            
            if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String{
                //self.updateChatView(newText: receivedString, id: peerID)
            }
            
            if let image = UIImage(data: data) {
                
                //self.imgView.image = image
                
                //self.updateChatView(newText: "received image", id: peerID)
                
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
    //**********************************************************
    
    
    
    
}

