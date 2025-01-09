import Foundation

enum ProductCreationError: String, Error {
    case empty = ""
    case alreadyUsed = "Этот товар уже есть в списке, добавьте другой"
}
