//! This `hub` crate is the
//! entry point of the Rust logic.

use audio_player::AudioPlayer;
use rodio::OutputStream;
use std::sync::Arc;

mod audio_player;
mod messages;
mod zune_rust;

rinf::write_interface!();

// You can go with any async library, not just `tokio`.
#[tokio::main(flavor = "current_thread")]
async fn main() {
    let (_stream, stream_handle) =
        OutputStream::try_default().expect("Failed to create output stream");
    let audio_player = Arc::new(AudioPlayer::new(&stream_handle));

    // Spawn concurrent tasks.
    // Always use non-blocking async functions like `tokio::fs::File::open`.
    // If you must use blocking code, use `tokio::task::spawn_blocking`
    // or the equivalent provided by your async library.
    let audio_player_for_play_pause = Arc::clone(&audio_player);

    tokio::spawn(zune_rust::play_pause_request(audio_player_for_play_pause));

    let audio_player_for_change_volume = Arc::clone(&audio_player);
    tokio::spawn(zune_rust::change_volume_request(
        audio_player_for_change_volume,
    ));

    // Helper thread for syncing queue/seek information with dart
    let audio_player_monitoring = Arc::clone(&audio_player);
    tokio::spawn(async move {
        if let Err(e) = audio_player_monitoring.helper_thread().await {
            eprintln!("Error in notify_of_seek loop: {}", e);
        }
    });

    // Keep the main function running until Dart shutdown.
    rinf::dart_shutdown().await;
}
