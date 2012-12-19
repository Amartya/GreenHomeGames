/*
 * Multi-Touch Library for Dart
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
library DartTouch;

import 'dart:html';
import 'dart:json';



/*
 * The touch manager is responsible for processing touch input and delegating 
 * touch events to touchable objects
 */
class TouchManager {
  
  // List of touch layers that contain touchable objects
  static List<TouchLayer> layers = new List<TouchLayer>();
    
  // Bindings from event IDs to touchable objects
  static Map<int, TouchBinding> bindings = new Map<int, TouchBinding>();
    
  // Is the mouse down?
  static bool mdown = false;
  
 
/*
 * This must be called from main() to bootstrap the touch management system
 */
  static void init() {
    
    // Register mouse events
    window.on.mouseDown.add((e) => mouseDown(e), true);
    window.on.mouseUp.add((e) => mouseUp(e), true);
    window.on.mouseMove.add((e) => mouseMove(e), true);
    
    // Events for iOS
    window.on.touchStart.add((e) => touchDown(e), true);
    window.on.touchMove.add((e) => touchDrag(e), true);
    window.on.touchEnd.add((e) => touchUp(e), true);
    
    // Prevent screen from dragging on iOS
    document.on.touchMove.add((e) => e.preventDefault(), true);
    
    // Add a default touch layer at the bottom of the stack
    addLayer(new TouchLayer());
    
    // Attempt to connect to the microsoft surface input stream
    /*
    try {
      var socket = new WebSocket("ws://localhost:405");
      socket.on.open.add((evt) => print("connected to surface."));
      socket.on.message.add((evt) => processTouches(evt.data));
      socket.on.error.add((evt) => print("error in surface connection."));
      socket.on.close.add((evt) => print("surface connection closed."));
    }
    catch (x) {
      print("unable to connect to surface.");
    }
    */
  }
  
  
/*
 * Adds a new touch layer. The most recently added layer will be on top
 */
  static void addLayer(TouchLayer layer) {
    layers.add(layer);
  }
  
  
/*
 * Add a touchable object to the given layer
 */
  static addTouchable(Touchable touchable, [String layer = null]) {
    if (layer == null) {
      layers[0].addTouchable(touchable);
    } else {
      for (var l in layers) {
        if (l.name == layer) {
          l.addTouchable(touchable);
        }
      }
    }
  }
  
  
/*
 * Remove a touchable object from the given layer
 */
  static removeTouchable(Touchable touchable, [String layer = null]) {
    if (layer == null) {
      layers[0].removeTouchable(touchable);
    } else {
      for (var l in layers) {
        if (l.name == layer) {
          l.removeTouchable(touchable);
        }
      }
    }
  }
  
  
/*
 * Searches through layers to find target of a touch event
 */
  static TouchBinding findTouchTarget(Contact contact) {
    for (int i = layers.length - 1; i >= 0; i--) {
      TouchLayer layer = layers[i];
      Touchable target = layer.findTouchTarget(contact);
      if (target != null) {
        return new TouchBinding(layer, target);
      }
    }
    return null;
  }
  
  
/*
 * Convert mouseUp to touchUp events
 */
  static void mouseUp(MouseEvent evt) {
    var b = bindings[-1]; // see if a binding exists
    if (b != null) {
      Contact c = new Contact.fromMouse(evt);
      c.transform(b.layer);
      b.target.touchUp(c);
      bindings[-1] = null;
    }
    mdown = false;
  }
  
  
/*
 * Convert mouseDown to touchDown events
 */
  static void mouseDown(MouseEvent evt) {
    Contact c = new Contact.fromMouse(evt);
    var b = findTouchTarget(c);
    if (b != null) {
      c.transform(b.layer);
      if(b.target.touchDown(c)) {
         bindings[-1] = b; // bind if the target wants ownership
      }
    }
    mdown = true;
  }
  
  
  /*
   * Convert mouseMove to touchDrag events
   */
  static void mouseMove(MouseEvent evt) {
    if (mdown) {
      Contact c = new Contact.fromMouse(evt);
      var b = bindings[-1];
      if (b != null) {
        c.transform(b.layer);
        b.target.touchDrag(c);
      } else {
        b = findTouchTarget(c);
        if (b != null) {
          c.transform(b.layer);
          b.target.touchSlide(c);
        }
      }
    }
  }
  
  
  /*
   * Delegate touch down events to touchable objects
   */   
  static void touchDown(TouchEvent tframe) {
    for (var te in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(te);
      t.down = true;
      var b = findTouchTarget(t);
      if (b != null) {
        t.transform(b.layer);
        if (b.target.touchDown(t)) {
          bindings[t.id] = b; // if touchables wants ownership then bind
        }
      }
    }
  }
  
  
  static void touchUp(var tframe) {
    for (var te in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(te);
      t.up = true;
      var b = bindings[t.id];
      if (b != null) {
        t.transform(b.layer);
        b.target.touchUp(t);
        bindings[t.id] = null;
      }
    }
    if (tframe.touches.length == 0) {
      bindings.clear();
    }
  }
  
  
  static void touchDrag(var tframe) {
    for (var te in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(te);
      t.drag = true;
      var b = bindings[t.id];
      if (b != null) {
        t.transform(b.layer);
        b.target.touchDrag(t);
      } else {
        b = findTouchTarget(t);
        if (b != null) {
          t.transform(b.layer);
          b.target.touchSlide(t);
        }
      }
    }
  }
}

  
/*
 * A touch layer corresponds to an HTML Canvas element on the screen.
 * Each layer contains touchable objects 
 */
