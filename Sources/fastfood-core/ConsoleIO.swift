//
//  ConsoleIO.swift
//  Fastfood
//
//  Created by Stas on 05/04/2019.
//
import Foundation

class ConsoleIO {

    func getInput() -> String {
        let keyboard = FileHandle.standardInput
        let inputData = keyboard.availableData
        let strData = String(data: inputData, encoding: String.Encoding.utf8)!

        return strData.trimmingCharacters(in: CharacterSet.newlines)
    }

}
