import Foundation

enum ListCreationError: String, Error {
    case empty = ""
    case alreadyUsed = "Это название уже используется, пожалуйста, измените его"
}
