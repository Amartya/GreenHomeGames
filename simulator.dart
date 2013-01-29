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
   
  // insulation value
  double R = 0.3;
  
  // thermal conductivity coefficient
  double K = 0.003;
  
  // furnace power
  double B = 1.0;
  
  // furnace efficiency
  double E = 0.2;
  
  // energy rate ($ / kWh)
  double C = 0.85;
  
  // step time (5 minutes)
  const STEP = 5;

  // x-axis times  
  var TIMES = [ "12am", "2am", "4am", "6am", "8am", "10am", "noon", "2pm", "4pm", "6pm", "8pm", "10pm", "12pm" ];
  
  // y-axis temp range
  var TEMPS = [ 50, 55, 60, 65, 70, 75, 80, 85 ];

  // size of the simulation display
  int width = 500, height = 400;
  
  // current simulation time
  int simTime = 24 * 60;
  
  // is the furnace on or off
  bool furnace = false;
  
  // is A/C on or off
  bool ac = false;
  
  // inside temperatures (F) over time
  List<double> temps;
  
  // cumulative energy use
  double energy = 0.0;
  
  // temperature velocity (used to smooth out the edges)
  double velocity = 0.0;
  
  // reference to the game engine
  Game game;
  
  // heating or cooling system?
  bool cool = false;
  
  // callback for when the simulation is finished running
  Function onDone = null;
  
  // drawing context
  CanvasRenderingContext2D ctx;
  
  
  Simulator(this.game) {
    CanvasElement canvas = document.query("#simulator");
    ctx = canvas.getContext("2d");
    width = canvas.width;
    height = canvas.height;
    clear();
  }
  
  
  void clear() {
    temps = new List<double>();
    temps.add(70.0);
    simTime = 0;
    energy = 0.0;
    R = double.parse(window.localStorage['valueR']);  // insulation 
    B = double.parse(window.localStorage['valueB']);  // furnace power
    E = double.parse(window.localStorage['valueE']);  // efficiency
    C = double.parse(window.localStorage['valueC']);  // energy rate
  }


  void run() {
    bool b = step();
    draw();
    if (b) {
      window.setTimeout(run, 30);
    } else if (onDone != null) {
      onDone();
    }
  }
  
  
  double getInsideTemperature() {
    int index = simTime ~/ STEP;
    if (index < temps.length) {
      return temps[index];
    } else {
      return 70.0;
    }
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

  
  bool step() {

    if (simTime >= 60 * 24) return false;
    
    // Reference to our weather model with outside temperatures    
    Weather weather = game.weather;
    
    // Reference to the thermostat with set temperatures
    Thermostat thermostat = game.thermostat;
    
    // current inside temperature
    double temp = getInsideTemperature();
    
    // advance time step
    simTime += STEP;
    
    // thermostat set temperature
    double stemp = thermostat.getSetTemperature(simTime ~/ 60, simTime % 60);

    // furnace turns on when actual temp is less than the set temp                     
    furnace = (stemp > temp) && !cool;
    ac = (stemp < temp) && cool;
    
    // add to the thermal velocity and total energy
    if (furnace) {
      velocity += STEP * B * E;
      energy += STEP * B;
    }
    
    if (ac) {
      velocity -= STEP * B * E;
      energy += STEP * B;
    }
    
    // temperature gradient
    double outside = weather.getTemperature(simTime ~/ 60, simTime % 60);
    double dT = temp - outside;

    // temperature flux
    K = (1 - R) / 300;
    double q = K * dT * STEP;
    
    velocity -= q;
    
    // adjust the actual indoor temperature
    temps.add(temp + velocity);
    
    // apply "friction"
    velocity *= 0.7;
    
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
      double tx = timeToX(0).toDouble();
      double ty = tempToY(temps[0]);
      ctx.beginPath();
      ctx.moveTo(tx, ty);
      
      for (int i=1; i<temps.length; i++) {
        tx = timeToX(i * STEP).toDouble();
        ty = tempToY(temps[i]);
        ctx.lineTo(tx, ty);
      }
      ctx.lineTo(tx, gy + gh);
      ctx.lineTo(gx, gy + gh);
      ctx.closePath();
      ctx.fillStyle = "rgba(255, 255, 255, 0.5)";
      ctx.fill();
    }
    
    // energy use so far
    ctx.font = "22px sans-serif";
    ctx.textAlign = "left";
    ctx.textBaseline = "top";
    ctx.fillStyle = "white";
    String str = "Energy: ${energy.toInt()} kWh";
    ctx.fillText(str, gx, gy + gh + 40);
    
    ctx.textAlign = "center";
    ctx.fillText("Bill: \$${(energy * C).toInt()}", gx + gw/2, gy + gh + 40);
    
    ctx.textAlign = "right";
    ctx.fillText("Avg. Temperature: ${getAverageTemperature().toInt()}", gx + gw, gy + gh + 40);
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

   
  double tempToY(double temp) {
    num y = 10;
    num h = height - 80;
    
    if (temp <= 50) {
      return y + h - 1.0;
    }
    else if (temp >= 90) {
      return y + 1.0;
    }
    else {
      temp -= 50;
      return y + h - temp * (h / 35);
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
}

