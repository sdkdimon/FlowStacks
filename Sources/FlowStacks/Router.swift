import Foundation
import SwiftUI

/// Router converts an array of pushed / presented routes into a view.
public struct Router<Screen, ScreenView: View>: View {
  /// The array of routes that represents the navigation stack.
  @Binding var routes: [Route<Screen>]

  /// A closure that builds a `ScreenView` from a `Screen`and its index.
  @ViewBuilder var buildView: (Binding<Screen>, Int) -> ScreenView

  
  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a binding to a `Screen` and its index.
  public init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Binding<Screen>, Int) -> ScreenView) {
    self._routes = routes
    self.buildView = buildView
  }
  
  public var body: some View {
    //iOS 16.4 because in prior versions navigationDestination(isPresented:) modifier has different behaviour
    //Here the article https://www.pointfree.co/blog/posts/84-better-swiftui-navigation-apis
    //Fixes available at https://github.com/pointfreeco/swiftui-navigation
    //But in our case we have vice versa issue
    //Prior to iOS 16.4 navigationDestination(isPresented:) not working
    //Starting from iOS 16.4 navigationDestination(isPresented:) works normally
    if #available(iOS 16.4, macOS 13.3, tvOS 16.0, watchOS 9.0, *) {
      Node16(allScreens: $routes, truncateToIndex: { index in routes = Array(routes.prefix(index)) }, index: 0, buildView: buildView)
    } else {
      Node(allScreens: $routes, truncateToIndex: { index in routes = Array(routes.prefix(index)) }, index: 0, buildView: buildView)
    }
  }
}

public extension Router {
  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a `Screen` and its index.
  init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Screen, Int) -> ScreenView) {
    self._routes = routes
    self.buildView = { buildView($0.wrappedValue, $1) }
  }
  
  init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Binding<Screen>) -> ScreenView) {
    self._routes = routes
    self.buildView = { screen, _ in buildView(screen) }
  }
  
  init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
    self._routes = routes
    self.buildView = { $screen, _ in buildView(screen) }
  }
}
