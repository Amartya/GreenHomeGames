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

class Weather extends Slidable {
   
  ImageElement image;
  
   
  Weather(double x, double y) : super(x, y) {
    image = new ImageElement();
    image.src = "images/icy.png";
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    
    // weather icon
    int iw = image.width;
    int ih = image.height;
    ctx.drawImage(image, x - iw/2 + deltaX, y - ih/2, iw, ih);

    
    // high temperature
    /*
    ctx.font = "60px arial, sans-serif";
    ctx.textAlign = "right";
    ctx.textBaseline = "top";
    ctx.fillText("25", x + 160, y + 30);
    ctx.font = "14px arial, sans-serif";
    ctx.fillText("HIGH", x + 160, y + 90);
    
    ctx.strokeStyle = "white";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(x + 174, y + 45, 6, 0, 2 * PI, true);
    ctx.stroke();
    */
    
    // low temperature
    /*
    ctx.font = "60px arial, sans-serif";
    ctx.textAlign = "right";
    ctx.textBaseline = "top";
    ctx.fillText("2", x + width - 40, y + 30);
    
    ctx.font = "14px arial, sans-serif";
    ctx.fillText("LOW", x + width - 40, y + 90);
    ctx.beginPath();
    ctx.arc(x + width - 26, y + 45, 6, 0, 2 * PI, true);
    ctx.stroke();
    */
  }
}

