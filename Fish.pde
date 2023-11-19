class Fish {
  PVector position;
  PVector velocity;
  PVector accel;
  float r;
  float vmax;
  float fmax;

  Fish(float x, float y) {
    this.position = new PVector(x, y);
    this.velocity = new PVector(random(-3, 3), random(-3, 3));
    this.r = 27;
    this.accel= new PVector(0, 0);
    this.vmax = 5;
    this.fmax = 0.05;
  }

  void update() {
    this.velocity.add(this.accel);
    this.velocity.limit(vmax);
    this.position.add(this.velocity);
    this.accel= new PVector(0, 0);
  }

  //魚のモデリング
  void render() {
    float a = atan2(this.velocity.y, this.velocity.x);
    int red = (int)random(0, 255);
    int blue = (int)random(0, 255);
    int green = (int)random(0, 255);
    fill(red, blue, green);
    pushMatrix();
    translate(this.position.x, this.position.y);
    rotate(a-PI/2);
    beginShape();
    vertex(r, 0);
    vertex(0, r);
    vertex(-r, 0);
    endShape();
    popMatrix();


    fill(red, blue, green);
    pushMatrix();
    translate(this.position.x, this.position.y);
    rotate(a-PI/2);
    beginShape();
    vertex(r, 0);
    vertex(0, -r*2);
    vertex(-r, 0);
    endShape();
    popMatrix();


    fill(red, blue, green);
    pushMatrix();
    translate(this.position.x, this.position.y);
    rotate(a-PI/2);
    beginShape();
    vertex(r, -r*2.5);
    vertex(0, -r*2);
    vertex(-r, -r*2.5);
    endShape(CLOSE);
    popMatrix();
  }

  //境界処理
  void border() {
    if (this.position.x>width-500) {
      this.position.x = 0;
    }
    if (this.position.x<0) {
      this.position.x = width-500;
    }
    if (this.position.y>height-100) {
      this.position.y = 0;
    }
    if (this.position.y<0) {
      this.position.y= height-100;
    }
  }

  void run(ArrayList<Fish> fishes) {
    groupBehavior(fishes);
    this.update();
    this.render();
    this.border();
  }

  void applyForce(PVector force) {
    this.accel.add(force);
  }

  //群れ行動
  void groupBehavior(ArrayList<Fish> fishes) {

    PVector separateForce = separate(fishes);
    separateForce.mult(1.5);//力の強さを変更
    applyForce(separateForce);
  }

  /*
  エージェント同士が離れる分離メソッド
  分離に関して働く力の強さと方向を決定
  */
  PVector separate(ArrayList<Fish> fishes) {
    float ran = 50;
    int q = 0;
    PVector steering = new PVector(0, 0);
    for (int j = 0; j<fishes.size(); j++) {
      float dis = dist(this.position.x, this.position.y, fishes.get(j).position.x, fishes.get(j).position.y);
      if (ran > dis && dis > 0) {
        PVector d = this.position.copy();
        d.sub(fishes.get(j).position);
        d.normalize();
        d.div(dis);
        steering.add(d);
        q++;
      }
    }
    if (0<q) {
      steering.div(q);
      steering.normalize();
      steering.mult(vmax);
      steering.sub(this.velocity);
      steering.limit(fmax);
    }
    return steering;
  }
}
