@testable import ImageFeed
import XCTest
import Foundation

// MARK: - Spies

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var fetchPhotosNextPageCalled: Bool = false
    var changeLikeCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled: Bool = false
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
}

// MARK: - Tests

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateTableViewOnNotification() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: nil)
            
        //then
        // Since notification is processed immediately usually, but just in case we can use expectation if async.
        // The observer runs in .main queue which is synchronous if posted on main queue.
        let expectation = self.expectation(description: "Wait for notification")
        DispatchQueue.main.async {
            XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
}
