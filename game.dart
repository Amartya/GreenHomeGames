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


class Game {
   
  // size of the game canvas
  int width, height;
   
  // Month / Day spinners
  Spinner month, day;
   
  // Next button
  Button next;

  // Weather indicator  
  Weather weather;
  
  // temperature simulation
  Grid grid;
   
  // Thermostat control
  RoundThermostat thermostat;

  // Penguine  
  ImageElement ping;
  
  // Status indicators
  Indicator pollution, energy, money;
  
  // Drawing context for the main canvas
  static CanvasRenderingContext2D ctx;
  
  // Used for static repaint method
  static Game instance;

  
  Game() {
    
    Game.instance = this;
    
    // Set up touch layer
    TouchLayer layer = new TouchLayer.fromCanvas("game");
    layer.resizeToFitScreen();
    Game.ctx = layer.context;
    width = layer.width;
    height = layer.height;
    TouchManager.addLayer(layer);
    
    // Load penguine image
    ping = new ImageElement();
    ping.src = "images/ping.png";
      
    // Load sound effects
    Sounds.loadSound("tick");
    Sounds.loadSound("crank");
    Sounds.loadSound("heater");
  
    // Create spinners
    month = new Spinner(45, 32, 100, 37);
    day = new Spinner(155, 32, 50, 37);
    day.VALUES = [];
    for (int i=1; i<=31; i++) day.VALUES.add(i);

    // Next button
    next = new Button(width - 170, height - 80);
    next.setImage("images/next.png");
    next.onClick = (action) => nextTurn(1);
    layer.addTouchable(next);
    
    // Pollution indicator
    pollution = new Indicator(450.0, 225.0);
    pollution.percent = 75;
    pollution.total = 235;
    
    // Energy indicator
    energy = new Indicator(450.0, 325.0);
    energy.percent = 60;
    energy.total = 180;
    energy.label = "Energy";
    energy.unit = "kilowatt hours";
    
    // Money indicator
    money = new Indicator(450.0, 425.0);
    money.percent = 92;
    money.total = 150;
    money.label = "Money";
    money.unit = "dollars";
    
    // Temperature simulation grid
    grid = new Grid(width / 2 - 325, height / 2 - 200, 650.0, 400.0);
    grid.hide();
    
    // Round thermostat control
    thermostat = new RoundThermostat(width / 2 - 300.0, height / 2 - 250.0);
    thermostat.hide();
    
    // Weather indicator
    weather = new Weather(width / 2, height / 2);
    weather.hide();
    
    // Give images and fonts a moment to load
    window.setTimeout(draw, 500);
  }

  
  void nextTurn(int s) {
    switch (s) {
      case 0:
        grid.slideOff(0);
        pollution.slideOn(0);
        energy.slideOn(3);
        money.slideOn(6);
        next.onClick = (action) => nextTurn(1);
        break;
      case 1:
        pollution.slideOff(0);
        energy.slideOff(3);
        money.slideOff(6);
        window.setTimeout(() => Sounds.playSound("crank"), 900);
        window.setTimeout(() => month.moveTo(month.index + 1), 1900);
        window.setTimeout(() => day.spin(), 2700);
        weather.slideOn(200);
        next.onClick = (action) => nextTurn(2);
        break;
      case 2:
        weather.slideOff(0);
        thermostat.slideOn(0);
        next.onClick = (action) => nextTurn(3);
        break;
      case 3:
        thermostat.slideOff(0);
        grid.slideOn(0);
        window.setTimeout(grid.restart, 1300);
        next.onClick = (action) => nextTurn(0);
        break;
    }
  }
  
  
  static void repaint() {
    Game.instance.draw();
  }
  
      
  void draw() {
    ctx.clearRect(0, 0, width, height);
    
    // draw penguine
    ctx.drawImage(ping, 40, height - 180);
    
    // draw top date bar
    ctx.fillStyle = "rgba(0, 0, 0, 0.4)";
    ctx.fillRect(25, 25, width - 50, 50);
    
    // draw grid elements
    pollution.draw(ctx);
    energy.draw(ctx);
    money.draw(ctx);
    month.draw();
    day.draw();
    next.draw(ctx);
    weather.draw(ctx);
    thermostat.draw(ctx);
    grid.draw(ctx);
  }
}

