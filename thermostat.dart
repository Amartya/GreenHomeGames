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


class RoundThermostat extends Slidable implements Touchable {
  
  const MIN_ANGLE = -PI / 2.3;
  const MAX_ANGLE = PI / 2.3;
  ImageElement dial;
  ImageElement shell;

  int width = 600;
  int height = 600;
  bool down = false;
  double angle = 0.0;
  double lastX, lastY;
  
  
  
  RoundThermostat(double x, double y) : super(x, y) {
    Sounds.loadSound("heater");
    dial = new ImageElement();
    dial.src = "images/round_dial.png";
    dial.on.load.add((event) {
      width = dial.width;
      height = dial.height;
    }, true);
    
    shell = new ImageElement();
    shell.src = "images/round_shell.png";
    
    TouchManager.addTouchable(this, "game");
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    double ix = x + deltaX;
    double iy = y;
    double iw = dial.width.toDouble();
    double ih = dial.height.toDouble();
    ctx.save();
    ctx.translate(ix + iw ~/ 2, iy + ih ~/ 2);
    ctx.drawImage(shell, iw ~/ -2, ih ~/ -2);
    ctx.rotate(angle);
    ctx.drawImage(dial, iw ~/ -2, ih ~/ -2 + 1, iw, ih);
    ctx.restore();
  }
  
  
  int getTemperature() {
    return (70 + (angle / PI) * 180 * 0.36).round().toInt();
  }
  
  
  // Return true iff touch intersects with the given object
  bool containsTouch(Contact event) {
    num tx = event.touchX - deltaX;
    num ty = event.touchY;
    return (tx >= x && ty >= y && tx <= x + width && ty <= y + height);
  }
  
  
  bool touchDown(Contact event) {
    down = true;
    lastX = event.touchX - deltaX;
    lastY = event.touchY;
    return true;
  }
  
  
  void touchUp(Contact event) {
    down = false;
    Sounds.playSound("heater");
    Game.repaint();
  }
  
  
  // This gets fired only after a touchDown lands on the touchable object
  void touchDrag(Contact event) {
    double tx = event.touchX - deltaX;
    double ty = event.touchY;
    num a1 = atan2(lastX - x - width/2.0, lastY - y - height/2);
    num a2 = atan2(tx - x - width/2.0, ty - y - height/2);
    angle -= (a2 - a1); 
    if (angle > PI) angle -= PI * 2;
    if (angle < -PI) angle += PI * 2;
    angle = min(angle, MAX_ANGLE);
    angle = max(angle, MIN_ANGLE);
    Game.repaint();
    lastX = tx;
    lastY = ty;
  }
  
  
  // This gets fired when an unbound touch events slides over an object
  void touchSlide(Contact event) { }
}