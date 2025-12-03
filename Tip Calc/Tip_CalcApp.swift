//
//  Tip_CalcApp.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 21/08/2025.
//

import SwiftUI
import Combine

@main
struct Tip_CalcApp: App {
    var body: some Scene {
        TestSafeWindowGroup {
            ContentView()
        }
    }
}

extension ProcessInfo {
    var isRunningTests: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}

struct TestSafeWindowGroup<Content: View>: Scene {
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.isRunningTests {
                EmptyView()
            } else {
                content()
            }
        }
    }
}



//class DispatchQueueViewModel: ObservableObject {
//    let serialQueue = DispatchQueue(label: "com.example.serial")
//    let concurrentQueue = DispatchQueue(label: "com.example.concurrent", attributes: .concurrent)
//    let group = DispatchGroup()
//    
//    func test1() {
//        DispatchQueue.global().async { // przechodzimy na wątek w tle
//            let result = "Fetched data from server"
//            
//            DispatchQueue.main.async { // wracamy na główny wątek
//                print("Update UI with: ", result)
//            }
//        }
//    }
//    
//    func test2() {
//        let start = Date()
//        DispatchQueue.global(qos: .userInteractive).async {
//            for i in 1...20_000_000 {
//                _ = sqrt(Double(i))
//            }
//            DispatchQueue.main.async {
//                let elapsed = Date().timeIntervalSince(start)
//                print("Elapsed time: \(elapsed) seconds")
//            }
//        }
//    }
//    
//    func test3() {
//        serialQueue.async {
//            print("Task 1")
//        }
//        serialQueue.async {
//            print("Task 2")
//        }
//        serialQueue.async {
//            print("Task 3")
//        }
//    }
//    
//    func test4() {
//        concurrentQueue.async {
//            print("Task A")
//        }
//        concurrentQueue.async {
//            print("Task B")
//        }
//        concurrentQueue.async {
//            print("Task C")
//        }
//    }
//    
//    func test5() {
//        group.enter()
//        DispatchQueue.global().async {
//            print("Download image")
//            self.group.leave()
//        }
//        group.enter()
//        DispatchQueue.global().async {
//            print("Download JSON")
//            self.group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            print("All downloads finished")
//        }
//    }
//    
//    func one() {
//        two()
//    }
//    
//    func two() {
//        DispatchQueue.global().async {
//            self.three()
//        }
//    }
//    
//    func three() {
//        four()
//    }
//    
//    func four() {
//        DispatchQueue.main.async {
//            print("Done!")
//        }
//    }
//}
//
//struct DispatchQueueLessonView: View {
//    @ObservedObject var viewModel = DispatchQueueViewModel()
//    @State var counter = 1
//    
//    var body: some View {
//        Text("Hello!")
//        Button("Main / Global switch") {
//            viewModel.test1()
//        }
//        Button("Counter: \(counter)") {
//            counter += 1
//            if counter == 5 {
//                viewModel.test2()
//            }
//        }
//        Button("Serial Queue") {
//            viewModel.test3()
//        }
//        Button("Concurrent Queue") {
//            viewModel.test4()
//        }
//        Button("Wait for concurrent queue") {
//            viewModel.test5()
//        }
//        Button("Function chain") {
//            viewModel.one()
//        }
//    }
//}
