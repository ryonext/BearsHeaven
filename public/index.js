// ゲームバランスに関する設定値
//やられ判定。これを大きくすれば詐欺判定。小さくすれば弾幕シューティング的判定に・・・。
//var YARARE_HANTEI = 0; //無敵モード
var YARARE_HANTEI = 5;
//敵の出現間隔。この数字を小さくすれば無理ゲー。大きくすればヌルゲーに。というのを、敵の回避数に応じて頻度を増やしていくのを思いついた
var ENEMY_CREATE = 100;
//敵の最大速度
var ENEMY_MAX_SPEED = 10;
//しろくまの飛ぶ高さ
var WHITE_BEAR_JUMP_HEIGHT = 13;
//プレイヤーのジャンプ高さ
var PLAYER_JUMP_HEIGHT = 8;
//ゲームバランスに関する設定値ココマデ

//敵の出現位置
var ENEMY_APPEAR_X = 300;
//キャラクターの表示位置（Y)
var CHARACTER_Y = 320 - (16 * 9) - 32;

//画面サイズ
var SCREEN_X = 320;
var SCREEN_Y = 320;

//状態
var STATUS_WAIT = 0;
var STATUS_WALK = 1;
var STATUS_JUMP = 2;
var STATUS_CRY = 3;
var STATUS_SHOOT = 4;

var player;
var game;


