import Foundation
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct Node16<Screen, V: View>: View {
  @Binding var allScreens: [Route<Screen>]
  let buildView: (Binding<Screen>, Int) -> V
  let truncateToIndex: (Int) -> Void
  let index: Int
  let screen: Screen?
  
  @State var isAppeared = false

  init(allScreens: Binding<[Route<Screen>]>, truncateToIndex: @escaping (Int) -> Void, index: Int, buildView: @escaping (Binding<Screen>, Int) -> V) {
    _allScreens = allScreens
    self.truncateToIndex = truncateToIndex
    self.index = index
    self.buildView = buildView
    screen = allScreens.wrappedValue[safe: index]?.screen
  }

  private var isActiveBinding: Binding<Bool> {
    return Binding(
      get: { allScreens.count > index + 1 },
      set: { isShowing in
        guard !isShowing else { return }
        guard allScreens.count > index + 1 else { return }
        guard isAppeared else { return }
        truncateToIndex(index + 1)
      }
    )
  }

  var next: some View {
    Node16(allScreens: $allScreens, truncateToIndex: truncateToIndex, index: index + 1, buildView: buildView)
  }
  
  var nextRoute: Route<Screen>? {
    allScreens[safe: index + 1]
  }

  @ViewBuilder
  var content: some View {
    if let screen = allScreens[safe: index]?.screen ?? screen {
      let screenBinding = Binding<Screen>(
        get: { allScreens[safe: index]?.screen ?? screen },
        set: { allScreens[index].screen = $0 }
      )
      buildView(screenBinding, index)
        .navigationDestination(
          isPresented: nextRoute?.style == .push ? isActiveBinding : .constant(false),
          destination: { next }
        )
        .presenting(
          sheetBinding: (nextRoute?.style.isSheet ?? false) ? isActiveBinding : .constant(false),
          coverBinding: (nextRoute?.style.isCover ?? false) ? isActiveBinding : .constant(false),
          destination: next,
          onDismiss: nextRoute?.onDismiss
        )
        .onAppear { isAppeared = true }
        .onDisappear { isAppeared = false }
    }
  }
  
  var body: some View {
    let route = allScreens[safe: index]
    if route?.embedInNavigationView ?? false {
      NavigationStack {
        content
      }
    } else {
      content
    }
  }
}
