/*
 * Green Home Games
 *
 * Michael S. Horn
 * Northwestern University
 * michael-horn@northwestern.edu
 * Copyright 2012, Michael S. Horn
 *
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
part of GreenHomeGames;


/*
 * A couple of convenience methods for playing sounds
 */
class Sounds {

  static AudioContext audio = new AudioContext();
  static Map sounds = new Map();


  static void loadSound(String name) {
    HttpRequest http = new HttpRequest();
    http.responseType = "arraybuffer";
    http.on.loadEnd.add((e) {
      audio.decodeAudioData(
          http.response, 
          (buffer) { sounds[name] = buffer; }, 
          (err) => print(err));
    });
    http.open('GET', "sounds/$name.wav");
    http.send();
  }


  static void playSound(String name) {
     if (sounds[name] == null) return;
     AudioBufferSourceNode source = audio.createBufferSource();
     source.connect(audio.destination, 0, 0);
     source.buffer = sounds[name];
     source.loop = false;
     source.gain.value = 0.2;
     source.playbackRate.value = 1;
     source.start(0);
  }
}