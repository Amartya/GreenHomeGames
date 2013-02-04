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
 * Right now this looks like a horizontal bar showing percentage filled
 */
class Indicator {

  // name of the indicator
  String label = "Pollution";
  
  // percent full
  int percent = 0;
  
  // total amount
  int total = 0;
  
  // unit
  String unit = "pounds carbon dioxide";
  
  double x, y;
  
  Indicator(this.x, this.y);

  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'right';
    ctx.font = "50px 'Wendy One', sans-serif";
    ctx.fillStyle = "rgba(255, 255, 255, 0.8)";
    ctx.fillText(label, x, y);
    
    ctx.font = "30px 'Share Tech', sans-serif";
    ctx.textAlign = 'left';
    ctx.fillText("${percent}%", x + 390, y);
    
    ctx.font = "16px 'Share Tech', sans-serif";
    ctx.textBaseline = 'top';
    ctx.fillText("${total} ${unit}", x + 40, y + 27);
    
    ctx.fillStyle = "rgba(255, 255, 255, 0.2)";
    ctx.fillRect(x + 30, y - 25, 350, 50);
    
    ctx.fillStyle = "rgba(255, 255, 255, 0.4)";
    ctx.fillRect(x + 30, y - 25, 350 * percent / 100.0, 50);
  }
}