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

  // Penguin family
  Family family;
  
  // Energy bill
  int curr_bill = 0;
  int prev_bill = 0;
  
  
  Game() {

    // Family of penguins    
    family = new Family(this);
    
    // Round thermostat control
    thermostat = new RoundThermostat(this);
    
    // Weather model
    weather = new Weather();
    
    // Temperature simulation
    simulator = new Simulator(this);
    simulator.onDone = () {
      prev_bill += curr_bill;
      curr_bill = simulator.bill;
      updateBill();
    };
    simulator.onStart = () {
      Element el = document.query("#paid-stamp");
      if (el != null) el.style.visibility = "hidden";
    };
    
    // Load sound effects
    Sounds.loadSound("tick");
    Sounds.loadSound("crank");
    Sounds.loadSound("heater");
  
    // Create spinner control 
    spinner = new DateSpinner(this);
    spinner.onDone = () {
      weather.setDate(spinner.month, spinner.day);
    };


    // set up the navigation buttons    
    var buttons = document.queryAll(".next-button");
    for (ButtonElement button in buttons) {
      button.on.click.add((event) {
        int page = int.parse(button.value);
        int next = page + 1;
        if (next > 4) next = 1;
        slidePageOut("page${page}", true);
        slidePageIn("page${next}", true);
      }, true);
    }
    
    
    buttons = document.queryAll(".back-button");
    for (ButtonElement button in buttons) {
      button.on.click.add((event) {
        int page = int.parse(button.value);
        int prev = page - 1;
        if (prev < 1) prev = 4;
        slidePageOut("page${page}", false);
        slidePageIn("page${prev}", false);
      }, true);
    }
    
    ButtonElement button = document.query("#pay-now");
    if (button != null) {
      button.on.click.add((event) {
        Element el = document.query("#paid-stamp");
        el.style.visibility = "visible";
        prev_bill = 0;
        curr_bill = 0;
        //updateBill();
      }, true);
    }

    // Transition from page2 to page3
    //next = document.query("#next2");
    //back = document.query("#back2");
    //next.on.click.add((event) {
    //  slidePageOut("page2");
    //  slidePageIn("page3");
    //  window.setTimeout(() {
    //    simulator.clear();
    //    simulator.run();
    //  }, 1000);
    //}, true);
    
    setDate(1, 1);
    showWeather();
    draw();
    
    // slide in page 1
    window.setTimeout(() => slidePageIn("page1", true), 1000);
  }
  
  
  void updateBill() {
    setText("bill-subtotal", "\$${curr_bill}");
    setText("bill-previous", "\$${prev_bill}");
    setText("bill-total", "\$${prev_bill + curr_bill}");
    setText("bill-energy", "${simulator.energy.toInt()} kWh");
    setText("bill-summary-amount", "\$${prev_bill + curr_bill}");
    setText("bill-summary-date", "${weather.getDateString()}");
    double rate = double.parse(window.localStorage['valueC']);
    setText("bill-rate", "${rate}");
  }
  
  
  void setText(String id, String text) {
    Element el = document.query("#${id}");
    if (el != null) {
      el.innerHtml = text;
    }
  }
  
  
  void slidePageIn(String page, bool left) {
    Element el = document.query("#$page");
    if (left) {
      el.style.animation = "slidein-left 0.5s ease-in 0 1";
      el.style.left = "25px";
    } else {
      el.style.animation = "slidein-right 0.5s ease-in 0 1";
      el.style.left = "25px";
    }
  }
  
  
  void slidePageOut(String page, bool left) {
    Element el = document.query("#$page");
    if (left) {
      el.style.animation = "slideout-left 0.5s ease-out 0 1";
      el.style.left = "-1500px";
    } else {
      el.style.animation = "slideout-right 0.5s ease-out 0 1";
      el.style.left = "1500px";
    }
  }
  
  
  void setDate(int month, int day) {
    spinner.setDate(month, day);
    weather.setDate(month, day);
    Element el = document.query("#curr-date");
    el.innerHtml = weather.getDateString();
  }
  
  
  void hideWeather() {
    Element el;
    setText("high-temp", "?");
    setText("low-temp", "?");
    setText("weather-report", "");
    setText("weather-temps", "");
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
    simulator.clear();
    family.resetComfortScores();
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

