use rodio::{Decoder, Sink};
use std::fs::File;
use std::io::BufReader;
use std::sync::{Arc, Mutex};
use tokio::time;

use crate::messages::{QueueChange, SeekChange};

pub struct AudioPlayer {
    sink: Arc<Mutex<Sink>>,
    queue: Arc<Mutex<Vec<String>>>,
    current_index: Arc<Mutex<usize>>,
}

impl AudioPlayer {
    pub fn new(stream_handle: &rodio::OutputStreamHandle) -> Self {
        let sink = Sink::try_new(stream_handle).expect("Failed to create sink");
        AudioPlayer {
            sink: Arc::new(Mutex::new(sink)),
            queue: Arc::new(Mutex::new(Vec::new())),
            current_index: Arc::new(Mutex::new(0)),
        }
    }

    pub fn set_volume(&self, volume: f32) {
        let sink = self.sink.lock().unwrap();
        sink.set_volume(volume);
    }

    pub fn queue(
        &self,
        file_paths: &[String],
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let mut queue = self.queue.lock().unwrap();
        queue.extend(file_paths.iter().cloned());
        Ok(())
    }

    pub fn clear_queue(&self) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let mut queue = self.queue.lock().unwrap();
        let mut index = self.current_index.lock().unwrap();
        queue.clear();
        *index = 0;
        Ok(())
    }

    pub async fn fill(&self) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        loop {
            let sink_empty = self.sink.lock().unwrap().empty();
            let queue_len = self.queue.lock().unwrap().len();

            if sink_empty && queue_len > 0 {
                {
                    let mut index = self.current_index.lock().unwrap();
                    // Move to next song
                    *index += 1;
                    // If index overflows go back to first song

                    if *index >= queue_len {
                        *index = 0;
                    }
                    // TODO: Dangerous cast here
                    println!("RUST-> Sending QUEUECHANGE Event to Dart {}", *index);
                    QueueChange {
                        current_rust_index: *index as i32,
                    }
                    .send_signal_to_dart();
                }
                self.play();
            }

            time::sleep(std::time::Duration::from_millis(500)).await; // Non-blocking sleep
        }
    }

    pub async fn notify_of_seek(&self) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        loop {
            let sink_empty = self.sink.lock().unwrap().empty();
            let sink_is_paused = self.sink.lock().unwrap().is_paused();

            if !sink_empty && !sink_is_paused {
                let sink_pos = self.sink.lock().unwrap().get_pos();
                // println!("RUST-> Sink position {}", sink_pos.as_secs());
                // TODO: Dangerous cast here
                SeekChange {
                    current_seek_value: sink_pos.as_secs() as i32,
                }
                .send_signal_to_dart();
            }

            time::sleep(std::time::Duration::from_millis(900)).await; // Non-blocking sleep
        }
    }

    pub fn play(&self) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let queue = self.queue.lock().unwrap();
        let index = self.current_index.lock().unwrap();
        // eprintln!("Should go too {} {}", *index, queue.len());

        if *index < queue.len() {
            let file_path = &queue[*index];
            let file = File::open(file_path)?;
            let decoder = Decoder::new(BufReader::new(file))?;
            let sink = self.sink.lock().unwrap();
            sink.append(decoder);
            sink.play();
            drop(sink);
        }
        Ok(())
    }

    pub fn pause(&self) {
        let sink = self.sink.lock().unwrap();
        if !sink.is_paused() {
            sink.pause();
        }
    }

    pub fn resume(&self) {
        let sink = self.sink.lock().unwrap();
        if sink.is_paused() {
            sink.play();
        }
    }

    pub fn stop(&self) {
        let sink = self.sink.lock().unwrap();
        sink.stop();
    }

    pub fn next(&self) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        {
            // Current index lock dropped here
            let queue_len = self.queue.lock().unwrap().len() - 1;
            let mut index = self.current_index.lock().unwrap();
            if *index < queue_len {
                *index += 1;
            } else {
                *index = 0;
            }
        }
        self.stop();
        self.play();
        Ok(())
    }

    pub fn previous(&self) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        {
            // Current index lock dropped here
            let queue_len = self.queue.lock().unwrap().len() - 1;
            let mut index = self.current_index.lock().unwrap();
            if *index > 0 {
                *index -= 1;
            } else {
                *index = queue_len;
            }
        }
        self.stop();
        self.play();
        Ok(())
    }
}
