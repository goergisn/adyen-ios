//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 01/08/2024.
//

import Foundation

extension SDKDump {
    
    struct FunctionDescription: CustomStringConvertible {
        
        private let underlyingElement: SDKDump.Element
        
        init?(underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .func || underlyingElement.declKind == .constructor else {
                return nil
            }
            
            self.underlyingElement = underlyingElement
        }
        
        public var functionName: String {
            underlyingElement.printedName.components(separatedBy: "(").first ?? ""
        }
        
        public var arguments: [Argument] {
            var sanitizedArguments = underlyingElement.printedName
            sanitizedArguments.removeFirst(functionName.count)
            sanitizedArguments.removeFirst() // `(`
            if sanitizedArguments.hasSuffix(":)") {
                sanitizedArguments.removeLast(2) // `:)`
            } else {
                sanitizedArguments.removeLast() // `)`
            }
            
            if sanitizedArguments.isEmpty { return [] }
            
            let funcComponents = sanitizedArguments.components(separatedBy: ":")
            
            let argumentTypes = Array(underlyingElement.children.suffix(from: 1)) // First element is the return type
            
            return funcComponents.enumerated().map { index, component in
                
                guard index < argumentTypes.count else {
                    return .init(
                        name: component,
                        type: "UNKNOWN_TYPE",
                        defaultArgument: nil
                    )
                }
                
                let type = argumentTypes[index]
                return .init(
                    name: component,
                    type: type.verboseName,
                    defaultArgument: type.hasDefaultArg ? "$DEFAULT_ARG" : nil
                )
            }
        }
        
        public var returnType: String? {
            guard let returnType = underlyingElement.children.first?.printedName else { return nil }
            return returnType == "()" ? "Swift.Void" : returnType
        }
        
        public var description: String {
            guard let returnType else {
                // Return type is optional as enum is using it as well (Figure out what the use is there)
                return underlyingElement.printedName
            }
            
            // TODO: Better allow passing of a formatting option to do multi line formatting
            let argumentList = arguments
                .map({ "    \($0.description)"})
                .joined(separator: ",\n")
            
            let components: [String?] = [
                "\(functionName)(\n\(argumentList)\n)",
                underlyingElement.isThrowing ? "throws" : nil,
                "->",
                returnType
            ]
            
            return components
                .compactMap { $0 }
                .joined(separator: " ")
        }
    }
}

extension SDKDump.FunctionDescription {
    
    public struct Argument: Equatable, CustomStringConvertible {
        let name: String
        let type: String
        let defaultArgument: String?
        
        public var description: String {
            let nameAndType = "\(name): \(type)"
            if let defaultArgument {
                return "\(nameAndType) = \(defaultArgument)"
            }
            return nameAndType
        }
    }
}