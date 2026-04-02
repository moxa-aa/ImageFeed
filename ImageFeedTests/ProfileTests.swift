@testable import ImageFeed
import XCTest
import Foundation

// MARK: - Spies

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var logoutCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var updateAvatarCalled: Bool = false
    var updateProfileDetailsCalled: Bool = false
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func updateProfileDetails(profile: Profile) {
        updateProfileDetailsCalled = true
    }
}

// MARK: - Tests

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateAvatarOnLoad() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
}
