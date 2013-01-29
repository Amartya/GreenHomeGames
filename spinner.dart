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
 * Combined date spinner with month and day
 */
class DateSpinner {
  
  // Month spinner
  Spinner mspin;
  
  // Day of month spinner
  Spinner dspin;

  // dimensions on the screen  
  int width = 320, height = 60;
  
  // callback for spin completion
  Function onDone = null;
  
  // Drawing context
  CanvasRenderingContext2D ctx;
  
  // Is the mouse down
  bool mdown = false;
  
  // Reference to the game engine
  Game game;
  
  
  DateSpinner(this.game) {
    
    // Load canvas and drawing context
    CanvasElement canvas = document.query("#spinner");
    width = canvas.width;
    height = canvas.height;
    ctx = canvas.getContext("2d");

    // create the month spinner    
    mspin = new Spinner(0, 0, 200, height, ctx);
    mspin.VALUES = Weather.MONTHS;
    mspin.onDone = () {
      game.hideWeather();
    };

    // create day spinner    
    dspin = new Spinner(220, 0, 100, height, ctx);
    setDayValues();
    dspin.onDone = () {
      game.setDate(mspin.index + 1, dspin.index + 1);
      game.showWeather();
    };
    
    // Register mouse events
    canvas.on.mouseDown.add((e) => mouseDown(e), true);
    canvas.on.mouseUp.add((e) => mouseUp(e), true);
    canvas.on.mouseMove.add((e) => mouseMove(e), true);

    // Register touch events
    canvas.on.touchStart.add((e) => touchDown(e), true);
    canvas.on.touchMove.add((e) => touchDrag(e), true);
    canvas.on.touchEnd.add((e) => touchUp(e), true);
  }
  
  
  void setDate(int month, int day) {
    mspin.setIndex(month - 1);
    setDayValues();
    dspin.setIndex(day - 1);
  }
  
  
  int get month => mspin.index + 1;
  
  int get day => dspin.index + 1;
  
  
  void draw() {
    mspin.draw();
    dspin.draw();
  }
  
  
  void setDayValues() {
    int m = mspin.index + 1;
    int d = 31;
    
    // 30 days hath September ...
    if (m == 9 || m == 4 || m == 6 || m == 11) {
      d = 30;
    } else if (m == 2) {
      d = 28;
    }
    
    dspin.VALUES = [];
    for (int i=1; i<=d; i++) dspin.VALUES.add(i);
  }
  
  
  void mouseUp(MouseEvent evt) {
    mdown = false;
  }
  
  
  void mouseDown(MouseEvent evt) {
    if (evt.offsetX <= 200) {
      mspin.moveTo(mspin.index + 1);
      setDayValues();
    } else if (evt.offsetX >= 220) {
      dspin.spin();
    }
    mdown = true;
  }
  
  
  void mouseMove(MouseEvent evt) {
    if (mdown) {
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


/*
 * Number spinner for month and day
 */
class Spinner {
   
  var VALUES = [];
   
  Random rand = new Random();
  
  // position on the canvas
  int x, y, width, height;
   
  // tween for spinning to a set value
  Tween tween;
   
  // index displayed on the spinner
  int index = 0;
   
  // current rotation of the spinner
  double angle = 0.0;
   
  // angular force for spins
  double force = 0.0;
  
  // callback for when the spin is complete
  Function onDone = null;
  
  // canvas rendering context
  CanvasRenderingContext2D ctx;
  
   
  Spinner(this.x, this.y, this.width, this.height, this.ctx);
  

/*
 * Randomly spin to a new index
 */
  void spin() {
    force = 0.15 + rand.nextDouble() * 0.15;
    animate();
  }
   
   
/*
 * Change to a given index
 */
  void moveTo(int i) {
    int delta = i - index;
    double incr = PI * 2 / VALUES.length;
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.addControlPoint(0, 0);
    tween.addControlPoint(incr * delta + incr * 0.02, 1);
    tween.duration = min(delta.abs() * 15, 60);
    tween.ondelta = (value) { angle += value; animate(); };
    tween.onend = () {
      angle = incr * index;
      animate();
      if (onDone != null) onDone();
    };
    tween.play();
  }
   
  
  void setIndex(int i) {
    index = i;
    double incr = PI * 2 / VALUES.length;
    angle = incr * index;
  }
  
   
  void animate() {
    double incr = PI * 2 / VALUES.length;
    if (force != 0) {
      angle += force;
      force *= 0.975;
      if (force.abs() < 0.01) {
        force = 0.0;
        angle = incr * index;
        Sounds.playSound("tick");
        if (onDone != null) {
          onDone();
        }
      }
      window.setTimeout(animate, 30);
    }
    
    while (angle > incr * index + incr * 0.5) {
      index++;
      if (index >= VALUES.length) {
        index = 0;
        angle -= PI * 2;
      }
      Sounds.playSound("tick");
    }
    draw();
  }

   
  void draw() {
    ctx.save();
    ctx.translate(x, y);
    
    ctx.clearRect(0, 0, width, height);
    ctx.fillStyle = "rgba(255, 255, 255, 0.95)"; //"rgba(0, 0, 0, 0.3)";
    ctx.fillRect(0, 0, width, height);
     
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(width, 0);
    ctx.lineTo(width, height);
    ctx.lineTo(0, height);
    ctx.closePath();
    ctx.clip();
    
    ctx.strokeStyle = "black";
    ctx.strokeRect(0, 0, width, height);
     
    ctx.font = "46px sans-serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillStyle = "black"; //"white";
    ctx.shadowColor = "#666"; //"black";
    ctx.shadowOffsetX = 1;
    ctx.shadowOffsetY = 1;
    ctx.shadowBlur = 2;
      
    double r = 16.0;
    r *= VALUES.length;
    ctx.save();
    ctx.translate(width/2 - r, height/2);
    ctx.rotate(angle);
    for (int i=0; i<VALUES.length; i++) {
      ctx.fillText(VALUES[i].toString(), r, 2);
      ctx.rotate(PI * -2 / VALUES.length);
    }
    ctx.restore();
      
    ctx.lineWidth = 1;
    ctx.strokeStyle = "black";
    ctx.strokeRect(0, 0, width, height);
    
    ctx.restore();  // from clip
  }
}