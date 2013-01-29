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
library GreenHomeGames;

import 'dart:html';
import 'dart:math';
import 'dart:web_audio';
import 'touch.dart';

part 'game.dart';
part 'simulator.dart';
part 'indicator.dart';
part 'sounds.dart';
part 'spinner.dart';
part 'thermostat.dart';
part 'tween.dart';
part 'weather.dart';


void main() {
  TouchManager.init();
  new Game();
}
