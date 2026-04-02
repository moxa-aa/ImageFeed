import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("gainitfuture@gmail.com")
        
        webView.swipeUp()
        // Обязательная пауза, чтобы кинетический скролл после swipeUp() полностью остановился
        // Иначе XCUITest промахнется при тапе по полю пароля!
        sleep(2) 
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("Gameshow03")
        
        webView.swipeUp()
        sleep(2)
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        // Даем симулятору больше времени (10 сек) на полную загрузку токена, профиля и фото
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        let likeButtonOff = cellToLike.buttons["like button off"]
        let likeButtonOn = cellToLike.buttons["like button on"]
        
        if likeButtonOff.exists {
            likeButtonOff.tap()
            sleep(2)
            likeButtonOn.tap()
        } else if likeButtonOn.exists {
            likeButtonOn.tap()
            sleep(2)
            likeButtonOff.tap()
        }
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        // ВНИМАНИЕ: Замените эти строки на ваше реальное Имя и Фамилию профиля Unsplash
        XCTAssertTrue(app.staticTexts["Mokhirjon Erkinov"].exists)
        XCTAssertTrue(app.staticTexts["@moxa_aa"].exists)
        
        app.buttons["logout button"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        // Проверяем, что открылся экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
