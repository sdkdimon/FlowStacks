import FlowStacks
import SwiftUI
import SwiftUINavigation

enum Screen {
  case number(Int)
  case other
}

extension Screen: ExpressibleByIntegerLiteral, Hashable {
  init(integerLiteral value: Int) {
    self = .number(value)
  }
}

struct NumberCoordinator: View {
  @State var routes: Routes<Screen> = [.root(0, embedInNavigationView: true)]

  var randomRoutes: [Route<Screen>] {
    let options: [[Route<Screen>]] = [
      [.root(0, embedInNavigationView: true)],
      [.root(0, embedInNavigationView: true), .push(1), .push(2), .push(3), .sheet(4, embedInNavigationView: true), .push(5)],
      [.root(0, embedInNavigationView: true), .push(1), .push(2), .push(3)],
      [.root(0, embedInNavigationView: true), .push(1), .sheet(2, embedInNavigationView: true), .push(3), .sheet(4, embedInNavigationView: true), .push(5)],
      [.root(0, embedInNavigationView: true), .sheet(1, embedInNavigationView: true), .cover(2, embedInNavigationView: true), .push(3), .sheet(4, embedInNavigationView: true), .push(5)],
    ]
    return options.randomElement()!
  }

  var body: some View {
    Router($routes) { $screen, _ in
      if let number = Binding(unwrapping: $screen, case: /Screen.number) {
        NumberView(
          number: number,
          routes: $routes,
          goRandom: {
            $routes.withDelaysIfUnsupported {
              $0 = randomRoutes
            }
          }
        )
      } else {
        EmptyView()
      }
    }
    .onOpenURL { url in
      guard let deeplink = Deeplink(url: url) else { return }
      follow(deeplink)
    }
  }

  @MainActor
  private func follow(_ deeplink: Deeplink) {
    guard case .numberCoordinator(let link) = deeplink else {
      return
    }
    switch link {
    case .numbers(let numbers):
      $routes.withDelaysIfUnsupported {
        for number in numbers {
          $0.push(.number(number))
        }
      }
    }
  }
}

struct NumberView: View {
  @Binding var number: Int
  @Binding var routes: [Route<Screen>]

  let goRandom: (() -> Void)?

  var body: some View {
    VStack(spacing: 8) {
      Stepper("\(number)", value: $number)
      Button("Present Double (cover)") {
        routes.presentCover(.number(number * 2), embedInNavigationView: true)
      }
      .accessibilityIdentifier("Present Double (cover) from \(number)")
      Button("Present Double (sheet)") {
        routes.presentSheet(.number(number * 2), embedInNavigationView: true)
      }
      .accessibilityIdentifier("Present Double (sheet) from \(number)")
      Button("Push next") {
        routes.push(.number(number + 1))
      }
      .accessibilityIdentifier("Push next from \(number)")
      if let goRandom = goRandom {
        Button("Go random", action: goRandom)
      }
      if routes.count > 1 {
        Button("Go back") { routes.goBack() }
          .accessibilityIdentifier("Go back from \(number)")
        Button("Go back to root") { routes.goBackToRoot() }
          .accessibilityIdentifier("Go back to root from \(number)")
      }
    }
    .padding()
    .navigationTitle("\(number)")
  }
}

// Included so that the same example code can be used for macOS too.
#if os(macOS)
  extension Route {
    static func cover(_ screen: Screen, embedInNavigationView: Bool = false) -> Route {
      sheet(screen, embedInNavigationView: embedInNavigationView)
    }
  }

  extension Array where Element: RouteProtocol {
    mutating func presentCover(_ screen: Element.Screen, embedInNavigationView: Bool = false) {
      presentSheet(screen, embedInNavigationView: embedInNavigationView)
    }
  }

  extension FlowNavigator {
    func presentCover(_ screen: Screen, embedInNavigationView: Bool = false) {
      presentSheet(screen, embedInNavigationView: embedInNavigationView)
    }
  }
#endif
