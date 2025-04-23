//
//  MainView.swift
//  GaeSaeIlKi
//
//  Updated on 4/10/25.
//

import SwiftUI
import SwiftData
import StoreKit
import SDWebImageSwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    
    @Query(filter: #Predicate<DogBird> { !$0.isFlyAway }) private var dogBirds: [DogBird]
    
    @AppStorage("currentGoal") var currentGoal: String = ""
    @AppStorage("currentScreen") var currentScreen: ViewScreen = .onboarding
    
    @State private var soundManager = SoundManager()
    
    @State private var fieldSize: CGSize = .zero
    @State private var totalGaeSae: Int = UserDefaults.standard.integer(forKey: "totalGaeSae")
    @State private var failureNote: String = ""
    @State private var trashVisible = false
    @State private var trashHighlighted = false
    @State private var draggingDogBirdID: UUID? = nil
    @State private var current_type_id: Int = 0
    @State private var selectedDogBird: DogBird?
    @State private var showingNoteDetail = false
    @State private var editedNote = ""
    @State private var showFailureNoteNavigatorView = false
    @State private var quietTime: TimeInterval = 0
    @State private var lastUpdateTime: Date = Date()
    @State private var showSoundPrompt: Bool = false
    @State private var recentlyAddedDogBirdID: UUID? = nil
    @State private var bgNum: Int = 0
    @State private var factorWhiteLayersHeight: CGFloat = 1
    
    @FocusState private var isBottomTextFieldFocused: Bool
    
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    // MARK: 잔디 배경
                    GeometryReader { geometry in
                        Image("bg\(bgNum)")
                            .resizable()
                            .scaledToFill()
                            .frame(width: fieldSize.width, height: fieldSize.height)
                            .onAppear {
                                fieldSize = geometry.size
                            }
                            .gesture(
                                DragGesture(minimumDistance: 20)
                                    .onEnded { value in
                                        if abs(value.translation.width) > abs(value.translation.height) {
                                            bgNum = (bgNum + 1) % 7
                                        }
                                    }
                            )
                    }
                    
                    // MARK: 쓰레기통
                    ZStack {
                        Circle()
                            .fill(trashHighlighted ? Color.red.opacity(0.3) : Color.gray.opacity(0.2))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(trashHighlighted ? Color.red : Color.gray, lineWidth: trashHighlighted ? 3 : 1)
                            )
                        
                        Image(systemName: "trash")
                            .symbolEffect(.bounce, value: trashHighlighted)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(trashHighlighted ? .red : .gray)
                            .frame(width: 70, height: 70)
                            .background(
                                Circle()
                                    .fill(trashHighlighted ? .white.opacity(0.9) : .white.opacity(0.8))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 180)
                    .opacity(trashVisible ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashVisible)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashHighlighted)
                    
                    // MARK: 개새들 (욕아님!)
                    ForEach(dogBirds) { dogBird in
                        ZStack {
                            if dogBird.isFlying {
                                Image("\(dogBird.type_id)_flying")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: dogBird.size, height: dogBird.size)
                                    .scaleEffect(x: shouldFaceRight(dogBird) ? -1 : 1, y: 1)
                            }
                            if let path = Bundle.main.path(forResource: "\(dogBird.type_id)", ofType: "webp") {
                                let url = URL(fileURLWithPath: path)
                                AnimatedImage(url: url)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: dogBird.size, height: dogBird.size)
                                    .scaleEffect(x: shouldFaceRight(dogBird) ? -1 : 1, y: 1)
                                    .opacity(dogBird.isFlying ? 0.05 : 1)
                            }
                            
                            if recentlyAddedDogBirdID == dogBird.id {
                                ZStack {
                                    Circle()
                                        .stroke(Color.yellow, lineWidth: 5)
                                        .fill(Color.yellow.opacity(0.3))
                                        .frame(width: dogBird.size + 30, height: dogBird.size + 30)
                                    
                                    Text("New")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .position(dogBird.position)
                        .scaleEffect(draggingDogBirdID == dogBird.id ? 1.1 : 1.0)
                        .shadow(
                            color: .black.opacity(draggingDogBirdID == dogBird.id ? 0.3 : 0),
                            radius: draggingDogBirdID == dogBird.id ? 10 : 0
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    draggingDogBirdID = dogBird.id
                                    dogBird.isFlying = false
                                    
                                    let previousX = dogBird.x
                                    dogBird.position = gesture.location
                                    
                                    if dogBird.x > previousX {
                                        dogBird.movingRight = true
                                    } else if dogBird.x < previousX {
                                        dogBird.movingRight = false
                                    }
                                    
                                    trashVisible = true
                                    
                                    let trashPosition = CGPoint(
                                        x: geometry.size.width / 2,
                                        y: geometry.size.height / 2 + 180
                                    )
                                    
                                    let distance = sqrt(
                                        pow(gesture.location.x - trashPosition.x, 2) +
                                        pow(gesture.location.y - trashPosition.y, 2)
                                    )
                                    
                                    trashHighlighted = distance < 45
                                }
                                .onEnded { gesture in
                                    let trashPosition = CGPoint(
                                        x: geometry.size.width / 2,
                                        y: geometry.size.height / 2 + 180
                                    )
                                    
                                    let distance = sqrt(
                                        pow(gesture.location.x - trashPosition.x, 2) +
                                        pow(gesture.location.y - trashPosition.y, 2)
                                    )
                                    
                                    if distance < 45 {
                                        withAnimation {
                                            modelContext.delete(dogBird)
                                        }
                                    }
                                    
                                    draggingDogBirdID = nil
                                    trashVisible = false
                                    trashHighlighted = false
                                }
                        )
                        .onTapGesture {
                            if draggingDogBirdID == nil {
                                showNoteDetail(for: dogBird)
                            }
                        }
                    }
                }
                .ignoresSafeArea(.all)
                .onTapGesture {
                    isBottomTextFieldFocused = false
                }
            }
            
            // MARK: 큰 음성 감지 UI
            if soundManager.isMonitoring {
                VStack {
                    Spacer()
                    VolumeRingView(decibel: soundManager.soundLevel, showPrompt: showSoundPrompt)
                    Spacer()
                }
            }
            
            // MARK: SPOTLIGHT SELECTED DOG
            if let selected = selectedDogBird, showingNoteDetail {
                Color.black.opacity(0.6)
                    .onTapGesture {
                        withAnimation {
                            showingNoteDetail = false
                            selectedDogBird = nil
                        }
                    }
                    .mask {
                        Rectangle()
                            .overlay(
                                Circle()
                                    .frame(width: selected.size + 30, height: selected.size + 30)
                                    .position(selected.position)
                                    .blendMode(.destinationOut)
                            )
                    }
                    .compositingGroup()
                    .animation(.easeInOut(duration: 0.3), value: selectedDogBird?.id)
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
            
            VStack {
                // MARK: 상단 UI
                // TODO: dogBirds가 20마리일때 100%인 프로그래스 뷰. 다른 UI를 참고해 배경에는 글래스모피즘 디자인을 적용한다.
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .frame(width: geometry.size.width - 40, height: 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(12, (geometry.size.width - 40) * (CGFloat(dogBirds.count) / 20.0)),
                                height: 24
                            )
                        
                        HStack {
                            Spacer()
                            Text("\(dogBirds.count)/20 개새")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(radius: 1)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(width: UIScreen.main.bounds.width, height: 24)
                
                HStack {
                    Spacer()
                    // MARK: 음성감지 on/off 버튼(마이크 심볼)
                    Button(action: {
                        soundManager.toggleMonitoring()
                        isBottomTextFieldFocused = false
                    }) {
                        Image(systemName: soundManager.isMonitoring ? "mic.fill" : "mic.slash")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(radius: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // MARK: 일기가 정리된 화면 보여주기
                    Button(action: {
                        showFailureNoteNavigatorView = true
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(radius: 1)
                            )
                    }
                    .padding(.trailing)
                }
                
                Spacer()
                
                // MARK: 하단 UI (실패일기 입력 영역 or 노트 상세 팝업)
                if showingNoteDetail, let dogBird = selectedDogBird {
                    PopupNoteDetailView(
                        isPresented: $showingNoteDetail,
                        failureNote: Binding(
                            get: { self.editedNote },
                            set: {
                                self.editedNote = $0
                                dogBird.failureNote = $0
                            }
                        ),
                        goalAtCreation: dogBird.goalAtCreation,
                        createdAt: dogBird.createdAt
                    )
                    .id(dogBird.id)
                    .transition(.move(edge: .bottom))
                }else {
                    VStack {
                        HStack {
                            // MARK: type 고르는 ui
                            HStack {
                                ForEach(0...3, id: \.self) { i in
                                    Button(action: {
                                        current_type_id = i
                                    }) {
                                        Image("\(i)")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(Circle())
                                            .opacity(current_type_id == i ? 1 : 0.5)
                                            .frame(width: 50, height: 50)
                                            .overlay(content: {
                                                Circle()
                                                    .stroke(current_type_id == i ? .white : .white.opacity(0.5), lineWidth: 2)
                                                    .shadow(radius: 1)
                                            })
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .shadow(radius: 1)
                            )
                            .padding(.horizontal)
                            Spacer()
                        }
                        
                        VStack {
                            HStack {
                                Text("나의 목표 : \(currentGoal)")
                                    .font(.headline)
                                Spacer()
                            }
                            HStack(alignment: .top) {
                                TextField("오늘의 실패일기를 작성하세요.", text: $failureNote, axis: .vertical)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(isBottomTextFieldFocused ? .white : .white.opacity(0.5))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .focused($isBottomTextFieldFocused)
                                    .onSubmit {
                                        if !failureNote.isEmpty {
                                            addDogBird()
                                            isBottomTextFieldFocused = false
                                        }
                                    }
                                
                                VStack {
                                    Button(action: {
                                        addDogBird()
                                        isBottomTextFieldFocused = false
                                    }) {
                                        Image(systemName: "plus")
                                            .symbolEffect(.bounce, value: failureNote.isEmpty)
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(failureNote.isEmpty ? .gray.opacity(0.2) : .gray)
                                            .frame(width: 55, height: 55)
                                            .background(
                                                Circle()
                                                    .fill(failureNote.isEmpty ? .white.opacity(0.2) : .white)
                                            )
                                    }
                                    .disabled(failureNote.isEmpty)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(radius: 1)
                        )
                        .lineLimit(1...7)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .onTapGesture {
                            isBottomTextFieldFocused = false
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            
            // MARK: 하얀 레이어
            Color.white
                .ignoresSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height * factorWhiteLayersHeight)
        }
        .onAppear() {
            HideWhiteLayer()
        }
        .animation(.default, value: failureNote.isEmpty)
        .animation(.default, value: isBottomTextFieldFocused)
        .animation(.easeInOut(duration: 0.5), value: showingNoteDetail)
        .animation(.easeInOut(duration: 0.5), value: selectedDogBird?.id)
        .onReceive(timer) { currentTime in
            updateDogBirdPositions()
            
            let timeSinceLastUpdate = currentTime.timeIntervalSince(lastUpdateTime)
            lastUpdateTime = currentTime
            
            if soundManager.isMonitoring {
                if soundManager.soundLevel < 0.9 {
                    quietTime += timeSinceLastUpdate
                    if quietTime > 5.0 && !showSoundPrompt {
                        withAnimation {
                            showSoundPrompt = true
                        }
                    }
                } else {
                    quietTime = 0
                    if showSoundPrompt {
                        withAnimation {
                            showSoundPrompt = false
                        }
                    }
                }
            } else {
                quietTime = 0
                showSoundPrompt = false
            }
        }
        .sheet(isPresented: $showFailureNoteNavigatorView) {
            FailureNoteNavigatorView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func shouldFaceRight(_ dogBird: DogBird) -> Bool {
        let angle = dogBird.rotation * .pi / 180
        let movingRight = cos(angle) > 0
        return movingRight || dogBird.movingRight
    }
    
    // MARK: 개새 추가 함수
    private func addDogBird() {
        guard !failureNote.isEmpty else { return }
        
        let randomX = fieldSize.width / 2
        let randomY = fieldSize.height / 2
        
        let newDogBird = DogBird(
            type_id: current_type_id,
            position: CGPoint(x: randomX, y: randomY),
            failureNote: failureNote,
            goalAtCreation: currentGoal
        )
        
        modelContext.insert(newDogBird)
        failureNote = ""
        
        recentlyAddedDogBirdID = newDogBird.id
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            withAnimation {
                if recentlyAddedDogBirdID == newDogBird.id {
                    recentlyAddedDogBirdID = nil
                }
            }
        }
        
        totalGaeSae += 1
        UserDefaults.standard.set(totalGaeSae, forKey: "totalGaeSae")
        if totalGaeSae % 50 == 49 {
            Task { @MainActor in
                requestReview()
            }
        }
        
        if dogBirds.count > 18 {
            showWhiteLayerAndResult()
        }
    }
    
    // MARK: 노트 상세 보기 표시
    private func showNoteDetail(for dogBird: DogBird) {
        selectedDogBird = dogBird
        editedNote = dogBird.failureNote
        showingNoteDetail = true
    }
    
    // MARK: 개새 위치 업데이트
    private func updateDogBirdPositions() {
        for dogBird in dogBirds {
            if draggingDogBirdID == dogBird.id {
                continue
            }
            
            if soundManager.soundLevel > 0.9 {
                dogBird.isFlying = true
                var newPosition = dogBird.position
                newPosition.y -= CGFloat(2.0 + (soundManager.soundLevel * 10))
                newPosition.x += CGFloat.random(in: -2...2)
                
                if newPosition.x < 20 {
                    newPosition.x = 20
                } else if newPosition.x > fieldSize.width - 20 {
                    newPosition.x = fieldSize.width - 20
                }
                
                if newPosition.y < 20 {
                    newPosition.y = 20
                }
                
                let previousX = dogBird.x
                dogBird.position = newPosition
                
                if dogBird.x > previousX {
                    dogBird.movingRight = true
                } else if dogBird.x < previousX {
                    dogBird.movingRight = false
                }
            } else {
                dogBird.isFlying = false
                let angle = dogBird.rotation * .pi / 180
                var newPosition = dogBird.position
                
                newPosition.x += CGFloat(cos(angle) * dogBird.speed)
                newPosition.y += CGFloat(sin(angle) * dogBird.speed)
                
                var directionChanged = false
                
                if newPosition.x < 20 || newPosition.x > fieldSize.width - 20 {
                    dogBird.rotation = 180 - dogBird.rotation
                    directionChanged = true
                }
                
                if newPosition.y < 20 || newPosition.y > fieldSize.height - 20 {
                    dogBird.rotation = 360 - dogBird.rotation
                    directionChanged = true
                }
                
                if directionChanged {
                    let newAngle = dogBird.rotation * .pi / 180
                    newPosition.x = dogBird.position.x + CGFloat(cos(newAngle) * dogBird.speed)
                    newPosition.y = dogBird.position.y + CGFloat(sin(newAngle) * dogBird.speed)
                }
                
                if Int.random(in: 0...100) < 3 {
                    dogBird.rotation = Double.random(in: 0...360)
                }
                
                if newPosition.x < 20 {
                    newPosition.x = 20
                } else if newPosition.x > fieldSize.width - 20 {
                    newPosition.x = fieldSize.width - 20
                }
                
                if newPosition.y < 20 {
                    newPosition.y = 20
                } else if newPosition.y > fieldSize.height - 20 {
                    newPosition.y = fieldSize.height - 20
                }
                
                _ = dogBird.x
                dogBird.position = newPosition
                
                dogBird.movingRight = cos(angle) > 0
            }
        }
    }
    
    private func showWhiteLayerAndResult() {
        withAnimation(.easeIn(duration: 2.0)) {
            factorWhiteLayersHeight = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            currentScreen = .showResult
        }
    }
    
    private func HideWhiteLayer() {
        withAnimation(.easeOut(duration: 2.0)) {
            factorWhiteLayersHeight = 0
        }
    }
}
