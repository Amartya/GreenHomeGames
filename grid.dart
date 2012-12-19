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
 * Need a better class name
 */
class Grid extends Slidable {
  
  // thermal conductivity coefficient
  const K = 0.005;
  
  // furnace power
  const B = 1.0;
  
  // furnace efficiency
  const E = 0.2;
  
  // step time (5 minutes)
  const STEP = 5;

  // x-axis times  
  var TIMES = [ "12am", "2am", "4am", "6am", "8am", "10am", "noon", "2pm", "4pm", "6pm", "8pm", "10pm", "12pm" ];
  
  // y-axis temp range
  var TEMPS = [ 50, 55, 60, 65, 70, 75, 80, 85 ];

  // size of the grid
  double width, height;
  
  // current simulation time
  int simTime = 24 * 60;
  
  // is the furnace on or off
  bool furnace = false;
  
  // inside temperatures (F) over time
  List<double> temps;
  
  // cumulative energy use
  double energy = 0.0;
  
  // temperature velocity (used to smooth out the edges)
  double velocity = 0.0;
  
  
  Grid(double x, double y, this.width, this.height) : super(x, y) {
    temps = new List<double>();
  }

  
  void restart() {
    temps = new List<double>();
    temps.add(70.0);
    simTime = 0;
    energy = 0.0;
    animate();
  }
  
  
  void animate() {
    
    if (simTime >= 60 * 24) return;
    
    // current inside temperature
    double temp = getInsideTemperature(simTime);
    
    // advance time step
    simTime += STEP;  

    // set temperature    
    double stemp = getSetTemperature(simTime);
    
    // furnance turns on when actual temperature is less than the set temp
    furnace = (stemp > temp);

    // add to thermal velocity and total energy     
    if (furnace) {
      velocity += STEP * B * E;
      energy += STEP * B;
    }
    
    // temperature gradient
    double dT = temp - getOutsideTemperature(simTime);
    
    // temperature flux
    double q = K * dT * STEP;
    
    velocity -= q;
        
    // adjust the actual indoor temperature
    temps.add(temp + velocity);

    // apply "friction"    
    velocity *= 0.7;
    
    Game.repaint();
    
    window.setTimeout(animate, 30);
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    double gx = x + deltaX;
    double gy = y;
    double gw = width;
    double gh = height;
    
    ctx.lineWidth = 1;
    ctx.beginPath();
      
    // Vertical lines
    int gc = TIMES.length - 1;
    double gs = gw / gc;
    for (int i=1; i<gc; i++) {
      ctx.moveTo(gx + i * gs, gy);
      ctx.lineTo(gx + i * gs, gy + gh);
    }
      
    // Horizontal lines
    gc = TEMPS.length - 1;
    gs = gh / gc;
    for (int i=1; i<gc; i++) {
      ctx.moveTo(gx, gy + i * gs);
      ctx.lineTo(gx + gw, gy + i * gs);
    }

    // Bounding box      
    ctx.strokeStyle = "rgba(255, 255, 255, 0.6)";
    ctx.stroke();
    ctx.fillStyle = "rgba(255, 255, 255, 0.2)";
    ctx.fillRect(gx, gy, gw, gh);
    ctx.strokeStyle = "white";
    ctx.strokeRect(gx, gy, gw, gh);
    
    // Grid Labels
    ctx.font = "10pt Arial, sans-serif";
    ctx.fillStyle = "white";
    
    // Vertical labels
    ctx.textAlign = "center";
    ctx.textBaseline = "top";
    gc = TIMES.length - 1;
    gs = gw / gc;
    for (int i=1; i<gc; i++) {
      ctx.fillText(TIMES[i], gx + i * gs, gy + gh + 6);
    }
      
    // Horizontal labels
    ctx.textAlign = "left";
    ctx.textBaseline = "middle";
    gc = TEMPS.length - 1;
    gs = gh / gc;
    for (int i=0; i<=gc; i++) {
      ctx.fillText(TEMPS[gc-i].toString(), gx + gw + 6, gy + i * gs);
    }
    
    // temperature curve
    if (temps.length > 0) {
      double tx = timeToX(0) + deltaX;
      double ty = tempToY(temps[0]);
      ctx.beginPath();
      ctx.moveTo(tx, ty);

      for (int i=1; i<temps.length; i++) {
        tx = timeToX(i * STEP) + deltaX;
        ty = tempToY(temps[i]);
        ctx.lineTo(tx, ty);
      }
      ctx.lineTo(tx, gy + gh);
      ctx.lineTo(gx, gy + gh);
      ctx.closePath();
      ctx.fillStyle = "rgba(255, 255, 255, 0.5)";
      ctx.fill();
    }
  }
  
  
  double getSetTemperature(int time) {
    return 71.5;
  }
  
  
  double getOutsideTemperature(int time) {
    return 33.4;
  }
  
  
  double getInsideTemperature(int time) {
    int index = time ~/ STEP;
    if (index < temps.length) {
      return temps[index];
    } else {
      return 70.0;
    }
  }
 
   
  double timeToX(int time) {
    if (time <= 0) {  // 12am
      return x + 1;
    }
    else if (time >= 60 * 24) { // 12pm
      return x + width - 1;
    }
    else {
      return x + time * (width / (24 * 60));
    }
  }

   
  double tempToY(double temp) {
    if (temp <= 50) {
      return y + height - 1;
    }
    else if (temp >= 90) {
      return y + 1;
    }
    else {
      temp -= 50;
      return y + height - temp * (height / 35);
    }
  }

   
  double yToTemp(double ty) {
    if (ty < y) {
      return 85.0;
    } else if (ty > y + height) {
      return 50.0;
    } else {
      ty = 1 - ((ty - y) / height);
      return (50.0 + (35 * ty));
    }
  }
}
