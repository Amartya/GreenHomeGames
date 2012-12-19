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
 * Very simple image button implementation... we might consider moving this
 * over to HTML and CSS rather than in dart. 
 */
class Button implements Touchable {

  // button image 
  var img;
   
  // action data to send with callbacks (optional)
  var action = null;
   
  // location of the button
  int x, y;
   
  // callback when the button is clicked
  var onClick = null;
  
  // callback when the button is first pressed
  var onDown = null;
   
  // button can be clicked on
  bool enabled = true;
   
  // is the button down 
  bool down = false;
   
  // is the button visible
  bool visible = true;
      

  Button(this.x, this.y);

   
  void setImage(var path) {
    img = new ImageElement();
    img.src = path;
    img.on.load.add((e) => Game.repaint());
  }
   

//-------------------------------------------------------------
// Touchable implementation
//-------------------------------------------------------------
  bool containsTouch(Contact event) {
    num tx = event.touchX;
    num ty = event.touchY;
    num w = img.width;
    num h = img.height;
    return (tx >= x && ty >= y && tx <= x + w && ty <= y + h);
  }
   
   
  bool touchDown(Contact event) {
    down = true;
    if (onDown != null) onDown(action);
    Game.repaint();
    return true;
  }
   
   
  void touchUp(Contact event) {
    down = false;
    if (onClick != null && containsTouch(event)) {
      onClick(action);
    }
    Game.repaint();
  }
   
   
  void touchDrag(Contact event) { 
    down = containsTouch(event);
    Game.repaint();
  }
   
   
  void touchSlide(Contact event) { }

   
  void draw(var ctx) {
    if (!visible) return;
      
    int ix = down? x + 3 : x;
    int iy = down? y + 3 : y;
    int iw = img.width;
    int ih = img.height;
      
    ctx.drawImage(img, ix, iy, iw, ih);
  }
}
