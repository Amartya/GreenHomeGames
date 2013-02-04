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
 * A member of the family has a comfort zone
 */
class Person {
  
  // name of the family member
  String name;
  
  // identifier in HTML
  String id;
  
  // comfort zones
  ComfortZones zones;
  
  // comfort score
  int comfort = 0;

  bool show_zones = false;
  
  
  Person(this.name, this.id) {
    
    zones = new ComfortZones();
    
    // randomly set comfort preferences
    zones.randomize();
    
  }
  
  
  void resetComfortScore() {
    Element el = document.query("#${id}");
    if (el != null) el.innerHtml = "";
  }
  
  
  void updateComfortScore(List<double> temps, int step) {
    
    comfort = zones.getComfortScore(temps, step);

    Element el = document.query("#${id}");
    if (el != null) {
      el.innerHtml = (comfort > 0) ? "+${comfort}" : "${comfort}";
    }
  }
}



/*
 * A family is just a list of people
 */
class Family {
  
  List<Person> people;
  
  Game game;
  
  Family(this.game) {
    people = new List<Person>();
    people.add(new Person("green", "green-penguin"));
    people.add(new Person("red", "red-penguin"));
    people.add(new Person("blue", "blue-penguin"));
    people.add(new Person("orange", "orange-penguin"));
    people.add(new Person("bear", "polar-bear"));
    
    List<Element> items = document.queryAll(".penguins li");
    for (Element el in items) {
      el.on.mouseUp.add((evt) {
        selectPerson(el.id);
      }, true);
    }
  }
  
  
  void resetComfortScores() {
    for (Person p in people) {
      p.resetComfortScore();
    }
  }
  

  void selectPerson(String id) {
    for (Person p in people) {
      if (p.id == id) {
        p.show_zones = !p.show_zones;
      } else {
        p.show_zones = false;
      }
    }
    List<Element> items = document.queryAll(".penguins li");
    for (Element el in items) {
      if (el.id == id) {
        el.classes.toggle("selected");
      } else {
        el.classes.remove("selected");
      }
    }
    game.draw();
  }
}