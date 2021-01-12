//
//  TreckDetailView.swift
//  iMusic1
//
//  Created by Тимур Мусаханов on 8/17/20.
//  Copyright © 2020 Тимур Мусаханов. All rights reserved.
//

import UIKit
import AVKit

class TreckDetailView: UIView {
    
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var miniGoForwardButton: UIButton!
    @IBOutlet weak var maxizedStackView: UIStackView!
    @IBOutlet weak var miniTrackImageView: UIImageView!
    @IBOutlet weak var miniTrackTitleLabel: UILabel!
    
    let scale: CGFloat = 0.8
    @IBOutlet weak var trackImageView: UIImageView! {
        didSet {
            trackImageView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            trackImageView.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var authorTitleLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            playPauseButton.layer.shadowOpacity = 0.5
            playPauseButton.layer.shadowRadius = 5
        }
    }
    @IBOutlet weak var volumeSlider: UISlider!
    
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    weak var delegate: TrackMovingDelegate?
    
    let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestures()
    }
    
    func set(viewModal: Track) {
        trackTitleLabel.text = viewModal.trackName
        authorTitleLabel.text = viewModal.artistName
        miniTrackTitleLabel.text = viewModal.trackName
        
        playTreck(previewTrack: viewModal.previewUrl)
        monitorStartTime()
        observeOlayerCurrentTime()
        
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
        let imageString600 = viewModal.artworkUrl100?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let imageUrl = URL(string: imageString600 ?? "") else { return }
        trackImageView.sd_setImage(with: imageUrl, completed: nil)
        miniTrackImageView.sd_setImage(with: imageUrl, completed: nil)
    }
    
    
    // MARK: - Animate
    private func enlargeTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.trackImageView.transform = .identity
        }, completion: nil)
    }
    
    private func reduceTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.trackImageView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
        }, completion: nil)
    }
    
    
    // MARK: - GestureRecognizer
    private func setupGestures() {
        miniTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized)))
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanMaximized)))
        maxizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    @objc func handleTapMaximized() {
        tabBarDelegate?.maximizedTrackDeatilController(viewModel: nil)
    }
    
    @objc func handlePanMaximized(gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .changed:
                handlePanChanged(gesture: gesture)
            case .ended:
                handlePanEnded(gesture: gesture)
            default:
                print("unknown default")
            }
    }
    
    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maxizedStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.tabBarDelegate?.maximizedTrackDeatilController(viewModel: nil)
            } else {
                self.miniTrackView.alpha = 1
                self.maxizedStackView.alpha = 0
            }
        }, completion: nil)
    }
    
    
    @objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.transform = .identity
                if translation.y > 50 {
                    self.tabBarDelegate?.minimizedTrackDeatilController()
                }
            }, completion: nil)
        default:
            print("unknown default1")
        }
    }
    
    
    private func playTreck(previewTrack: String?) {
        guard let imageUrl = URL(string: previewTrack ?? "") else { return }
        let playerItem = AVPlayerItem(url: imageUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    
    // MARK: Time setup
    //отслеживания время начала трека для анимации картнки
    private func monitorStartTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [ weak self ] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func observeOlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLabel.text = "-\(currentDurationText)"
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    
    
    @IBAction func playPauseAction() {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            reduceTrackImageView()
        }
    }
    
    @IBAction func nextTrack() {
        guard let cellViewModel = delegate?.moveForwardForPreviousTrack() else { return }
        set(viewModal: cellViewModel)
    }
    
    @IBAction func previousTrack() {
        guard let cellViewModel = delegate?.moveBackForPreviousTrack() else { return }
        set(viewModal: cellViewModel)
    }
    
    @IBAction func hanldeVolumeSlider() {
        player.volume = volumeSlider.value
    }
    
    @IBAction func handleCurrentTimeSlider() {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeUnSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeUnSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func dragDownButtonTapped() {
            tabBarDelegate?.minimizedTrackDeatilController()
    //        self.removeFromSuperview()
        }

}
