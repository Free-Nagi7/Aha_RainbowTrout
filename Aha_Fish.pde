import ddf.minim.*;  //外部ライブラリの定義
ArrayList<Fish> fishes;
ArrayList<Hamon> hamons;
PImage img1, img2, img3, img4, before, after, black, back;
int num = 60;//ニジマスの数
int n = 4;//階調数
int g = 256/n;//階調補正後の一階調当たりの色割り当て
int [] k = new int [256];//階調補正を行うための色割り当てを保存する配列
int pix;//正解画像の塗りつぶされたピクセルをカウント
int m = 250;//中間画像の枚数
PImage [] c = new PImage[m+1];
int i=0;
float red, green, blue;//アハ体験の加工後画像を生成する際に各色を0から255に抑える
boolean answerview = false;//正解画像を表示するかどうか

Minim minim;
AudioPlayer water;  //水滴
AudioPlayer masu;  //虹鱒追加SE
AudioPlayer ike;  //魚が跳ねるSE
AudioPlayer camera;  //シャッター音
AudioPlayer ans;  //正解SE
AudioPlayer aha;  //アハ体験画像表示SE

void setup() {
  size(1500, 900);
  background(159, 217, 246);
  smooth();

  //再生用のオブジェクト生成
  minim = new Minim(this);

  //音楽ファイルを読み込む
  water = minim.loadFile("water.mp3");
  masu = minim.loadFile("masu.mp3");
  ike = minim.loadFile("ike.mp3");
  camera = minim.loadFile("camera.mp3");
  ans = minim.loadFile("ans.mp3");
  aha = minim.loadFile("aha.mp3");


  fishes = new ArrayList<Fish>();
  for (int i = 0; i<num; i++) {
    fishes.add(new Fish(random(width), random(height)));
  }

  hamons = new ArrayList<Hamon>();
  for (int i = 0; i<3; i++) {
    hamons.add(new Hamon(random(100, 900), random(100, 700)));
    water.play(0);
  }


  //ここから各種画像作成

  //黒画像読み込み、サイズ調整
  black = loadImage("black.png");
  black.resize(500, 400);
  
  //画面右上の初期設定(黒)
  img1 = black;
  
  //画面右半分の黒背景
  back = black.get();
  back.resize(500, 800);
  
  //画面右下の初期設定(黒)
  for (int i = 0; i<=m; i++) {
    c[i] = black;
  }

  //中間画像を作成するための色割り当ての計算
  for (int i = 0; i < n; i++) {
    for (int j = 0; j<k.length; j++) {
      if (i*g <= j&&j<(i+1)*g) {
        k[j]=(i*g)+(i*i+1*g)/2;
      }
    }
  }

  img3 = createImage(500, 400, RGB);
}


void draw() {
  //池の背景
  background(159, 217, 246);

  //ニジマス配置
  for (int i = 0; i<fishes.size(); i++) {
    fishes.get(i).run(fishes);
  }
  
  //波紋を配列にランダム追加、SEを再生
  int hamonview = (int)random(0, 200);
  if (hamonview==10) {
    hamons.add(new Hamon(random(100, 900), random(100, 700)));
    int waterin = (int)random(0, 2);
    if (waterin == 1) {
      ike.play(0);
    }
    water.play(0);
  }
  
  //波紋を画面に配置
  for (int i = 0; i<hamons.size(); i++) {
    hamons.get(i).run();
  }

  //波紋が池の範囲外に出ると消える
  for (int i = 0; i < hamons.size(); i++) {
    if (hamons.get(i).diameter>=4000) {
      hamons.remove(i);
    }
  }


  //余白
  fill(170);
  noStroke();
  rect(0, height-100, width, 100);

  //正解画像表示ボタンの配置
  pushMatrix();
  translate(width-130, height-80);
  fill(255, 0, 0);
  noStroke();
  rect(0, 0, 100, 60);
  fill(255);
  text("Answer", 30, 33);
  popMatrix();

  //ここから各種画像を表示
  //右半分の背景
  image(back, 1000, 0);
  
  //画面右上にスクリーンショットを表示
  image(img1, 1002, -2);
  
  //画面右下にアハ体験を表示
  image(c[i], 1002, 400);
  i++;
  if (i>m) {
    i=0;
  }

  //画面右上に正解画像を任意で表示
  if (answerview == true) {
    image(img3, 1002, 0);
  }
}

void mousePressed() {
  //池の中でクリックするとニジマスを追加
  if (0 <= mouseY && mouseY <= height-100) {
    if (0 <= mouseX && mouseX <= width-500) {
      fishes.add(new Fish(mouseX, mouseY));
      hamons.add(new Hamon(mouseX, mouseY));
      masu.play(0);
    }
  }

  //answerボタンをクリックすると正解画像を表示・非表示
  if (height-80 <= mouseY && mouseY <= height-10) {
    if (width-130 <= mouseX && mouseX <= width-10) {
      if (answerview == false) {
        answerview = true;
        ans.play(0);
      } else {
        answerview = false;
      }
    }
  }
}


