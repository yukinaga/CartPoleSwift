//
//  Agent.swift
//  CertPole
//
//  Created by Yukinaga2 on 2018/08/16.
//  Copyright © 2018年 Yukinaga Azuma. All rights reserved.
//

import UIKit

class Agent {
    
    var qTable = [[CGFloat]]()

    let digitizeNumber = 12
    let eta = CGFloat(0.3)
    let gamma = CGFloat(0.99)
    
    let limit = ["pole_angle":CGFloat.pi/4, "pole_speed":CGFloat(1.2)]
    var currentState = ["pole_angle":CGFloat(0), "pole_speed":CGFloat(0)]
    var action = 0
    
    init() {
        for _ in (0 ..< digitizeNumber*digitizeNumber) {
            let rand_left = CGFloat(arc4random_uniform(101))/100.0
            let rand_right = CGFloat(arc4random_uniform(101))/100.0
            qTable.append([rand_left, rand_right])
        }
    }
    
    func digitizeState(state:[String:CGFloat]) -> Int{
        var digitizedState = [String:Int]()
        for (key, _) in state {
            var dig = Int((state[key]!-(-limit[key]!)) / (2*limit[key]!/CGFloat(digitizeNumber)))
            if dig < 0 {
                dig = 0
            }else if dig >= digitizeNumber {
                dig = digitizeNumber-1
            }
            digitizedState[key] = dig
        }

        var dState = 0
        dState += digitizedState["pole_angle"]!*digitizeNumber
        dState += digitizedState["pole_speed"]!
        return dState
    }
    
    func getAction(c_state:[String:CGFloat], episode:Int) -> Int{
        currentState = c_state
        let dState = digitizeState(state: currentState)
        let epsilon = 0.5*(1.0/(CGFloat(episode)+1.0))
        
        if epsilon <= CGFloat(arc4random_uniform(1001))/1000.0 {
            action = qTable[dState][0] > qTable[dState][1] ? 0 : 1
        }else{
            action = arc4random_uniform(2)==0 ? 0 : 1
        }
        
        return action
    }
    
    func updateQTable(reward:CGFloat, nextState:[String:CGFloat]){
        let cDigState = digitizeState(state: currentState)
        let nDigState = digitizeState(state: nextState)
        let maxQNext = qTable[nDigState].max()!
        
        qTable[cDigState][action] += eta * (reward + gamma*maxQNext - qTable[cDigState][action])
    }
}
