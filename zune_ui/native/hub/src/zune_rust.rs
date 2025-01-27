//! This module is written for Rinf demonstrations.
use rinf::debug_print;
use std::sync::Arc;

use crate::audio_player::AudioPlayer;
use crate::messages::*;

// Though async tasks work, using the actor model
// is highly recommended for state management
// to achieve modularity and scalability in your app.
// To understand how to use the actor model,
// refer to the Rinf documentation.

// pub async fn queue_thread(audio_player: Arc<AudioPlayer>)

pub async fn play_pause_request(
    audio_player: Arc<AudioPlayer>,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let receiver = PlayPauseTrackAtPath::get_dart_signal_receiver(); // GENERATED

    while let Some(dart_signal) = receiver.recv().await {
        let signal_data = dart_signal.message;
        let file_paths = signal_data.paths;
        let request_action = signal_data.action;

        // debug_print prints in flutter console
        println!(
            "RUST-> Change PlayPauseRequest: [ value: {} ]",
            request_action
        );

        match request_action.as_str() {
            "resume_action" => {
                audio_player.resume();
            }
            "pause_action" => {
                audio_player.pause();
            },
            "next_action" => {
                audio_player.next()?;
            },
            "previous_action" => {
                audio_player.previous()?;
            },
            "play_action" => {
                audio_player.play()?;
            },
            "clean_queue_action" => {
                audio_player.stop();
                audio_player.clear_queue()?;
                audio_player.queue(&file_paths)?;
                audio_player.play()?;
            }
            _ => {
                audio_player.queue(&file_paths)?;
            },
        }
    }
    Ok(())
}

pub async fn change_volume_request(
    audio_player: Arc<AudioPlayer>,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let receiver = VolumeChange::get_dart_signal_receiver(); // GENERATED

    while let Some(dart_signal) = receiver.recv().await {
        let signal_data = dart_signal.message;
        let value = signal_data.value;
        let max = signal_data.max;

        let volume = value / max;
        debug_print!("RUST-> Change VolumeEvent: [ value: {} ]", volume);

        audio_player.set_volume(volume);
    }
    Ok(())
}
