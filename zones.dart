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


class ComfortZones {

  static Random rand = new Random();
  
  // four comfort zones  
  List<Zone> zones;
  
  
  ComfortZones() {
    // keep zones in a list for convience
    zones = new List<Zone>();
    
    // morning
    zones.add(new Zone(6 * 60, 8 * 60, 71.5, "WAKE"));
    
    // daytime 
    zones.add(new Zone(8 * 60, 17 * 60, 67.0, "DAYTIME"));
    
    // evening
    zones.add(new Zone(17 * 60, 22 * 60, 70.0, "EVENING"));
    
    // night
    zones.add(new Zone(22 * 60, 6 * 60, 65.0, "NIGHT"));
  }
  
  
  void randomize() {
    morning.temp = 71.5 + rand.nextInt(9) * 0.5 - 4.0;
    daytime.temp = 69.0 + rand.nextInt(9) * 0.5 - 4.0;
    evening.temp = 70.5 + rand.nextInt(9) * 0.5 - 4.0;
    night.temp   = 65.5 + rand.nextInt(9) * 0.5 - 4.0;
  }
  
  
  
  Zone get morning => zones[0];
  Zone get daytime => zones[1];
  Zone get evening => zones[2];
  Zone get night => zones[3];
  
  
  Zone getZone(int time) {
    for (Zone zone in zones) {
      if (zone.inZone(time)) {
        return zone;
      }
    }
  }
  
  
  bool isComfortable(int time, double temp) {
    return getZone(time).isComfortable(temp);
  }
  
  
  int getComfortScore(List<double> temps, int step) {
    int time = 0;
    int score = 0;
    double s = 0.0;
    
    for (double temp in temps) {
      if (isComfortable(time, temp)) {
        score++;
      } else {
        score--;
      }
      time += step;
    }
    if (score > 1) {
      s = log(score);
    }
    else if (score < -1) {
      s = log(score * -1) * -1;
    }
    
    return (s * 0.5).round().toInt();
  }
}



class Zone {
  
  int start = 0;       // start time in minutes
  
  int end = 0;         // end time in minutes
  
  double temp = 65.0;  // comfort zone
  
  String name;
  
  
  Zone(this.start, this.end, this.temp, this.name);

  // Is time in this zone (special case for night)  
  bool inZone(int time) {
    if (start > end) {
      return (time >= start || time < end);
    } else {
      return (time >= start && time < end);
    }
  }
  
  
  bool isComfortable(double t) {
    return (t > (temp - 2) && t < (temp + 2));
  }
  
}
 