void keyPressed() {
  if (key == 's') {

    //画像を作成
    PImage img = createImage(width, height, RGB);

    //画面を画像にコピー
    loadPixels();
    img.pixels = pixels;
    img.updatePixels();

    //画像のピクセル情報を切り出して保存
    img = img.get(0, 0, width-500, height-100);
    img.resize(500, 400);
    img.save("photo.png");

    //スクリーンショットした画像を読み込み・SEを再生
    img1 = loadImage("photo.png");
    camera.play(0);
  }

  if (key == 'a') {

    //中間画像を作成するために元画像をコピー
    before = img1.get();
    
    //色削減画像
    img2 = del(img1);
    
    //正解画像
    img3 = answer(img2);
    
    //加工後の画像
    after = kakou(before, img3);
    
    //中間画像作成
    for (int i = 0; i<=m; i++) {
      img4 = mid(img1, after, i);
      c[i] = img4;
    }
    //出題SEを再生
    aha.play(0);
  }
}


//色削減メソッド
PImage del(PImage img1) {

  PImage img3 = createImage(img1.width, img1.height, RGB);

  //色削減
  for (int i = 0; i < img1.pixels.length; i++) {
    img3.pixels[i]= color(k[(int)(red(img1.pixels[i]))], k[(int)(green(img1.pixels[i]))], k[(int)(blue(img1.pixels[i]))]);
  }

  return img3;
}


//正解画像作成メソッド
PImage answer(PImage img2) {
  PImage img = createImage(img1.width, img1.height, RGB);
  do {
    //黒のPImage型のデータを作成
    for (int i = 0; i<img.pixels.length; i++) {
      img.pixels[i]=color(0, 0, 0);
    }
    
    //領域抽出する色をランダムに決定
    int [] a = new int[3];
    pix=0;
    for (int i = 0; i<3; i++) {
      int n = (int)random(0, 4);
      a[i]= (n*g)+(n*n+1*g)/2;
    }
    
    //全体（背景）が⿊で抽出した領域のみが⾚（指定範囲内）の画像を作成
    for (int i = 0; i < img2.pixels.length; i++) {
      if (img2.pixels[i]==color(a[0], a[1], a[2])) {
        img.pixels[i]=color(255, 0, 0);
        pix++;
      } else {
        img.pixels[i]=color(0, 0, 0);
      }
    }
  } while ((double)pix/img2.pixels.length<0.01|| (double)pix/img2.pixels.length>0.6);

  return img;
}


//正解画像を元に画像加工を行うメソッド
PImage kakou(PImage before, PImage ans) {
  //ランダムで色の階調を増減させる幅を決める
  float [] delta = new float[3];
  PImage im = createImage(img1.width, img1.height, RGB);
  for (int i = 0; i<3; i++) {
    int n = (int)random(4);
    if (n==0) {
      delta[i]= 32;
    } else if (n==1) {
      delta[i]= -32;
    } else if (n==2) {
      delta[i]= 23;
    } else if (n==3) {
      delta[i]= 23;
    }
  }
  
  //answerメソッドで特定した領域の各ピクセルと同じ位置に、上で決めた数値を加算
  for (int i = 0; i < ans.pixels.length; i++) {
    red = red(before.pixels[i])+delta[0];
    green = green(before.pixels[i])+delta[1];
    blue = blue(before.pixels[i])+delta[2];
    if (red(before.pixels[i])+delta[0]<0) {
      red = 0;
    } else if (green(before.pixels[i])+delta[1]<0) {
      green = 0;
    } else if (blue(before.pixels[i])+delta[2]<0) {
      blue = 0;
    } else if (red(before.pixels[i])+delta[0]>255) {
      red = 255;
    } else if (green(before.pixels[i])+delta[1]>255) {
      green = 255;
    } else if (blue(before.pixels[i])+delta[2]>255) {
      blue = 255;
    }
    if (ans.pixels[i]==color(255, 0, 0)) {
      im.pixels[i]=color(red, green, blue);
    } else {
      im.pixels[i]=color(red(before.pixels[i]), green(before.pixels[i]), blue(before.pixels[i]));
    }
  }
  return im;
}


//中間画像作成メソッド
PImage mid(PImage img1, PImage img2, int i) {
  PImage img4 = createImage(img1.width, img1.height, RGB);
  
  //画像二枚の各ピクセルの中間数値を計算
  for (int j = 0; j < img1.pixels.length; j++) {
    img4.pixels[j]= color(((m-i)*red(img1.pixels[j])+i*red(img2.pixels[j]))/m, ((m-i)*green(img1.pixels[j])+i*green(img2.pixels[j]))/m, ((m-i)*blue(img1.pixels[j])+i*blue(img2.pixels[j]))/m);
  }

  return img4;
}
