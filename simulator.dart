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


class Simulator {
   
  // step time (5 minutes)
  const STEP = 5;

  // x-axis times  
  var TIMES = [ "12am", "2am", "4am", "6am", "8am", "10am", "noon", "2pm", "4pm", "6pm", "8pm", "10pm", "12pm" ];
  
  // y-axis temp range
  var TEMPS = [ 55, 60, 65, 70, 75, 80 ];
  
  // size of the simulation display
  int width = 500, height = 400;
  
  // current simulation time
  int simTime = 24 * 60;
  
  // inside temperatures (F) over time
  List<double> temps;
  
  // cumulative energy use
  double energy = 0.0;
  
  // temperature velocity (used to smooth out the edges)
  double velocity = 0.0;
  
  // reference to the game engine
  Game game;
  
  // callback for when the simulation is finished running
  Function onDone = null;
  
  // callback for when the simulation is starting
  Function onStart = null;
  
  // drawing context
  CanvasRenderingContext2D ctx;
  
  
  Simulator(this.game) {
    CanvasElement canvas = document.query("#simulator");
    ctx = canvas.getContext("2d");
    width = canvas.width;
    height = canvas.height;
    
    // Register mouse events
    canvas.on.mouseDown.add((e) => mouseDown(e), true);
    canvas.on.mouseUp.add((e) => mouseUp(e), true);
    canvas.on.mouseMove.add((e) => mouseMove(e), true);

    // Register touch events
    canvas.on.touchStart.add((e) => touchDown(e), true);
    canvas.on.touchMove.add((e) => touchDrag(e), true);
    canvas.on.touchEnd.add((e) => touchUp(e), true);
    
    clear();
  }
  
  
  void clear() {
    temps = new List<double>();
    temps.add(70.0);
    simTime = 0;
    energy = 0.0;
  }


