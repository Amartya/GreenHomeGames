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

class Weather {
  
  static List<String> MONTHS = [ "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" ];
   
  Random rand = new Random();
  
  // high temperature for the current day
  int high = 102;
  
  // low temperature for the current day
  int low = 3;
  
  // current month (1 = JAN, 2 = FEB, ...)
  int month = 1;
  
  // current day (i.e. 1 - 31)
  int day = 1;
  
   
  Weather() {
    setDate(1, 15);
  }
  
  
  /*
   * Set the current month and day and determine the summary weather information
   */
  void setDate(int month, int day) {

    this.month = min(max(0, month), MONTHS.length);
    this.day = day;
    
    // for now fake the climate with a sine wave and some randomness
    double theta = (month - 1) * (1.0 / 12.0) * PI * 2 - PI / 2;
    int avg = (sin(theta) * 30.0 + 50.0).toInt();
    high = avg - 25 + rand.nextInt(50);
    low = high - 2 - rand.nextInt(20);
  }
  

  /*
   * Get the temperature for the given hour and minute (12am == hour 0)
   */
  double getTemperature(int hour, int minute) {
    double range = (high - low) / 2.0;
    double theta = (hour * 60 + minute) * PI / (12.0 * 60.0) - PI / 2.0;
    return sin(theta) * range + range + low;
  }
  
  
  /*
   * Returns a summary of weather conditions for the given day
   */
  String getWeatherSummary() {
    return "Foggy with a chance of snow";
  }
  
  
  /*
   * Returns an HTML string for the current month and day
   */
  String getDateString() {
    return "${MONTHS[month - 1]}&nbsp;$day";
  }
  
  
  /*
   * Returns an HTML string for the high / low temps
   */
  String getTemperatureString() {
    return "High ${high}&deg;&nbsp;&nbsp; Low ${low}&deg;";
  }
}
