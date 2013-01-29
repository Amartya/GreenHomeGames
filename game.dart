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
   
  // Month / Day spinners
  DateSpinner spinner;
   
  // Weather model
  Weather weather;
  
  // Thermostat 
  Thermostat thermostat;

  // indoor temperature simulation
  Simulator simulator;
   
  // Status indicators
  Indicator pollution, energy, money;
  
  
  Game() {
    
    // Load sound effects
    Sounds.loadSound("tick");
    Sounds.loadSound("crank");
    Sounds.loadSound("heater");
  
    // Create spinner control 
    spinner = new DateSpinner(this);
    spinner.onDone = () {
      weather.setDate(spinner.month, spinner.day);
    };

    // Transition from page1 to page2
    ButtonElement next = document.query("#next1");
    next.on.click.add((event) {
      slidePageOut("page1");
      slidePageIn("page2");
      next.style.visibility = "hidden";
    }, true);
    
    
    // Transition from page2 to page3
    next = document.query("#next2");
    next.on.click.add((event) {
      slidePageOut("page2");
      slidePageIn("page3");
      window.setTimeout(() {
        simulator.clear();
        simulator.run();
      }, 1000);
    }, true);
    
    
    // Transition from page3 to page1
    next = document.query("#next3");
    next.on.click.add((event) {
      slidePageOut("page3");
      slidePageIn("page1");
      next.style.visibility = "hidden";
    }, true);
    
    
    // Pollution indicator
    /*
    pollution = new Indicator(450.0, 225.0);
    pollution.percent = 75;
    pollution.total = 235;
    */
    
    // Energy indicator
    /*
    energy = new Indicator(450.0, 325.0);
    energy.percent = 60;
    energy.total = 180;
    energy.label = "Energy";
    energy.unit = "kilowatt hours";
    */
    
    // Money indicator
    /*
    money = new Indicator(450.0, 425.0);
    money.percent = 92;
    money.total = 150;
    money.label = "Money";
    money.unit = "dollars";
    */
    
    // Temperature simulation
    simulator = new Simulator(this);
    simulator.onDone = () {
      Element el = document.query("#next3");
      el.style.visibility = 'visible';
    };
    
    // Round thermostat control
    thermostat = new RoundThermostat(this);
    
    // Weather model
    weather = new Weather();
    setDate(1, 1);
    hideWeather();
    draw();
    
    // slide in page 1
    window.setTimeout(() => slidePageIn("page1"), 1000);
  }
  
  
  void slidePageIn(String page) {
    Element el = document.query("#$page");
    el.style.animation = "slidein 0.5s ease-in 0 1";
    el.style.left = "25px";
  }
  
  
  void slidePageOut(String page) {
    Element el = document.query("#$page");
    el.style.animation = "slideout 0.5s ease-out 0 1";
    el.style.left = "-1500px";
  }
  
  
  void setDate(int month, int day) {
    spinner.setDate(month, day);
    weather.setDate(month, day);
    Element el = document.query("#curr-date");
    el.innerHtml = weather.getDateString();
  }
  
  
  void hideWeather() {
    Element el;
    el = document.query("#next1");
    el.style.visibility = 'hidden';
    el = document.query("#high-temp");
    el.innerHtml = "?";
    el = document.query("#low-temp");
    el.innerHtml = "?";
    el = document.query("#weather-report");
    el.innerHtml = "";
    el = document.query("#weather-temps");
    el.innerHtml = "";
  }
  
  
  void showWeather() {
    Element el = document.query("#high-temp");
    el.innerHtml = "${weather.high}&deg;";
    el = document.query("#low-temp");
    el.innerHtml = "${weather.low}&deg;";
    el = document.query("#weather-report");
    el.innerHtml = weather.getWeatherSummary();
    el = document.query("#weather-temps");
    el.innerHtml = weather.getTemperatureString();
    el = document.query("#next1");
    el.style.visibility = 'visible';
  }

  
  void nextTurn(int s) {
    //simulator.clear();
    //simulator.run();
    //spinner.spin();
    /*
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
        next.onClick = (action) => nextTurn(2);
        break;
      case 2:
        weather.setDate(month.index, day.index);
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
    */
  }
  
  
  void draw() {
    // draw grid elements
    //pollution.draw(ctx);
    //energy.draw(ctx);
    //money.draw(ctx);
    spinner.draw();
    thermostat.draw();
    simulator.draw();
  }
}