class TouchLayer {
  
  // A list of touchable objects on this layer
  List<Touchable> touchables = new List<Touchable>();

  // Size and position of the canvas in the browser window
  int x, y, width, height;
  
  // Layer name
  String name = null;
  
  // Drawing context
  CanvasRenderingContext2D context = null;
  
  // Transformation matrix
  List<double> tform = [1, 0, 0, 1, 0, 0];
  
  TouchLayer() {
    x = 0;
    y = 0;
    width = window.innerWidth;
    height = window.innerHeight;
  }
  
  TouchLayer.fromCanvas(String id) {
    CanvasElement canvas = document.query("#$id");
 
    // Determine the size and position of this layer
    x = canvas.offsetLeft;
    y = canvas.offsetTop;
    width = canvas.width;
    height = canvas.height;
    name = canvas.id;
    
    context = canvas.getContext("2d");
    
    canvas.getComputedStyle("=webkit-transform").onComplete((f) {
      String s = f.value.transform;
      if (s.startsWith("matrix(")) {
        s = s.substring(7, s.length - 1);
        var sa = s.split(", ");
        this.tform.clear();
        for (var v in sa) {
          this.tform.add(double.parse(v));
        }
      }
    });
  }
  

/*
 * Add a touchable object to the list
 */
   void addTouchable(Touchable t) {
      touchables.add(t);
   }
   

/*
 * Remove a touchable object from the master list
 */
   void removeTouchable(Touchable t) {
      for (int i=0; i<touchables.length; i++) {
         if (t == touchables[i]) {
            touchables.removeRange(i, 1);
            return;
         }
      }
   }
   

  void resize(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    
    CanvasElement canvas = document.query("#$name");
    canvas.width = w;
    canvas.height = h;
    canvas.style.left = "${x}px";
    canvas.style.top = "${y}px";
  }
  
  
  void resizeToFitScreen() {
    resize(0, 0, window.innerWidth, window.innerHeight);
  }
   
   
/*
 * Find a touchable object that intersects with the given touch event
 */
  Touchable findTouchTarget(Contact contact) {
    Contact c = new Contact.copy(contact);
    c.transform(this);
    for (var t in touchables) {
      if (t.containsTouch(c)) {
        return t;
      }
    }
    return null;
  }
}


/*
 * Objects on the screen must implement this interface to receive touch events
 */
abstract class Touchable {
   
   // Return true iff touch intersects with the given object
   bool containsTouch(Contact event);
   
   // This gets fired if a touch down lands on the touchable object. 
   // Return true to 'own' the touch event for the duration 
   // Return false to ignore the event (e.g. if disabled or if you want slide events)
   bool touchDown(Contact event);
   
   void touchUp(Contact event);
   
   // This gets fired only after a touchDown lands on the touchable object
   void touchDrag(Contact event);
   
   // This gets fired when an unbound touch events slides over an object
   void touchSlide(Contact event);
}


class TouchBinding {
  TouchLayer layer;
  Touchable target;
  
  TouchBinding(this.layer, this.target);
}




class Contact {
  int id;
  int tagId = -1;
  double touchX = 0.0;
  double touchY = 0.0;
  double radiusX = 0.0;
  double radiusY = 0.0;
  bool tag = false;
  bool up = false;
  bool down = false;
  bool drag = false;
  bool finger = false;
  
  Contact(this.id);
  
  Contact.fromMouse(MouseEvent mouse) {
    id = -1;
    touchX = mouse.pageX.toDouble();
    touchY = mouse.pageY.toDouble();
    finger = true;
  }
  
  Contact.fromTouch(Touch touch) {
    id = touch.identifier;
    touchX = touch.pageX.toDouble();
    touchY = touch.pageY.toDouble();
    tag = false;
    tagId = -1;
    finger = true;
  }
  
  Contact.fromJSON(var json) {
    id = json.identifier;
    touchX = json.pageX;
    touchY = json.pageY;
    up = json.up;
    down = json.down;
    drag = json.drag;
    tag = json.tag;
    tagId = json.tagId;
  }
  
  Contact.copy(Contact other) {
    id = other.id;
    touchX = other.touchX;
    touchY = other.touchY;
    radiusX = other.radiusX;
    radiusY = other.radiusY;
    tag = other.tag;
    up = other.up;
    down = other.down;
    drag = other.drag;
    finger = other.finger;
  }

  void transform(TouchLayer layer) {
    double tx = touchX - layer.width / 2 - layer.x;
    double ty = touchY - layer.height / 2 - layer.y;
    touchX = layer.tform[0] * tx + layer.tform[1] * ty;
    touchY = layer.tform[2] * tx + layer.tform[3] * ty;
    touchX += layer.width / 2;
    touchY += layer.height / 2;
  }
}
