//
//  CodeGenerator.swift
//  ColorListGenerator
//
//  Created by griffin-stewie on 2015/05/18.
//  Copyright (c) 2015 net.cyan-stivy. All rights reserved.
//

import Foundation

enum Code: String {
    case Swift = "swift"
    case ObjC = "objc"
    case Android = "android"

    func generateCode(_ colors: [Color], directory: String) {
        switch self {
        case .Swift:
            func classFunc(_ color: Color) -> String {

                let methodName: String
                if let cName = color.name {
                    methodName = cName.camelCase().sanitizeAsMethodName() + "()"
                } else {
                    methodName = "cName" + "()"
                }

                let code = "    class func \(methodName) -> UIColor {\n" +
                    "        return UIColor(red: \(Double(color.color!.redComponent)), green: \(Double(color.color!.greenComponent)), blue: \(Double(color.color!.blueComponent)), alpha: \(Double(color.color!.alphaComponent)))\n" +
                "    }\n\n"
                return code
            }

            func generateSwiftFile(_ colors: [Color], directory: String) {
                var code = "import UIKit"
                         + "\n"
                         + "\n"
                         + "extension UIColor {"
                         + "\n"
                for c in colors {
                    code += classFunc(c)
                }

                code += "}"

                var e: NSError? = nil

                if let path = URL(fileURLWithPath: directory.appending(pathComponent: "AppColors.swift").standardizingPath()).path as? String {
                    let result: Bool
                    do {
                        try code.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                        result = true
                    } catch let error as NSError {
                        e = error
                        result = false
                    }
                    if result {
                        CSNPrintStandardOutput("SUCCESS: saved to \(path)")
                    }
                    #if DEBUG
                        print(e)
                        print(result)
                    #endif
                } else {
                    CSNPrintStandardOutput("FAILED: failed to save swift extension file")
                }
            }

            generateSwiftFile(colors, directory: directory)

        case .ObjC:
            func classMethodInterface(_ color: Color) -> String {

                let methodName: String
                if let cName = color.name {
                    methodName = cName.camelCase().sanitizeAsMethodName() + "Color"
                } else {
                    methodName = "cName" + "Color()"
                }


                let code = "+ (UIColor *)clg_\(methodName);\n\n"
                return code
            }

            func classMethodImplementation(_ color: Color) -> String {

                let methodName: String
                if let cName = color.name {
                    methodName = cName.camelCase().sanitizeAsMethodName() + "Color"
                } else {
                    methodName = "cName" + "Color()"
                }

                let code = "+ (UIColor *)clg_\(methodName)\n" +
                "{\n" +
                "    return [UIColor colorWithRed:\(Double(color.color!.redComponent)) green:\(Double(color.color!.greenComponent)) blue:\(Double(color.color!.blueComponent)) alpha:\(Double(color.color!.alphaComponent))];\n" +
                "}\n\n"
                return code
            }

            func generateObjCHeaderFile(_ colors: [Color], fileName: String) {
                var code = "@import UIKit;"
                    + "\n"
                    + "\n"
                    + "@interface UIColor (CLRGeneratedAdditions)"
                    + "\n"
                    + "\n"

                for c in colors {
                    code += classMethodInterface(c)
                }

                code += "@end"

                var e: NSError? = nil

                let filePath = ((directory as NSString).appendingPathComponent("UIColor+CLRGeneratedAdditions.h") as NSString).standardizingPath
                if let path = URL(fileURLWithPath:filePath).path as? String {
                    let result: Bool
                    do {
                        try code.write(toFile: path,
                                                atomically: true,
                                                encoding: String.Encoding.utf8)
                        result = true
                    } catch let error as NSError {
                        e = error
                        result = false
                    }
                    if result {
                        CSNPrintStandardOutput("SUCCESS: saved to \(path)")
                    }
                    #if DEBUG
                        print(e)
                        print(result)
                    #endif
                } else {
                    CSNPrintStandardOutput("FAILED: failed to save swift extension file")
                }
            }

            func generateObjCImplementationFile(_ colors: [Color], fileName: String) {
                let headerFileName = "UIColor+CLRGeneratedAdditions.h"
                var code = "#import \"\(headerFileName)\""
                         + "\n"
                         + "\n"
                         + "@implementation UIColor (CLRGeneratedAdditions)"
                         + "\n"
                         + "\n"

                for c in colors {
                    code += classMethodImplementation(c)
                }

                code += "@end"

                var e: NSError? = nil
                let filePath = ((directory as NSString).appendingPathComponent("UIColor+CLRGeneratedAdditions.m") as NSString).standardizingPath
                if let path = URL(fileURLWithPath:filePath).path as? String {
                    let result: Bool
                    do {
                        try code.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                        result = true
                    } catch let error as NSError {
                        e = error
                        result = false
                    }
                    if result {
                        CSNPrintStandardOutput("SUCCESS: saved to \(path)")
                    }
                    #if DEBUG
                        print(e)
                        print(result)
                    #endif
                } else {
                    CSNPrintStandardOutput("FAILED: failed to save swift extension file")
                }

            }

            generateObjCHeaderFile(colors, fileName: directory)
            generateObjCImplementationFile(colors, fileName: directory)

        case .Android:
            func colorElement(_ color: Color) -> String {
                let name: String
                if let cName = color.name {
                    name = cName.snakeCase().sanitizeAsMethodName()
                } else {
                    name = "cName"
                }
                return "    <color name=\"\(name)\">\(color.hexStringRepresentation())</color>\n"
            }

            func generateColorXMLFile(_ colors: [Color], fileName: String) {
                var code = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                    + "\n"
                    + "<resources>"
                    + "\n"
                    + "    <!-- Palette generated by clg -->"
                    + "\n"
                    + "\n"

                for c in colors {
                    code += colorElement(c)
                }

                code += "</resources>"

                var e: NSError? = nil
                let filePath = ((directory as NSString).appendingPathComponent("colors.xml") as NSString).standardizingPath
                if let path = URL(fileURLWithPath:filePath).path as? String {
                    let result: Bool
                    do {
                        try code.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                        result = true
                    } catch let error as NSError {
                        e = error
                        result = false
                    }
                    if result {
                        CSNPrintStandardOutput("SUCCESS: saved to \(path)")
                    }
                    #if DEBUG
                        print(e)
                        print(result)
                    #endif
                } else {
                    CSNPrintStandardOutput("FAILED: failed to save swift extension file")
                }
            }

            generateColorXMLFile(colors, fileName: directory)
        }
    }

}

