class Hamon {
  PVector position;
  int diameter;//直径

  Hamon(float x, float y) {
    this.position = new PVector(x, y);
    this.diameter = 0;
  }

  void update() {
   this.diameter = this.diameter + 30;
  }

  //波紋の描写
  void render() {
    pushMatrix();
    stroke(100, 150, 255);
    strokeWeight(3);
    noFill();
    ellipse(this.position.x, this.position.y, this.diameter, this.diameter);
    popMatrix();
  }

  void run() {
    this.update();
    this.render();
  }
}
