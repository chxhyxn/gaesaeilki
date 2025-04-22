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
    @Environment(\.modelContext) private var context
    @Query private var dogBirds: [DogBird]
    
    @State private var fieldSize: CGSize = .zero
    @AppStorage("currentGoal") var currentGoal: String = ""
    @State private var totalGaeSae: Int = UserDefaults.standard.integer(forKey: "totalGaeSae")
    @State private var failureNote: String = ""
    
    // 쓰레기통 관련 상태
    @State private var trashVisible = false
    @State private var trashHighlighted = false
    @State private var draggingDogBirdID: UUID? = nil
    
    @FocusState private var isTopTextFieldFocused: Bool
    @FocusState private var isBottomTextFieldFocused: Bool
    
    @StateObject var soundManager = SoundManager()
    
    // dogBird type
    @State private var current_type_id: Int = 0
    
    // 노트 팝업 관련 상태
    @State private var selectedDogBird: DogBird?
    @State private var showingNoteDetail = false
    @State private var editedNote = ""
    
    // 일기 리스트 보여주기
    @State private var showFailureNoteNavigatorView = false
    
    // 사운드 도움말 보여주기
    @State private var quietTime: TimeInterval = 0
    @State private var lastUpdateTime: Date = Date()
    @State private var showSoundPrompt: Bool = false
    
    // 새로 추가된 DogBird 상태 추적
    @State private var recentlyAddedDogBirdID: UUID? = nil
    
    // 배경 넘버
    @State private var bgNum: Int = 0
    
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    // MARK: 잔디 배경
                    GeometryReader { geometry in
                        Image("bg\(bgNum)")
                            .resizable()                         // 리사이즈 가능하게
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
                            
                            // 새로 추가된 개새 표시
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
                                    // 드래그 시작 또는 진행 중
                                    draggingDogBirdID = dogBird.id
                                    dogBird.isFlying = false
                                    
                                    // 이전 위치와 현재 위치를 비교하여 방향 업데이트
                                    let previousX = dogBird.x
                                    dogBird.position = gesture.location
                                    
                                    // 이동 방향에 따라 각도 업데이트
                                    if dogBird.x > previousX {
                                        // 오른쪽으로 이동 중
                                        dogBird.movingRight = true
                                    } else if dogBird.x < previousX {
                                        // 왼쪽으로 이동 중
                                        dogBird.movingRight = false
                                    }
                                    
                                    // 쓰레기통 표시
                                    trashVisible = true
                                    
                                    // 쓰레기통 위에 있는지 확인
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
                                    // 드래그 종료
                                    let trashPosition = CGPoint(
                                        x: geometry.size.width / 2,
                                        y: geometry.size.height / 2 + 180
                                    )
                                    
                                    let distance = sqrt(
                                        pow(gesture.location.x - trashPosition.x, 2) +
                                        pow(gesture.location.y - trashPosition.y, 2)
                                    )
                                    
                                    // 쓰레기통 위에서 드롭되었으면 삭제
                                    if distance < 45 {
                                        withAnimation {
                                            context.delete(dogBird)
                                        }
                                    }
                                    
                                    // 상태 초기화
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
                    isTopTextFieldFocused = false
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
                        // 어두운 영역 탭 시 팝업 닫기
                        withAnimation {
                            showingNoteDetail = false
                            selectedDogBird = nil
                        }
                    }
                    .mask {
                        // 구멍 뚫기: 선택된 개새 위치만 투명하게
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
            
            // UI
            VStack {
                // MARK: 상단 UI
                VStack {
                    Text("나의 목표")
                        .font(.headline)
                    
                    HStack {
                        TextField("✏️ 당신의 목표를 작성하세요.", text: $currentGoal)
                            .multilineTextAlignment(.center)
                            .fontWeight(.black)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isTopTextFieldFocused ? .white : .white.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .focused($isTopTextFieldFocused)
                        
                        if isTopTextFieldFocused {
                            Button(action: {
                                isTopTextFieldFocused = false
                                UserDefaults.standard.set(currentGoal, forKey: "currentGoal")
                            }) {
                                Image(systemName: "checkmark")
                                    .symbolEffect(.bounce, value: !isTopTextFieldFocused||currentGoal.isEmpty)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(!isTopTextFieldFocused||currentGoal.isEmpty ? .gray.opacity(0.2) : .gray)
                                    .frame(width: 55, height: 55)
                                    .background(
                                        Circle()
                                            .fill(!isTopTextFieldFocused||currentGoal.isEmpty ? .white.opacity(0.2) : .white)
                                    )
                            }
                            .disabled(!isTopTextFieldFocused||currentGoal.isEmpty)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 1)
                )
                .frame(height: 120)
                .padding()
                .onTapGesture {
                    isTopTextFieldFocused = false
                    isBottomTextFieldFocused = false
                }
                
                HStack {
                    Spacer()
                    // MARK: 음성감지 on/off 버튼(마이크 심볼)
                    Button(action: {
                        soundManager.toggleMonitoring()
                        isTopTextFieldFocused = false
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
//                                        Image(uiImage: UIImage(named: "\(i)")!)
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
                                        UserDefaults.standard.set(currentGoal, forKey: "currentGoal")
                                        addDogBird()
                                        isBottomTextFieldFocused = false
                                    }
                                }
                            
                            VStack {
                                Button(action: {
                                    UserDefaults.standard.set(currentGoal, forKey: "currentGoal")
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
                            isTopTextFieldFocused = false
                            isBottomTextFieldFocused = false
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .animation(.default, value: failureNote.isEmpty)
        .animation(.default, value: !isTopTextFieldFocused||currentGoal.isEmpty)
        .animation(.default, value: isTopTextFieldFocused)
        .animation(.default, value: isBottomTextFieldFocused)
        .animation(.easeInOut(duration: 0.5), value: showingNoteDetail)
        .animation(.easeInOut(duration: 0.5), value: selectedDogBird?.id)
        .onReceive(timer) { currentTime in
            updateDogBirdPositions()
            
            // Track how long the sound has been below threshold
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
                    // Reset when sound exceeds threshold
                    quietTime = 0
                    if showSoundPrompt {
                        withAnimation {
                            showSoundPrompt = false
                        }
                    }
                }
            } else {
                // Reset when not monitoring
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
    
    // 개새 이동 방향에 따라 이미지 방향 결정
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
        
        context.insert(newDogBird)
        failureNote = ""
        
        // 새로 생성된 DogBird에 표시하기
        recentlyAddedDogBirdID = newDogBird.id
        
        // 7초 후에 New 배지 숨기기
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
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
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
            // 현재 드래그 중인 개새는 건너뜀
            if draggingDogBirdID == dogBird.id {
                continue
            }
            
            if soundManager.soundLevel > 0.9 {
                // 소리가 감지되면 위로 날아간다
                dogBird.isFlying = true
                var newPosition = dogBird.position
                newPosition.y -= CGFloat(2.0 + (soundManager.soundLevel * 10)) // 소리 크기에 비례해서 더 빨리 올라감
                newPosition.x += CGFloat.random(in: -2...2) // 살짝 좌우 흔들림
                
                // 화면 경계 체크
                if newPosition.x < 20 {
                    newPosition.x = 20
                } else if newPosition.x > fieldSize.width - 20 {
                    newPosition.x = fieldSize.width - 20
                }
                
                if newPosition.y < 20 {
                    newPosition.y = 20
                }
                
                // 이전 위치와 비교하여 움직이는 방향 업데이트
                let previousX = dogBird.x
                dogBird.position = newPosition
                
                // 이동 방향에 따라 movingRight 값 업데이트
                if dogBird.x > previousX {
                    dogBird.movingRight = true
                } else if dogBird.x < previousX {
                    dogBird.movingRight = false
                }
            } else {
                // 소리가 없으면 자유롭게 돌아다님
                dogBird.isFlying = false
                let angle = dogBird.rotation * .pi / 180
                var newPosition = dogBird.position
                
                // 현재 방향으로 이동
                newPosition.x += CGFloat(cos(angle) * dogBird.speed)
                newPosition.y += CGFloat(sin(angle) * dogBird.speed)
                
                // 화면 경계에 닿으면 반대 방향으로 튕김
                var directionChanged = false
                
                if newPosition.x < 20 || newPosition.x > fieldSize.width - 20 {
                    dogBird.rotation = 180 - dogBird.rotation
                    directionChanged = true
                }
                
                if newPosition.y < 20 || newPosition.y > fieldSize.height - 20 {
                    dogBird.rotation = 360 - dogBird.rotation
                    directionChanged = true
                }
                
                // 방향이 변경되었다면 새 방향으로 위치 재계산
                if directionChanged {
                    let newAngle = dogBird.rotation * .pi / 180
                    newPosition.x = dogBird.position.x + CGFloat(cos(newAngle) * dogBird.speed)
                    newPosition.y = dogBird.position.y + CGFloat(sin(newAngle) * dogBird.speed)
                }
                
                // 가끔 랜덤하게 방향 변경 (3% 확률)
                if Int.random(in: 0...100) < 3 {
                    dogBird.rotation = Double.random(in: 0...360)
                }
                
                // 화면 밖에 있으면 화면 안으로 강제 이동
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
                
                // 이전 위치와 비교하여 움직이는 방향 업데이트
                _ = dogBird.x
                dogBird.position = newPosition
                
                // 코사인 값으로 이동 방향 결정 (cos > 0이면 오른쪽으로 이동 중)
                dogBird.movingRight = cos(angle) > 0
            }
        }
    }
}
