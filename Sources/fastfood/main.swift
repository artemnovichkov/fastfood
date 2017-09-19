//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import FastfoodCore

let fastfood = Fastfood()

do {
    try fastfood.run()
}
catch {
    print("❌ \(error.localizedDescription)")
}