  void run() {
    if (simTime == 0 && onStart != null) onStart();

    bool b = step();
    draw();
    if (b) {
      window.setTimeout(run, 20);
    } else if (onDone != null) {
      onDone();
    }
  }
  
  
  double getCurrentTemperature() {
    return getTemperature(simTime);
  }
  
  
  double getAverageTemperature() {
    if (temps.length == 0) {
      return 70.0;
    } else {
      double avg = 0.0;
      for (double t in temps) {
        avg += t;
      }
      return avg / temps.length;
    }
  }
  
  
  double getTemperature(int time) {
    int index = time ~/ STEP;
    if (index >= 0 && index < temps.length) {
      return temps[index];
    } else {
      return 70.0;
    }
  }
  
  
  int get bill {
    double C = double.parse(window.localStorage['valueC']); 
    return (energy * C / 10.0).toInt() * 10;
  }
  
  
  bool step() {
    
    // insulation value
    double R = double.parse(window.localStorage['valueR']);
    double K = (1 - R) / 175;
    
    // furnace power
    double B = double.parse(window.localStorage['valueB']); 
    
    // furnace efficiency
    double E = double.parse(window.localStorage['valueE']);

    // only simulate 24 hours
    if (simTime >= 60 * 24) return false;
    
    // Reference to our weather model with outside temperatures    
    Weather weather = game.weather;
    
    // Reference to the thermostat with set temperatures
    Thermostat thermostat = game.thermostat;
    
    // current inside temperature
    double temp = getCurrentTemperature();
    
    // advance time step
    simTime += STEP;
    
    // thermostat set temperature
    double stemp = thermostat.getSetTemperature(simTime);

    // add to the thermal velocity and total energy
    if (thermostat.heating && stemp > temp) {
      velocity += STEP * B * E;
      energy += STEP * B;
    }
    else if (thermostat.cooling && stemp < temp) {
      velocity -= STEP * B * E;
      energy += STEP * B;
    }
    
    // temperature gradient
    double outside = weather.getTemperature(simTime ~/ 60, simTime % 60);
    double dT = temp - outside;

    // temperature flux
    double q = K * dT * STEP;
    
    velocity -= q;
    
    // adjust the actual indoor temperature
    temps.add(temp + velocity);
    
    // apply "friction"
    velocity *= 0.85;
    
    // compute comfort scores
    for (Person p in game.family.people) {
      p.updateComfortScore(temps, STEP);
    }
    
    return true;
  }

    
  void draw() {
    
    ctx.clearRect(0, 0, width, height);
    
    double gx = 25.0;
    double gy = 10.0;
    double gw = width.toDouble() - 50;
    double gh = height.toDouble() - 80;
    
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
    ctx.strokeStyle = "rgba(255, 255, 255, 0.6)";
    ctx.stroke();
    

    // Bounding box      
    ctx.fillStyle = "rgba(255, 255, 255, 0.1)";
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
    
    
    // draw comfort zones
    for (Person p in game.family.people) {
      if (p.show_zones) {
        drawComfortZones(p.zones);
      }
    }
    
    
    // temperature curve
    if (temps.length > 0) {
      
      double x0, y0, x1, y1, t0, t1;
      
      t0 = temps[0];
      x0 = timeToX(0);
      y0 = tempToY(t0);
      ctx.beginPath();
      ctx.moveTo(x0, y0);
      
      for (int i=1; i<temps.length; i++) {
        t1 = temps[i];
        x1 = timeToX(i * STEP);
        y1 = tempToY(t1);
        
        ctx.lineTo(x1, y1);
        
        x0 = x1; y0 = y1; t0 = t1;
      }
      ctx.strokeStyle = "white";
      ctx.lineWidth = 2;
      ctx.stroke();

      ctx.lineTo(x0, gy + gh);
      ctx.lineTo(x0, gy + gh);
      ctx.lineTo(gx, gy + gh);
      
      ctx.closePath();
      ctx.fillStyle = "rgba(255, 255, 255, 0.1)";
      ctx.fill();
    }
    

    // energy use so far
    ctx.font = "18px sans-serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "top";
    ctx.fillStyle = "white";
    String str = "Energy: ${energy.toInt()} kWh";
    ctx.fillText(str, gx + gw / 2, gy + gh + 40);
    
    Element el = document.query("#running-bill");
    if (el != null) {
      el.innerHtml = "\$${bill}";
    }
  }
  
  
  void drawComfortZones(ComfortZones zones) {
    
    // Comfort zones
    ctx.textAlign = "left";
    ctx.textBaseline = "top";
    ctx.font = "10pt Arial, sans-serif";
    ctx.fillStyle = "rgba(0, 0, 0, 0.8)";
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
    num sw = (tempToY(60) - tempToY(64));  // stroke width = 4degrees
    ctx.lineWidth = sw;
    
    for (Zone zone in zones.zones) {
      ctx.beginPath();
      double x0 = timeToX(zone.start);
      double x1 = timeToX(zone.end);
      double y0 = tempToY(zone.temp);

      if (x0 > x1) {
        ctx.moveTo(timeToX(0), y0);
        ctx.lineTo(x1, y0);
        ctx.moveTo(x0, y0);
        ctx.lineTo(timeToX(24 * 60), y0);
       } else {
        ctx.moveTo(x0, y0);
        ctx.lineTo(x1, y0);
      }
      ctx.stroke();
      ctx.fillText(zone.name, x0 + 6, y0 - sw / 2 + 6);
    
    }
    ctx.fillText(zones.night.name, timeToX(0) + 6, tempToY(zones.night.temp) - sw / 2 + 6);
  }

  
  double timeToX(int time) {
    num x = 25;
    num w = width - 50;
    if (time <= 0) {  // 12am
      return x + 1.0;
    }
    else if (time >= 60 * 24) { // 12pm
      return x + w - 1.0;
    }
    else {
      return x + time * (w / (24 * 60));
    }
  }

   
  double tempToY(num temp) {
    num y = 10;
    num h = height - 80;
    
    if (temp <= 55) {
      return y + h - 1.0;
    }
    else if (temp >= 80) {
      return y + 1.0;
    }
    else {
      temp -= 55;
      return y + h - temp * (h / 25);
    }
  }

   
  double yToTemp(double ty) {
    num y = 10;
    num h = height - 80;
    if (ty < y) {
      return 85.0;
    } else if (ty > y + h) {
      return 50.0;
    } else {
      ty = 1 - ((ty - y) / h);
      return (50.0 + (35 * ty));
    }
  }
  
  bool down = false;
  
  void mouseUp(MouseEvent evt) {
    down = false;
  }
  
  
  void mouseDown(MouseEvent evt) {
    clear();
    run();
    down = true;
  }
   
  
  void mouseMove(MouseEvent evt) {
    if (down) {    }
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

