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


abstract class Thermostat {
  
  double settemp = 70.0;
  
  // returns the set temperature for the given time of day
  double getSetTemperature(int hour, int minute) {
    return settemp;
  }
  
  void setTemperature(double t) {
    settemp = t;
  }
  
  
  void draw();
  
}


class RoundThermostat extends Thermostat {
  
  const MIN_ANGLE = -PI / 2.3;
  const MAX_ANGLE = PI / 2.3;
  ImageElement dial;
  ImageElement shell;

  int width = 600, height = 600;

  bool down = false;

  double angle = 0.0;
  
  double lastX, lastY;
  
  CanvasRenderingContext2D ctx;
  
  Game game;
  
  
  RoundThermostat(this.game) {
    
    CanvasElement canvas = document.query("#thermostat");
    ctx = canvas.getContext("2d");
    width = canvas.width;
    height = canvas.height;
    
    dial = new ImageElement();
    dial.src = "images/round_dial.png";
    shell = new ImageElement();
    shell.src = "images/round_shell.png";
    shell.on.load.add((evt) => draw());
    
    // Register mouse events
    canvas.on.mouseDown.add((e) => mouseDown(e), true);
    canvas.on.mouseUp.add((e) => mouseUp(e), true);
    canvas.on.mouseMove.add((e) => mouseMove(e), true);

    // Register touch events
    canvas.on.touchStart.add((e) => touchDown(e), true);
    canvas.on.touchMove.add((e) => touchDrag(e), true);
    canvas.on.touchEnd.add((e) => touchUp(e), true);
    
  }
  
  
  void setTemperature(double t) { }
  
  
  void draw() {
    double ix = 0.0;
    double iy = 0.0;
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
  
  
  double getSetTemperature(int hour, int minute) {
    
    // round thermostat has a constant temperature all day long
    return getTemperature().toDouble();
  }
  
  
  void mouseUp(MouseEvent evt) {
    down = false;
  }
  
  
  void mouseDown(MouseEvent evt) {
    lastX = evt.offsetX.toDouble();
    lastY = evt.offsetY.toDouble();
    down = true;
  }
   
  
  void mouseMove(MouseEvent evt) {
    if (down) {
      
      double tx = evt.offsetX.toDouble();
      double ty = evt.offsetY.toDouble();
      num a1 = atan2(lastX - width/2.0, lastY - height/2);
      num a2 = atan2(tx - width/2.0, ty - height/2);
      angle -= (a2 - a1); 
      if (angle > PI) angle -= PI * 2;
      if (angle < -PI) angle += PI * 2;
      angle = min(angle, MAX_ANGLE);
      angle = max(angle, MIN_ANGLE);
      draw();
      lastX = tx;
      lastY = ty;
    }
  }
  
  
  void touchDown(TouchEvent tframe) {
    for (var te in tframe.changedTouches) {
    }
  }
  
  
  void touchUp(var tframe) {
    for (var te in tframe.changedTouches) {
    }
  }
  
  
  void touchDrag(var tframe) {
    for (var te in tframe.changedTouches) {
    }
  } 
  
}