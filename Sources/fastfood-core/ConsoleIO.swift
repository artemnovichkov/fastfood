//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

final class ConsoleIO {

    func getInput() -> String? {
        let keyboard = FileHandle.standardInput
        let inputData = keyboard.availableData
        let strData = String(data: inputData, encoding: .utf8)

        return strData?.trimmingCharacters(in: .newlines)
    }

}
