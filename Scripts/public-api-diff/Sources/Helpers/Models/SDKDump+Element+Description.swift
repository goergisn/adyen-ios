//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

import Foundation

extension SDKDump.Element {
    
    var description: String {
        var components = [String]()
        spiGroupNames?.forEach {
            components += ["@_spi(\($0))"]
        }
        
        if hasDiscardableResult {
            components += ["@discardableResult"]
        }
        
        if declKind != .import {
            components += [isInternal ? "internal" : "public"]
        }
        
        if isFinal, declKind == .class {
            components += ["final"]
        }
        
        if isStatic {
            components += ["static"]
        }
        
        if let declKind {
            if declKind == .constructor {
                components += ["func"]
            } else if declKind == .case {
                components += ["case"]
            } else if declKind == .var, isLet {
                components += ["let"]
            } else {
                components += ["\(declKind.rawValue.lowercased())"]
            }
        }
        
        components += [verboseName]
        
        if let conformanceNames = conformances?.sorted().map(\.printedName), !conformanceNames.isEmpty {
            components += [": \(conformanceNames.joined(separator: ", "))"]
        }
        
        if let accessors = accessors?.map({ $0.name.lowercased() }), !accessors.isEmpty {
            components += ["{ \(accessors.joined(separator: " ")) }"]
        }
        
        return components.joined(separator: " ")
    }
    
    var verboseName: String {
        
        guard let declKind else {
            return printedName
        }
        
        switch declKind {
        case .import:
            return printedName
        case .class:
            return printedName
        case .struct:
            return printedName
        case .enum:
            return printedName
        case .case:
            return verboseNameForCase()
        case .var:
            return verboseNameForVar()
        case .protocol:
            return printedName
        case .constructor, .func:
            return SDKDump.FunctionDescription(underlyingElement: self)?.description ?? printedName
        case .accessor:
            return printedName
        case .typeAlias:
            return verboseNameForTypeAlias()
        case .subscriptDeclaration:
            return printedName
        case .associatedType:
            return printedName
        case .macro:
            return printedName
        }
    }
}

private extension SDKDump.Element {
    
    /// Verbose name for `typealias`
    ///
    /// - Adds alias asignment information
    func verboseNameForTypeAlias() -> String {
        guard let alias = children.first?.verboseName else {
            return printedName
        }
        
        return "\(printedName) = \(alias)"
    }
    
    /// Verbose name for `var`
    ///
    /// - Adds return type information
    func verboseNameForVar() -> String {
        guard let returnValue = children.first?.printedName else {
            return printedName
        }
        
        return "\(printedName): \(returnValue)"
    }
    
    /// Verbose name for `case`
    ///
    /// - Adds typing information for associated value
    func verboseNameForCase() -> String {
        guard let firstChild = children.first else {
            return printedName
        }
        
        guard let nestedFirstChild = firstChild.children.first else {
            return printedName // Return type (enum type)
        }
        
        guard nestedFirstChild.children.count == 2, let associatedValue = nestedFirstChild.children.last else { 
            return printedName // No associated value
        }
        
        return printedName + associatedValue.printedName
    }
}