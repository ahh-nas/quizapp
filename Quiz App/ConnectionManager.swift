//
//  ConnectionManager.swift
//  Quiz App
//
//  Created by Adrianne Williams on 4/22/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectionManager : NSObject
{
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
            session.delegate = self
            return session
    }()
    
    
    
    private let gameServiceType = "quiz-app"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)      //displays name of device to peers
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    override init()
    {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: gameServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: gameServiceType)
        super.init()
       
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
       
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
      
    }
    
    deinit
    {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}
    extension ConnectionManager : MCNearbyServiceAdvertiserDelegate
    {
        
        func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
            NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
        }
        
        func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
            NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
            invitationHandler(true, self.session)
        }
        
    }

    extension ConnectionManager : MCNearbyServiceBrowserDelegate
    {
    
        func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
        }
    
        func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    
        func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        }
    }
    
    extension ConnectionManager : MCSessionDelegate {
            
        func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
          NSLog("%@", "peer \(peerID) didChangeState: \(state)")
            }
            
        func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            NSLog("%@", "didReceiveData: \(data)")
            }
            
        func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
            NSLog("%@", "didReceiveStream")
            }
            
        func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
            NSLog("%@", "didStartReceivingResourceWithName")
            }
            
        func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
            NSLog("%@", "didFinishReceivingResourceWithName")
            }
            
        }
    



