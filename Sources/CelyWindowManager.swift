//
//  CelyManager.swift
//  Cely
//
//  Created by Fabian Buentello on 10/14/16.
//  Copyright © 2016 Fabian Buentello. All rights reserved.
//

import UIKit

public class CelyWindowManager {

    // MARK: - Variables
    static let manager = CelyWindowManager()
    internal var window: UIWindow!

    public var loginController: UIViewController?
    public var homeController: UIViewController?

    public var loginStyle: CelyStyle!
    public var celyAnimator: CelyAnimator!

    public init() {}

    static func setup(window _window: UIWindow, withOptions options: [CelyOptions : Any?]? = [:]) {
        CelyWindowManager.manager.window = _window

        // Set the login Styles
        CelyWindowManager.manager.loginStyle = options?[.loginStyle] as? CelyStyle ?? DefaultSyle()

        // Set the HomeStoryboard
        CelyWindowManager.setHomeController(options?[.homeController] as? UIViewController)

        // Set the LoginStoryboard
        CelyWindowManager.setLoginController(options?[.loginController] as? UIViewController)

        // Set the Transition Animator
        CelyWindowManager.manager.celyAnimator = options?[.celyAnimator] as? CelyAnimator ?? DefaultAnimator()

        CelyWindowManager.manager.addObserver(#selector(showScreenWith), action: .loggedIn)
        CelyWindowManager.manager.addObserver(#selector(showScreenWith), action: .loggedOut)
    }

    // MARK: - Private Methods

    private func addObserver(_ selector: Selector, action: CelyStatus) {
        NotificationCenter.default
            .addObserver(self,
                         selector: selector,
                         name: NSNotification.Name(rawValue: action.rawValue),
                         object: nil)
    }

    // MARK: - Public Methods

    @objc func showScreenWith(notification: NSNotification) {
        if let status = notification.object as? CelyStatus {
            if let block = Cely.loginTransitionCompletionBlock {
                block(status)
            } else {
                if status == .loggedIn {
                    CelyWindowManager.manager.celyAnimator.loginTransition(
                        to: CelyWindowManager.manager.homeController,
                        with: CelyWindowManager.manager.window
                    )
                } else {
                    CelyWindowManager.manager.celyAnimator.logoutTransition(
                        to: CelyWindowManager.manager.loginController,
                        with: CelyWindowManager.manager.window
                    )
                }
            }
        }
    }

    static func setHomeController(_ controller: UIViewController?) {
        let defaultController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        CelyWindowManager.manager.homeController = controller ?? defaultController
    }

    static func setLoginController(_ controller: UIViewController?) {
        let defaultController = UIStoryboard(name: "Cely", bundle: Bundle(for: CelyWindowManager.self)).instantiateInitialViewController()
        CelyWindowManager.manager.loginController = controller ?? defaultController
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
