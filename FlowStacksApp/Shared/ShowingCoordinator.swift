import FlowStacks
import SwiftUI
import SwiftUINavigation

struct ShowingCoordinator: View {
  @State var routes: Routes<Int> = []

  var body: some View {
    Button("Show 42", action: { routes.push(42) })
      .showing($routes, embedInNavigationView: true) { $number, _ in
        ShownNumberView(number: $number, routes: $routes)
      }
  }
}

struct ShownNumberView: View {
  @Binding var number: Int
  @Binding var routes: [Route<Int>]
  
  var body: some View {
    VStack(spacing: 8) {
      Stepper("\(number)", value: $number)
      Button("Present Double (cover)") {
        routes.presentCover(number * 2, embedInNavigationView: true)
      }
      Button("Present Double (sheet)") {
        routes.presentSheet(number * 2, embedInNavigationView: true)
      }
      Button("Push next") {
        routes.push(number + 1)
      }
      if !routes.isEmpty {
        Button("Go back") { routes.goBack() }
      }
    }
    .padding()
    .navigationTitle("\(number)")
  }
}
