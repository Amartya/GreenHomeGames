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
 * Number spinner for month and day
 */
class Spinner {
   
  var VALUES = [ "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" ];
   
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
   
  // alignment ("left" or "right")
  String align = "left";
   
   
  Spinner(this.x, this.y, this.width, this.height);
  

/*
 * Randomly spin to a new index
 */
  void spin() {
    force = 0.15 + rand.nextDouble() * 0.1;
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
    tween.onend = () { angle = incr * index; animate(); };
    tween.play();
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
    CanvasRenderingContext2D ctx = Game.ctx;

    ctx.save();
      
    ctx.fillStyle = "#223";
    ctx.fillRect(x, y, width, height);
     
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x + width, y);
    ctx.lineTo(x + width, y + height);
    ctx.lineTo(x, y + height);
    ctx.closePath();
    ctx.clip();
     
    ctx.font = "30px 'Share Tech', sans-serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillStyle = "white";
    ctx.shadowColor = "black";
    ctx.shadowOffsetX = 1;
    ctx.shadowOffsetY = 1;
    ctx.shadowBlur = 4;
      
    double r = (align == "right") ? -8.0 : 8.0;
    r *= VALUES.length;
    ctx.save();
    ctx.translate(x + width/2 - r, y + height/2);
    ctx.rotate(angle);
    for (int i=0; i<VALUES.length; i++) {
      ctx.fillText(VALUES[i].toString(), r, 2);
      ctx.rotate(PI * -2 / VALUES.length);
    }
    ctx.restore();
      
    ctx.lineWidth = 1;
    ctx.strokeStyle = "black";
    ctx.strokeRect(x, y, width, height);
    
    ctx.restore();  // from clip
  }
}