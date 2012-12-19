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
 * Superclass for an object that can slide on or off the screen
 */
class Slidable {

  // location on the screen
  double x, y;
  
  // used to slide on or off the page
  double deltaX = 0.0, deltaY = 0.0;
  
  // For animating transitions
  Tween tween;
  
  
  Slidable(this.x, this.y);

  
/*
 * Move offscreen to hide object (without animation)
 */
  void hide() {
    deltaX = 2000.0;
  }

/*
 * Slides object off the screen (to the left for now)
 */
  void slideOff(int delay) {
    tween = new Tween();
    tween.function = TWEEN_DECAY;
    tween.addControlPoint(0.0, 0);
    tween.addControlPoint(-1500.0, 1);
    tween.duration = 40;
    tween.delay = delay;
    tween.ontick = (value) { deltaX = value; Game.repaint(); };
    tween.play();
  }
  

/*
 * Slides an object on the screen (from the right)
 */
  void slideOn(int delay) {
    tween = new Tween();
    tween.function = TWEEN_DECAY;
    tween.addControlPoint(1000.0, 0);
    tween.addControlPoint(0.0, 1);
    tween.duration = 20;
    tween.delay = delay;
    tween.ontick = (value) { deltaX = value; Game.repaint(); };
    tween.play();
  }
}