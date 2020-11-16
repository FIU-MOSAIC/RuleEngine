//
//  RuleEngine.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/9/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class RuleEngine{
    
    static let sharedInstance = RuleEngine()
    
    
    var mappings:[TriggerActionMapping] = []
    var processors:[Processor] = []
    
    var sourceMetadataList = [String : EventSourceStruct]()
    var actionMetadataList = [String: KoiosActionStruct]()
    
    
    //    //objects for testing purposes
    //    var testTrigger:EventTrigger? = nil
    //    var source:NetworkSource? = nil
    //    var action:SendNotificationAction? = nil
    
    
    //real implementation
    var state:EngineState
    
    
    
    init() {
        
        mappings = Loader.sharedInstance.getAllMappings()
        if mappings.count > 0 {
            self.state = EngineState.initial
        }else{
            self.state = EngineState.none
        }
        loadMetadata()
    }
    
    func loadMetadata(){
        let serviceUrl = Utils.getBaseUrl() + "rules/eventmetadata"
        Alamofire.request(serviceUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value as Any)
                //                print("sources list : \(json)")
                
                
                for item in json.arrayValue{
                    let name = item["name"].stringValue
                    let dataType = DataType.init(rawValue: item["dataType"].stringValue.lowercased())
                    print("source name : \(item["name"].stringValue)")
                    print("data type:\(item["dataType"].stringValue)")
                    //                    print("param count:\(item["params"].arrayValue.count), name:\(item["params"].arrayValue[0])")
                    //                    item["params"].arra
                    var params:[ParameterStruct] = []
                    for param in item["params"].arrayValue{
                        print("param name:\(param["name"])")
                        let paramName = param["name"].stringValue
                        let parent = param["parent"].stringValue
                        let paramDataType = DataType.init(rawValue: param["dataType"].stringValue.lowercased())
                        params.append(ParameterStruct(name: paramName, parent: parent, dataType: paramDataType ?? DataType.none, value: ""))
                    }
                    var attributes:[EventAttributeStruct] = []
                    for attribute in item["attributes"].arrayValue{
                        let attrName = attribute["name"].stringValue
                        let attrSource = attribute["source"].stringValue
                        let attrDataType = DataType.init(rawValue: attribute["dataType"].stringValue.lowercased())
                        attributes.append(EventAttributeStruct(name: attrName, source: attrSource, dataType: attrDataType ?? DataType.none, value: ""))
                    }
                    
                    self.sourceMetadataList[name] = EventSourceStruct(name: name, dataType: dataType ?? DataType.none, attributes: attributes, params: params)
                }
                
                
            case .failure(let error):
                print(error)
            // TODO: show error label - service not available
            }
        }
        
        let actionUrl = Utils.getBaseUrl() + "rules/actionmetadata"
        Alamofire.request(actionUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value as Any)
                //                print("action list : \(json)")
                
                
                for item in json.arrayValue{
                    print("action name : \(item["name"].stringValue)")
                    let name = item["name"].stringValue
                    let isSustained = item["isSustained"].intValue
                    var params:[ParameterStruct] = []
                    for param in item["params"].arrayValue{
                        print("param name:\(param["name"])")
                        let paramName = param["name"].stringValue
                        let parent = param["parent"].stringValue
                        let paramDataType = DataType.init(rawValue: param["dataType"].stringValue.lowercased())
                        params.append(ParameterStruct(name: paramName, parent: parent, dataType: paramDataType ?? DataType.none, value: ""))
                    }
                    self.actionMetadataList[name] = KoiosActionStruct(name: name, isSustained: isSustained, params: params)
                }
                
                
            case .failure(let error):
                print(error)
            // TODO: show error label - service not available
            }
        }
    }
    
    func loadData()->Bool{
        if mappings.count <= 0 {
            self.mappings = Loader.sharedInstance.getAllMappings()
        }
        for mapping in mappings{
            let studyId = mapping.studyId
            let configId = mapping.sensorConfigId
            let mappingId = mapping.mappingId
            
            var processorSources:[BaseSource] = []
            var processorActions:[BaseAction] = []
            //            var processorTrigger:Trigger
            
            let instanceId = "\(studyId)-\(configId)-\(mappingId)"
            if let sourceConfigs = mapping.sources{
                processorSources = sourceGenerator(instanecId: instanceId, sources: sourceConfigs)
            }
            //            processors.append(Processor(sources: nil, trigger: nil, actions: nil))
            
            if let actionConfigs = mapping.actions{
                processorActions = actionGenerator(instanecId: instanceId, actions: actionConfigs)
            }
            
                        print("trigger string: \(mapping.triggerJson)")
            var triggerJson = JSON.init(parseJSON: mapping.triggerJson ?? "")
            let triggerStruct = TriggerStruct.responseFromJSONData(jsonData: triggerJson)
                        print("trigger:[\(triggerStruct.toString())]")
            let expression = "\(triggerStruct.expression)"
            print("expression:\(expression)")
            print("is valid expression:\(isValidExpressionForTreeConstruct(list: expression.components(separatedBy: " ")))")
            
            if let rootNode = constructTree(list: expression.components(separatedBy: " ")){
                print("type:\(rootNode.nodeType)")
                let tree = ContextTree(root: rootNode)
                tree.postOrderTraversal(node: rootNode, data: nil)
                let trigger = ContextTrigger(sources: processorSources, contextTree: tree, actions: processorActions)
                processors.append(Processor(sources: processorSources, trigger: trigger, actions: processorActions))
            }else{
                print("Invalid rule expression...")
            }
            
        }
        return true
    }
    
    
    func start() -> Bool{
        
        //        source = NetworkSource(instanceId: "1-1-1", eventSource: DummyData.getAEventSourceStruct())
        //        action = SendNotificationAction(action: DummyData.getAnActionStruct())
        //        testTrigger = EventTrigger(source: source!, actions: [action!])
        
        self.state = EngineState.active
        for processor in processors {
            processor.start()
        }
        return true
    }
    
    func stop()-> Bool{
        self.state = EngineState.inactive
        for processor in processors{
            processor.stop()
        }
        return true
    }
    
    func restart()->Bool{
        self.stop()
        self.start()
        return true
    }
    
    func reset() -> Bool{
        self.state = EngineState.none
        return true
    }
    
    func sourceGenerator(instanecId:String, sources:String)->[BaseSource]{
        var baseSources:[BaseSource] = []
        for source in sources.components(separatedBy: "|"){
            print("source:\(String(source))")
            //            baseSources.append(sourceParser(sourceStr: String(source)))
            if let baseSource =  sourceParser(instanecId: instanecId, sourceStr: String(source)){
                baseSources.append(baseSource)
            }
        }
        return baseSources
    }
    
    func sourceParser(instanecId:String, sourceStr:String)->BaseSource?{
        let sourceName = sourceStr.components(separatedBy: "[")[0]
        var source = sourceMetadataList[sourceName]
        var params:[String] = []
        if sourceStr.hasSuffix("]") {
            var paramPart = (sourceStr.components(separatedBy: "[")[1])
            paramPart = String(paramPart.prefix(paramPart.count-1))
            params = paramPart.components(separatedBy: ",")
        }
        
        if source != nil {
            for param in params{
                let paramName = param.components(separatedBy: ":")[0]
                let paramValue = param.components(separatedBy: ":")[1]
                for i in 0..<(source?.params.count ?? 0) {
                    if source?.params[i].name == paramName {
                        source?.params[i].value = paramValue
                    }
                }
            }
            print("source info: \(source?.toString())")
            
            return ClassFactory.getSourceClass(instanceId: instanecId, sourceStruct: source!)
        }
        //        return [BaseSource()]
        return nil
    }
    
    func actionGenerator(instanecId:String, actions:String)->[BaseAction]{
        var baseActions:[BaseAction] = []
        for action in actions.components(separatedBy: "|"){
            print("atcion:\(String(action))")
            if let baseAction = actionParser(instanecId: instanecId, actionStr: action) {
                baseActions.append(baseAction)
            }
        }
        return baseActions
    }
    
    func actionParser(instanecId:String, actionStr:String)->BaseAction?{
        let actionName = actionStr.components(separatedBy: "[")[0]
        var action = actionMetadataList[actionName]
        var params:[String] = []
        if actionStr.hasSuffix("]") {
            var paramPart = (actionStr.components(separatedBy: "[")[1])
            paramPart = String(paramPart.prefix(paramPart.count-1))
            params = paramPart.components(separatedBy: ",")
        }
        
        if action != nil {
            for param in params{
                let paramName = param.components(separatedBy: ":")[0]
                let paramValue = param.components(separatedBy: ":")[1]
                for i in 0..<(action?.params.count ?? 0) {
                    if action?.params[i].name == paramName {
                        action?.params[i].value = paramValue
                    }
                }
            }
            //            print("action info: \(action?.toString())")
            
            return ClassFactory.getActionClass(instanceId: instanecId, actionStruct: action!)
        }
        //        return [BaseSource()]
        return nil
    }
    
    
    
    func containsOperator(exp:String)->Bool{
        //<= and >= will be covered by < and >
        if exp.contains("=") || exp.contains("<") || exp.contains(">"){
            return true
        }
        return false
    }
    
    func getConditionOperator(exp:String)->ConditionalOperator{
        if containsOperator(exp: exp) {
            let firstLessThan = exp.firstIndex(of: "<")?.utf16Offset(in: exp)
            let firstGreaterThan = exp.firstIndex(of: ">")?.utf16Offset(in: exp)
            
            if firstLessThan==nil && firstGreaterThan==nil {
                //only =
                return ConditionalOperator.equal
            }else if firstLessThan == nil && firstGreaterThan != nil{
                //> >=
                if exp[(firstGreaterThan ?? -99)+1]=="=" {
                    return ConditionalOperator.greaterThanEqual
                }
                return ConditionalOperator.greaterThan
            }else if firstLessThan != nil && firstGreaterThan == nil{
                //< <=
                if exp[(firstLessThan ?? -99)+1]=="=" {
                    return ConditionalOperator.lessThanEqual
                }
                return ConditionalOperator.lessThan
            }else{
                var minIndex = firstLessThan!<firstGreaterThan! ? firstLessThan : firstGreaterThan
                if minIndex==firstLessThan {
                    if exp[minIndex!+1]=="=" {
                        return ConditionalOperator.lessThanEqual
                    }
                    return ConditionalOperator.lessThan
                }else{
                    if exp[minIndex!+1]=="=" {
                        return ConditionalOperator.greaterThanEqual
                    }
                    return ConditionalOperator.greaterThan
                }
            }
            
        }
        return ConditionalOperator.none
    }
    
    func containsAttributeName(exp:String)->Bool{
        let condOperator = getConditionOperator(exp: exp).rawValue
        let parts = exp.components(separatedBy: condOperator)
        if  parts[0].isEmpty{
            return false
        }
        return true
    }
    
    func containsAttributeValue(exp:String)->Bool{
        let condOperator = getConditionOperator(exp: exp).rawValue
        let parts = exp.components(separatedBy: condOperator)
        print("operator:\(condOperator), parts count:\(parts.count)")
        if  parts.count>1 && !parts[1].isEmpty{
            return true
        }
        return false
    }
    
    func getAttributeName(exp:String)->String{
        let condOperator = getConditionOperator(exp: exp).rawValue
        let parts = exp.components(separatedBy: condOperator)
        if  parts[0].isEmpty{
            return ""
        }
        return parts[0]
    }
    
    func getAttributeValue(exp:String)->String{
        let condOperator = getConditionOperator(exp: exp).rawValue
        let parts = exp.components(separatedBy: condOperator)
        if  parts.count>1 && !parts[1].isEmpty{
            return parts[1]
        }
        return ""
    }
    
    func isValidExpression(exp:String)->Bool{
        print("contains attribute-- \(containsAttributeName(exp: exp))")
        print("contains operator-- \(containsOperator(exp: exp))")
        print("contains value-- \(containsAttributeValue(exp: exp))")
        if containsAttributeName(exp: exp) && containsOperator(exp: exp) && containsAttributeValue(exp: exp) {
            return true
        }
        return false
    }
    
    
    //    private String applyOperation(String op1, String op2, String operator) {
    //        if (op1.equals("exp") && op2.equals("exp") && (operator.equals("and") || operator.equals("or"))) {
    //            return "exp";
    //        }
    //        return null;
    //    }
    
    
    func applyDummyOperation(op1:String, op2:String, logicalOperator:String)->String?{
        //        if isValidExpression(exp: op1) && isValidExpression(exp: op2) {
        //            return "\(op1) \(logicalOperator) \(op2)"
        //        }
        //        return nil
        if op1=="exp" && op2=="exp" && (logicalOperator=="and" || logicalOperator=="or") {
            return "exp"
        }
        return nil
    }
    
    func isValidExpressionForTreeConstruct(list:[String])->Bool{
        var expStack = Stack<String>()
        var opStack = Stack<String>()
        
        for element in list{
            print("current element:\(element)")
            if element=="(" {
                opStack.push("(")
            }else if element=="and" || element=="or"{
                if element=="and" && !opStack.isEmpty && opStack.top=="or" {
                    return false
                }
                
                if element=="or" && !opStack.isEmpty && opStack.top=="and" {
                    return false
                }
                opStack.push(element)
            }else if element==")"{
                while !opStack.isEmpty && opStack.top != "(" {
                    var first = ""
                    var second = ""
                    if !expStack.isEmpty {
                        second = expStack.pop()!
                    }
                    if !expStack.isEmpty {
                        first = expStack.pop()!
                    }
                    var op = ""
                    if !opStack.isEmpty {
                        op = opStack.pop()!
                    }
                    if let value = applyDummyOperation(op1: first, op2: second, logicalOperator: op){
                        expStack.push(value)
                    }else{
                        return false
                    }
                }
                if opStack.isEmpty {
                    return false
                }else{
                    opStack.pop()
                }
            }else{
                if isValidExpression(exp: element) {
                    print("expression entity is valid...")
                    expStack.push("exp")
                }else{
                    print("genjam ache...")
                    return false
                }
            }
        }
        
        while !expStack.isEmpty && !opStack.isEmpty {
            var first = ""
            var second = ""
            if !expStack.isEmpty {
                second = expStack.pop()!
            }
            if !expStack.isEmpty {
                first = expStack.pop()!
            }
            var op = ""
            if  !opStack.isEmpty {
                op = opStack.pop()!
            }
            if let value = applyDummyOperation(op1: first, op2: second, logicalOperator: op){
                expStack.push(value)
            }else{
                return false
            }
        }
        if expStack.count == 1 && opStack.isEmpty {
            return true
        }
        return false
    }
    
    
    func applyLogicalOperation(op1:ContextNode?, op2:ContextNode?, logicalOperator:LogicalNode?)->LogicalNode?{
        
        if op1 != nil && op2 != nil && logicalOperator != nil {
            logicalOperator?.addNode(node: op1!)
            logicalOperator?.addNode(node: op2!)
            return logicalOperator
        }
        return nil
    }
    func constructTree(list:[String])->ContextNode?{
        var expStack = Stack<Any>()
        var opStack = Stack<Any>()
        
        for element in list{
            if element=="(" {
                opStack.push("(")
            }else if element=="and" || element=="or"{
                if element=="and" && !opStack.isEmpty && opStack.top is LogicalNode && (opStack.top as! LogicalNode).logicalOperator == .or {
                    return nil
                }
                
                if element=="or" && !opStack.isEmpty && opStack.top is LogicalNode && (opStack.top as! LogicalNode).logicalOperator == .and {
                    return nil
                }
                opStack.push(LogicalNode(logicalOperator: LogicalOperator.init(rawValue: element) ?? .none))
            }else if element==")"{
                //until "(" is found, but only "(" is pushed as string
                while !opStack.isEmpty && !(opStack.top is String) {
                    var first:ContextNode?
                    var second:ContextNode?
                    if !expStack.isEmpty && expStack.top is ContextNode{
                        second = expStack.pop()! as? ContextNode
                    }
                    if !expStack.isEmpty && expStack.top is ContextNode{
                        first = expStack.pop()! as? ContextNode
                    }
                    var op:LogicalNode?
                    if !opStack.isEmpty && opStack.top is LogicalNode{
                        op = opStack.pop()! as? LogicalNode
                    }
                    if let value = applyLogicalOperation(op1: first, op2: second, logicalOperator: op){
                        expStack.push(value)
                    }else{
                        return nil
                    }
                }
                if opStack.isEmpty {
                    return nil
                }else{
                    opStack.pop()
                }
            }else{
                let attributeName = getAttributeName(exp: element)
                let conditionalOpr = getConditionOperator(exp: element)
                let attrValue = getAttributeValue(exp: element)
                expStack.push(ExpressionNode(attribute: attributeName, dataType: .none, conditionalOperator: conditionalOpr, value: attrValue))
            }
        }
        
        while !expStack.isEmpty && !opStack.isEmpty {
            var first:ContextNode?
            var second:ContextNode?
            if !expStack.isEmpty && expStack.top is ContextNode{
                second = expStack.pop()! as? ContextNode
            }
            if !expStack.isEmpty && expStack.top is ContextNode{
                first = expStack.pop()! as? ContextNode
            }
            var op:LogicalNode?
            if !opStack.isEmpty && opStack.top is LogicalNode{
                op = opStack.pop()! as? LogicalNode
            }
            if let value = applyLogicalOperation(op1: first, op2: second, logicalOperator: op){
                expStack.push(value)
            }else{
                return nil
            }
        }
        if expStack.count == 1 && expStack.top is ContextNode && opStack.isEmpty {
            return (expStack.pop() as! ContextNode)
        }
        return nil
    }
    
}


enum EngineState {
    case initial, active, inactive, none
}


enum ProcessorState{
    case initial, active, inactive, none
}

class Processor{
    let sources:[BaseSource]
    let trigger:Trigger
    let actions:[BaseAction]
    
    init(sources:[BaseSource], trigger:Trigger, actions:[BaseAction]) {
        self.sources = sources
        self.trigger = trigger
        self.actions = actions
    }
    
    func start()->Bool{
        trigger.start()
        return true
    }
    
    func stop()->Bool{
        trigger.stop()
        return true
    }
    
    func restart()->Bool{
        true
    }
}


//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Stack
//source from internet
public struct Stack<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public var top: T? {
        return array.last
    }
    
}