enchant();
window.onload = function(){
  // 前処理
  game = new Game(SCREEN_X, SCREEN_Y);
  game.fps =16;
  game.score = 0;
  game.score_revarage = 1;
  game.tick = 0;
  
  //画像の読み込み
  game.preload('http://enchantjs.com/assets/images/space3.gif', 
      'http://enchantjs.com/assets/images/map0.gif', 
      'http://enchantjs.com/assets/images/icon0.gif');

  // メイン処理
  game.onload = function(){
    // 背景
    var bg = new Sprite(SCREEN_X, SCREEN_Y);
    bg.backgroundColor = "rgb(0, 200, 255)";
    var matip = game.assets['http://enchantjs.com/assets/images/map0.gif'];
    var surface = new Surface(SCREEN_X, SCREEN_Y);
    for (var i = 0; i < SCREEN_Y; i+=16){
      surface.draw(matip, 16 * 7, 0, 16, 16, i, 320 - (16 * 9), 16, 16);
    }
    bg.image = surface;
    game.rootScene.addChild(bg);
    // ゲームパッド
    pad = new Pad();
    pad.y = 200;
    game.rootScene.addChild(pad);
    // ボタン
    var button = new Sprite(16, 16);
    button.image = game.assets['http://enchantjs.com/assets/images/icon0.gif'];
    button.frame = 19;
    button.scaleX = 6;
    button.scaleY = 6;
    button.x = 250;
    button.y = 250;
    game.rootScene.addChild(button);
    button.addEventListener(Event.TOUCH_START, function(){
      player.jump();
    });
    button.addEventListener(Event.TOUCH_END, function(){
      player.jump();
    });
    //スコア
    var scoreboard = new Label(16, 16);
    scoreboard.x = 100;
    scoreboard.text = game.score;
    game.rootScene.addChild(scoreboard);
    //難易度ラベル
    var difficult = new Label(16, 16);
    difficult.x = 0;
    difficult.text = "かんたん";
    game.rootScene.addChild(difficult);
    //倍率ラベル
    var revarage_label = new Label(16, 16);
    revarage_label.x = 200;
    revarage_label.text = "スコア倍率：" + game.score_revarage;
    game.rootScene.addChild(revarage_label);
    //プレイヤークマ
    player = new Bear(0, 160 - 16, CHARACTER_Y, 1);
    player.status = STATUS_WAIT;
    player.y_prev = player.y;
    player.F = PLAYER_JUMP_HEIGHT;
    
    //ゲーム制御用の変数
    var enemy_create_balance = ENEMY_CREATE;
    
    // ゲーム毎フレームの処理
    game.rootScene.addEventListener(Event.ENTER_FRAME, function(){
        //ヤラレチャッタ？
        if(player.status == STATUS_CRY){
          if(player.y > CHARACTER_Y){
            var retry_btn = new Label(64, 64);
            retry_btn.x = 70;
            retry_btn.y = 100;
            retry_btn.color = "#ffFF00";
            retry_btn.font = "24px monospace";
            retry_btn.text = "もう一度プレイする";
            game.rootScene.addChild(retry_btn);
            retry_btn.addEventListener(Event.TOUCH_START, function(){
              location.reload();
            });
          }
          return;
        }
        //ジャンプ中
        if(player.status == STATUS_JUMP){
          player.jump_as_mario();
          if(player.y == CHARACTER_Y){
              player.F = PLAYER_JUMP_HEIGHT;
              player.status = STATUS_WAIT;
              player.y_prev = player.y;
          }
        }
//        //Aボタン
//        if (game.input.a){
//          player.jump();
//        }
        //上
        if (game.input.up){
          player.jump();
        }
        //左
        if(game.input.left){
          player.x -= 6;
          player.scaleX = -1;
          if(player.x < 1) player.x = 1; //画面端に行けないようにする。
          if(player.status != STATUS_JUMP) player.status = STATUS_WALK;
        }
        //右
        if(game.input.right){
          player.x += 6;
          player.scaleX = 1;
          if(player.x > 290) player.x = 290; //画面端に行けないようにする。
          if(player.status != STATUS_JUMP) player.status = STATUS_WALK;
        }
        if(!game.input.right && !game.input.left){
          if(player.status != STATUS_JUMP) player.status = STATUS_WAIT;
        }
        player.tick++;
        if (player.status == STATUS_WAIT){
          player.frame = player.anim[0];
        }else if(player.status == STATUS_WALK){
          player.frame = player.anim[player.tick % 4];
        }else if (player.status == STATUS_JUMP){
          player.frame = player.anim[1];
        }
        game.tick++;
        //だんだん敵の出現頻度を上げる
        var enemy_create_temp;
        if(enemy_create_balance < 31) {
          enemy_create_temp = 15;
          dif_text = "Very Hard";
          difficult.color = "#ff0000";
        }
        if(enemy_create_balance > 30){
          enemy_create_temp = 30;
          dif_text = "Hard";
          difficult.color = "#cc0033";
        }
        if(enemy_create_balance > 50){
          enemy_create_temp = 50;
          dif_text = "Normal";
          difficult.color = "#990077";
        }
        if(enemy_create_balance > 70){
          enemy_create_temp = 60;
          dif_text = "Easy";
          difficult.color = "#6600BB";
        }
        if(enemy_create_balance > 90){
          enemy_create_temp = 80;
          dif_text = "Very Easy";
          difficult.color = "#3300FF";
        }
        if((game.tick % enemy_create_temp) === 0){
          // 指定のフレームごとに敵作る
          create_enemy();
          enemy_create_balance--;
        }
        if(game.tick == 1000000){
          //いくつが限界かしらんけど適当なとこでゼロに戻しとく。
          game.tick = 0;
        }
        difficult.text = dif_text;
        scoreboard.text = game.score;
        revarage_label.text = "スコア倍率：" + game.score_revarage;
      });
  };
  game.start();
};

