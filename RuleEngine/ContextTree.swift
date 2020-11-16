//
//  ContextTree.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 11/9/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation


enum NodeType:String{
    case logical, expression, none
}

enum LogicalOperator:String{
    case and, or, none
}

enum ConditionalOperator:String {
    case equal="=", lessThan="<", greaterThan=">", lessThanEqual="<=", greaterThanEqual=">=", none
}

protocol ContextNode {
    var nodeType:NodeType{get}
    var state:Bool{get}
    
}

class LogicalNode: ContextNode {
    var nodeType: NodeType
    var state: Bool
    
    var nodes:[ContextNode]
    var logicalOperator:LogicalOperator
    
    init(logicalOperator:LogicalOperator) {
        nodeType = NodeType.logical
        state = false
        self.logicalOperator = logicalOperator
        self.nodes = []
    }
    
    func addNode(node:ContextNode){
        self.nodes.append(node)
    }
    
    func getNodes()->[ContextNode]{
        return self.nodes
    }
}

class ExpressionNode:ContextNode{
    var nodeType: NodeType
    var state: Bool
    
    var attribute:String
    var dataType:DataType
    var conditionalOperator:ConditionalOperator
    var value:String
    
    init(attribute:String, dataType:DataType, conditionalOperator:ConditionalOperator, value:String) {
        nodeType = .expression
        state = false
        
        self.attribute = attribute
        self.dataType = dataType
        self.conditionalOperator = conditionalOperator
        self.value = value
    }
    
}

class ContextTree{
    var root:ContextNode?
    
    init(root:ContextNode) {
        self.root = root
    }
    
    func postOrderTraversal(node:ContextNode?, data:EventData?){
        if node == nil{
            return
        }
        
        if node is ExpressionNode {
            let currNode = node as! ExpressionNode
            print("desc:\(currNode.attribute), \(currNode.conditionalOperator.rawValue), \(currNode.value)")
            if data != nil {
                let attribute = currNode.attribute
                if let attributeValue = data?.values[attribute]{
                    print("matched attribute data in the event, value :\(attributeValue)")
                    if currNode.conditionalOperator == ConditionalOperator.equal {
                        currNode.state = (attributeValue as! String == currNode.value)
                    }else if currNode.conditionalOperator == ConditionalOperator.greaterThan{
                        currNode.state = (Double(attributeValue as! String)! > Double(currNode.value)!)
                    }else if currNode.conditionalOperator == ConditionalOperator.greaterThanEqual{
                        currNode.state = (Double(attributeValue as! String)! >= Double(currNode.value)!)
                    }else if currNode.conditionalOperator == ConditionalOperator.lessThan{
                        currNode.state = (Double(attributeValue as! String)! < Double(currNode.value)!)
                    }else if currNode.conditionalOperator == ConditionalOperator.lessThanEqual{
                        currNode.state = (Double(attributeValue as! String)! <= Double(currNode.value)!)
                    }
                }
            }
            return
        }
        
        if node is LogicalNode {
            let currNode = node as! LogicalNode
            if currNode.getNodes().count==2 {
                postOrderTraversal(node: currNode.getNodes()[0], data: data)
                postOrderTraversal(node: currNode.getNodes()[1], data: data)
                print("logical node:\(currNode.logicalOperator.rawValue)")
                if currNode.logicalOperator == LogicalOperator.and {
                    currNode.state = currNode.getNodes()[0].state && currNode.getNodes()[1].state
                }else if currNode.logicalOperator == LogicalOperator.or{
                    currNode.state = currNode.getNodes()[0].state || currNode.getNodes()[1].state
                }else{
                    print("Must be a problem to construct the tree")
                }
            }else{
                print("Must be a problem to construct")
            }
        }
    }
    
    func updateTreeState(data:EventData){
        postOrderTraversal(node: self.root, data: data)
    }
    
    func currentState()->Bool{
        return root?.state ?? false
    }
    
}
