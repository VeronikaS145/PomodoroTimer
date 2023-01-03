//
//  ViewController.swift
//  PomodoroTimer
//
//  Created by Nika Semenkova on 03.01.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Работа"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:25"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 45, weight: .bold)
        return label
    }()
    
    private lazy var startAndPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 70)
        button.setImage(UIImage(named: "play"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private properties
    private var timer = Timer()
    private var workTime: TimeInterval = 25
    private var relaxTime: TimeInterval = 10
    private var timerCounter = 1000
    
    private var isStarted = false
    private var isWorkTime = true
    private var isAnimationStarted = false
    
    private var progressLayer = CAShapeLayer()
    private var circleLayer = CAShapeLayer()
    private var startPoint = CGFloat(-Double.pi / 2)
    private var endPoint = CGFloat(3 * Double.pi / 2)
    
    // set gradient
    var gradientLayer: CAGradientLayer!
    
    private let firstColor = UIColor(#colorLiteral(red: 1, green: 0.7265934514, blue: 0.5481436793, alpha: 1))
    private let secondColor = UIColor(#colorLiteral(red: 0.6497644328, green: 0.5915143865, blue: 1, alpha: 1))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradientLayer(topColor: firstColor, bottomColor: secondColor)
        setupHierarchy()
        setupLayouts()
        createCircle()
    }
    
    // MARK: Setup
    
    private func setupHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(timeLabel)
        view.addSubview(startAndPauseButton)
    }
    
    private func setupLayouts() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(150)
            make.centerX.equalTo(view)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(100)
            make.centerX.equalTo(view)
        }
        
        startAndPauseButton.snp.makeConstraints { main in
            main.top.equalTo(timeLabel.snp.bottom).offset(20)
            main.centerX.equalTo(view)
        }
    }
    
    // MARK: - Actions
    
    @objc private func pressedButton() {
        if !isStarted {
            startTimer()
            setModeAnimation()
            startAndPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            startAndPauseButton.configuration?.baseBackgroundColor = .red
            isStarted = true
        } else {
            timer.invalidate()
            pauseAnimation(for: progressLayer)
            startAndPauseButton.setImage(UIImage(named: "play"), for: .normal)
            startAndPauseButton.configuration?.baseBackgroundColor = .green
            isStarted = false
        }
    }
    
    @objc private func timerMode() {
        if timerCounter > 0 {
            timerCounter -= 1
            return
        }
        
        timerCounter = 1000
        if isWorkTime {
            changeToRelax()
        } else {
            changeToWork()
        }
    }
    
    // MARK: - Private functions for timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerMode), userInfo: nil, repeats: true)
    }
    
    // Режим работы
    private func changeToRelax() {
        guard workTime > 1 else {
            stopAnimation()
            workTime = 25
            titleLabel.text = "Отдых"
            timeLabel.text = "00:10"
            startAndPauseButton.setImage(UIImage(named: "play"), for: .normal)
            progressLayer.strokeColor = UIColor.green.cgColor
            isStarted = false
            isWorkTime = false
            timer.invalidate()
            return
        }
        
        workTime -= 1
        timeLabel.text = String(format: "%02i:%02i", Int(workTime) / 60 % 60, Int(workTime) % 60)
    }
    
    // Режим отдыха
    private func changeToWork() {
        guard relaxTime > 1 else {
            stopAnimation()
            relaxTime = 10
            titleLabel.text = "Работа"
            timeLabel.text = "00:25"
            startAndPauseButton.setImage(UIImage(named: "play"), for: .normal)
            progressLayer.strokeColor = UIColor.red.cgColor
            isStarted = false
            isWorkTime = true
            timer.invalidate()
            return
        }
        
        relaxTime -= 1
        timeLabel.text = String(format: "%02i:%02i", Int(relaxTime) / 60 % 60, Int(relaxTime) % 60)
    }
    
    // MARK: - Private functions for progress bar
    
    private func createCircle() {
        let circle = UIBezierPath(arcCenter: CGPoint(x: view.frame.size.width / 2.0, y: view.frame.size.height / 2.35), radius: 100, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        
        // Set values for circle
        circleLayer.path = circle.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 10
        circleLayer.strokeEnd = 1
        circleLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.layer.addSublayer(circleLayer)
        
        // Set values for progress bar
        progressLayer.path = circle.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = #colorLiteral(red: 1, green: 0.4149405136, blue: 0.3453579257, alpha: 1)
        view.layer.addSublayer(progressLayer)
        
    }
    
    // Setting up animation modes
    private func resetAnimation() {
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        progressLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    
    private func startAnimation(duration: TimeInterval) {
        resetAnimation()
        isAnimationStarted = true
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
    
    private func pauseAnimation(for circle: CAShapeLayer) {
        let pauseTime = circle.convertTime(CACurrentMediaTime(), from: nil)
        circle.speed = 0.0
        circle.timeOffset = pauseTime
    }
    
    private func continueAnimation(for circle: CAShapeLayer) {
        let pauseTime = circle.timeOffset
        circle.speed = 1.0
        circle.timeOffset = 0.0
        circle.beginTime = 0.0
        let timeSincePaused = circle.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        circle.beginTime = timeSincePaused
    }
    
    private func stopAnimation() {
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        progressLayer.strokeEnd = 0.0
        progressLayer.removeAllAnimations()
        isAnimationStarted = false
    }
    
    private func changeTime() {
        if isWorkTime {
            startAnimation(duration: workTime)
        } else {
            startAnimation(duration: relaxTime)
        }
    }
    
    private func setModeAnimation() {
        if !isAnimationStarted{
            changeTime()
        } else {
            continueAnimation(for: progressLayer)
        }
    }
}