//くまクラス。敵も味方もとりあえず共通で。
var Bear = enchant.Class.create(enchant.Sprite, {
  initialize: function(type, x, y, speed){
    // 見た目周りの設定など
    enchant.Sprite.call(this, 32, 32);
    this.image = game.assets['http://enchantjs.com/assets/images/space3.gif'];
    this.x = x; this.y = y;
    this.tick = 0;
    this.type = type;
    this.speed = speed;
    //向き
    this.scaleX = -1;
    //定数
    var TYPE_NORMAL = 1;
    var TYPE_WHITE = 2;
    var TYPE_GIRL = 0;
    var TYPE_SPACE = 3;
    var TYPE_BOARD = 4;
   
    //ジャンプ用
    this.F = 10;
    this.y_prev = this.y;
    
    //タイプ別分岐
    switch(this.type){
      //しろくま
      case TYPE_WHITE:
        this.anim = [5, 6, 5, 7, 8];
        this.F = WHITE_BEAR_JUMP_HEIGHT;
        break;
      case TYPE_GIRL:
        //女の子くま
        this.anim = [10, 11, 10, 12, 13];
        break;
      case TYPE_SPACE:
        //宇宙くま
        this.anim = [15, 16, 15, 17, 18];
        this.y -= 32;
        this.y_prev = this.y;
        break;
      case TYPE_BOARD:
        //スケボーくま
        this.anim = [4, 4, 4, 4, 3];
        break;
      default:
        //ノーマルくま
        this.anim = [0, 1, 0, 2, 3];
        break;
    }
    this.frame = this.anim[0];
    
    //イベントの設定
    this.addEventListener(Event.ENTER_FRAME, function(){
      this.move();
      this.conflict();
      this.defeated();
      this.shoot();
      this.go_out();
    });
    game.rootScene.addChild(this);
    
    //くまの移動処理
    this.move = function(){
      if (player.status == STATUS_CRY) return;
      if (this == player) return;
      if (this.status == STATUS_CRY) return;
      if (this.status == STATUS_SHOOT) return;
      // クマの種類別に動きを切り替え
      switch(this.type){
        case TYPE_WHITE: // しろくま
          //飛び跳ねる
          this.jump_as_mario();
          if(this.y == CHARACTER_Y){
            this.tick = 0;
            this.F = WHITE_BEAR_JUMP_HEIGHT;
          }
          break;
        case TYPE_SPACE: // 宇宙くま
          //飛ばないと当たらない位置にいる
          break;
        case TYPE_BOARD: //スケボーくま
          //折り返してくる    
          if (this.scaleX < 0){
            if(this.x < this.speed + 5) this.scaleX *= -1;
          }
          else{
            //反転後
            this.x += this.speed*2;
          }
          break;
        default:
          break;
        }
        this.x -= this.speed;
        // 共通処理
        this.tick++;
        this.frame = this.anim[this.tick % 4];
        // やられモード
        if(this.x < -5 || this.x > ENEMY_APPEAR_X) {
          this.status = STATUS_CRY;
        }
    };

    // くまの衝突処理
    this.conflict = function(){
      if(this == player) return;
      //敵がプレイヤーに触れてプレイヤーがやられる処理。
      if(this.within(player, YARARE_HANTEI)){
        if(this.status != STATUS_CRY && this.status != STATUS_SHOOT) {
          player.status = STATUS_CRY; // ヤラレチャッタ
        }
      }
      //やられ中の敵にプレイヤーが触れて吹っ飛ばす処理
      if(this.intersect(player)){
        if(this.status == STATUS_CRY){
          this.status = STATUS_SHOOT;
          this.F = 20;
          this.y_prev = this.y;
        }
      }
    };
    // ジャンプ
    this.jump = function(){
      if(this.status == STATUS_CRY) return;
      this.status = STATUS_JUMP;
    };
    //撃破
    this.defeated = function(){
      if(this.status != STATUS_CRY) return;
      this.frame = this.anim[4];
      this.x -= this.speed * this.scaleX;
      this.jump_as_mario();
    };
    //ふっとばし
    this.shoot = function(){
      if(this.status != STATUS_SHOOT) return;
      if (game.frame % 2 === 0){
        this.scale(0.97, 0.97);
        this.rotate(45);
      }
      else{
        this.jump_as_mario();
      }
      scale = Math.abs(this.scaleX);
      if(scale < 0.33){
        this.visible = false;
      }
    };
    //退場したキャラのデータを削除する
    this.go_out = function(){
      // キャラデータの削除
      if(this.y > SCREEN_Y || this.x > SCREEN_X || this.x < -10) {
        game.score += Math.round(1 * game.score_revarage);
        if (this.status == STATUS_SHOOT){
          game.score += Math.round(9 * game.score_revarage);
          game.score_revarage = Math.round(game.score_revarage * 1.5);
        }
        else{
          game.score_revarage = 1;
        }
        game.rootScene.removeChild(this);
        delete this;
      }
    };
    //マリオジャンプの挙動を見よ
    this.jump_as_mario = function(){
      y_temp = this.y;
      this.y -= this.y_prev - this.y + this.F;
      this.y_prev = y_temp;
      this.F = -1;
    };
  }
});

//敵を作る
function create_enemy(){
  var type = Math.floor(Math.random() * 4) + 1;
  var speed = Math.floor(Math.random() * ENEMY_MAX_SPEED) + 1;
  bear = new Bear(type, ENEMY_APPEAR_X, CHARACTER_Y, speed);
}
