# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#敵を作る
create_enemy = ->
  type = Math.floor(Math.random() * 4) + 1
  speed = Math.floor(Math.random() * ENEMY_MAX_SPEED) + 1
  bear = new Bear(type, ENEMY_APPEAR_X, CHARACTER_Y, speed)
# ゲームバランスに関する設定値
#やられ判定。これを大きくすれば詐欺判定。小さくすれば弾幕シューティング的判定に・・・。
#var YARARE_HANTEI = 0; //無敵モード
YARARE_HANTEI = 5
#敵の出現間隔。この数字を小さくすれば無理ゲー。大きくすればヌルゲーに。というのを、敵の回避数に応じて頻度を増やしていくのを思いついた
ENEMY_CREATE = 100
#敵の最大速度
ENEMY_MAX_SPEED = 10
#しろくまの飛ぶ高さ
WHITE_BEAR_JUMP_HEIGHT = 13
#プレイヤーのジャンプ高さ
PLAYER_JUMP_HEIGHT = 8
#ゲームバランスに関する設定値ココマデ
#敵の出現位置
ENEMY_APPEAR_X = 300
#キャラクターの表示位置（Y)
CHARACTER_Y = 320 - (16 * 9) - 32
#画面サイズ
SCREEN_X = 320
SCREEN_Y = 320
#状態
STATUS_WAIT = 0
STATUS_WALK = 1
STATUS_JUMP = 2
STATUS_CRY = 3
STATUS_SHOOT = 4
# 前処理
player = undefined
game = undefined
enchant()
window.onload = ->
  game = new Game(SCREEN_X, SCREEN_Y)
  game.fps = 16
  game.score = 0
  game.score_magnification = 1
  game.max_magnification = 1
  game.tick = 0
  #画像の読み込み
  game.preload "http://enchantjs.com/assets/images/space3.gif", "http://enchantjs.com/assets/images/map0.gif", "http://enchantjs.com/assets/images/icon0.gif"
  # メイン処理
  game.onload = ->
    # 背景
    bg = new Sprite(SCREEN_X, SCREEN_Y)
    bg.backgroundColor = "rgb(0, 200, 255)"
    matip = game.assets["http://enchantjs.com/assets/images/map0.gif"]
    surface = new Surface(SCREEN_X, SCREEN_Y)
    i = 0

    while i < SCREEN_Y
      surface.draw matip, 16 * 7, 0, 16, 16, i, 320 - (16 * 9), 16, 16
      i += 16
    bg.image = surface
    game.rootScene.addChild bg
    # ゲームパッド
    pad = new Pad()
    pad.y = 200
    game.rootScene.addChild pad
    # ボタン
    button = new Sprite(16, 16)
    button.image = game.assets["http://enchantjs.com/assets/images/icon0.gif"]
    button.frame = 19
    button.scaleX = 6
    button.scaleY = 6
    button.x = 250
    button.y = 250
    game.rootScene.addChild button
    button.addEventListener Event.TOUCH_START, ->
      player.jump()

    button.addEventListener Event.TOUCH_END, ->
      player.jump()

    #スコア
    scoreboard = createLabelWithFont(16, 16, 14)
    scoreboard.x = 100
    scoreboard.y = 5
    scoreboard.text = game.score
    game.rootScene.addChild scoreboard
    #難易度ラベル
    difficult = createLabelWithFont(16, 16, 14)
    difficult.x = 10
    difficult.y = 5
    difficult.text = "かんたん"
    game.rootScene.addChild difficult
    #倍率ラベル
    magnification_label = createLabelWithFont(16, 16, 14)
    magnification_label.x = 200
    magnification_label.y = 5
    magnification_label.text = "X" + game.score_magnification
    game.rootScene.addChild magnification_label
    
    #プレイヤークマ
    player = new Bear(0, 160 - 16, CHARACTER_Y, 1)
    player.status = STATUS_WAIT
    player.y_prev = player.y
    player.F = PLAYER_JUMP_HEIGHT
    enemy_create_balance = ENEMY_CREATE
    
    #ゲームオーバーフラグ
    gameOver = false
    # ゲーム毎フレームの処理
    game.rootScene.addEventListener Event.ENTER_FRAME, ->
      #ヤラレチャッタ？
      if player.status is STATUS_CRY
        if player.y > CHARACTER_Y && gameOver is false
          gameOver = true
          sendScore(game.score, difficult.text, game.max_magnification)

          retry_btn = createLabelWithFont(64, 64)
          retry_btn.x = 70
          retry_btn.y = 100
          retry_btn.color = "#ffFF00"
          retry_btn.text = "Play again"
          game.rootScene.addChild retry_btn
          retry_btn.addEventListener Event.TOUCH_START, ->
            location.reload()

        return
      #ジャンプ中
      if player.status is STATUS_JUMP
        player.jump_as_mario()
        if player.y is CHARACTER_Y
          player.F = PLAYER_JUMP_HEIGHT
          player.status = STATUS_WAIT
          player.y_prev = player.y
      #上
      player.jump()  if game.input.up
      #左
      if game.input.left
        player.x -= 6
        player.scaleX = -1
        #画面端に行けないようにする。
        player.x = 1  if player.x < 1
        player.status = STATUS_WALK  unless player.status is STATUS_JUMP
      #右
      if game.input.right
        player.x += 6
        player.scaleX = 1
        #画面端に行けないようにする。
        player.x = 290  if player.x > 290
        player.status = STATUS_WALK  unless player.status is STATUS_JUMP
      #静止状態
      unless game.input.right || game.input.left
        player.status = STATUS_WAIT  unless player.status is STATUS_JUMP
      player.tick++
      if player.status is STATUS_WAIT
        player.frame = player.anim[0]
      else if player.status is STATUS_WALK
        player.frame = player.anim[player.tick % 4]
      else player.frame = player.anim[1]  if player.status is STATUS_JUMP
      game.tick++
      enemy_create_temp = undefined
      #だんだん敵の出現頻度を上げる
      if enemy_create_balance < 31
        enemy_create_temp = 15
        dif_text = "Very Hard"
        difficult.color = "#ff0000"
      if enemy_create_balance > 30
        enemy_create_temp = 30
        dif_text = "Hard"
        difficult.color = "#cc0033"
      if enemy_create_balance > 50
        enemy_create_temp = 50
        dif_text = "Normal"
        difficult.color = "#990077"
      if enemy_create_balance > 70
        enemy_create_temp = 60
        dif_text = "Easy"
        difficult.color = "#6600BB"
      if enemy_create_balance > 90
        enemy_create_temp = 80
        dif_text = "Very Easy"
        difficult.color = "#3300FF"
      if (game.tick % enemy_create_temp) is 0
        # 指定のフレームごとに敵作る
        create_enemy()
        enemy_create_balance--
      
      #いくつが限界かしらんけど適当なとこでゼロに戻しとく。
      game.tick = 0  if game.tick is 1000000
      difficult.text = dif_text
      scoreboard.text = game.score
      magnification_label.text = "X" + game.score_magnification


  game.start()

#くまクラス。敵も味方もとりあえず共通で。
Bear = enchant.Class.create(enchant.Sprite,
  initialize: (type, x, y, speed) ->
    enchant.Sprite.call this, 32, 32
    # 見た目周りの設定など
    @image = game.assets["http://enchantjs.com/assets/images/space3.gif"]
    @x = x
    @y = y
    @tick = 0
    @type = type
    @speed = speed
    #向き
    @scaleX = -1
    #定数
    TYPE_NORMAL = 1
    TYPE_WHITE = 2
    TYPE_GIRL = 0
    TYPE_SPACE = 3
    TYPE_BOARD = 4
    #ジャンプ用
    @F = 10
    @y_prev = @y
    #タイプ別分岐
    switch @type
      #しろくま
      when TYPE_WHITE
        @anim = [5, 6, 5, 7, 8]
        @F = WHITE_BEAR_JUMP_HEIGHT
      #女の子くま
      when TYPE_GIRL
        @anim = [10, 11, 10, 12, 13]
      #宇宙くま
      when TYPE_SPACE
        @anim = [15, 16, 15, 17, 18]
        @y -= 32
        @y_prev = @y
      #スケボーくま
      when TYPE_BOARD
        @anim = [4, 4, 4, 4, 3]
      #ノーマルくま
      else
        @anim = [0, 1, 0, 2, 3]
    @frame = @anim[0]
    #イベントの設定
    @addEventListener Event.ENTER_FRAME, ->
      @move()
      @conflict()
      @defeated()
      @shoot()
      @go_out()

    game.rootScene.addChild this
    #くまの移動処理
    @move = ->
      return  if player.status is STATUS_CRY
      return  if this is player
      return  if @status is STATUS_CRY
      return  if @status is STATUS_SHOOT
      # クマの種類別に動きを切り替え
      switch @type
        # しろくま
        when TYPE_WHITE
          #飛び跳ねる
          @jump_as_mario()
          if @y is CHARACTER_Y
            @tick = 0
            @F = WHITE_BEAR_JUMP_HEIGHT

        # 宇宙くま
        # なにもしない（通常より高い位置から出現するだけ）

        # スケボーくま
        when TYPE_BOARD
          #折り返してくる    
          if @scaleX < 0
            @scaleX *= -1  if @x < @speed + 5
          else
            #反転後
            @x += @speed * 2
        else

      # 共通処理
      @x -= @speed
      @tick++
      @frame = @anim[@tick % 4]
      # やられモード
      @status = STATUS_CRY  if @x < -5 or @x > ENEMY_APPEAR_X

    # くまの衝突処理
    @conflict = ->
      #敵がプレイヤーに触れてプレイヤーがやられる処理。
      return  if this is player
      player.status = STATUS_CRY  if @status isnt STATUS_CRY and @status isnt STATUS_SHOOT  if @within(player, YARARE_HANTEI)# ヤラレチャッタ
#やられ中の敵にプレイヤーが触れて吹っ飛ばす処理
      if @intersect(player)
        if @status is STATUS_CRY
          @status = STATUS_SHOOT
          @F = 20
          @y_prev = @y

    # ジャンプ
    @jump = ->
      return  if @status is STATUS_CRY
      @status = STATUS_JUMP

    #撃破
    @defeated = ->
      return  unless @status is STATUS_CRY
      @frame = @anim[4]
      @x -= @speed * @scaleX
      @jump_as_mario()

    #ふっとばし
    @shoot = ->
      return  unless @status is STATUS_SHOOT
      if game.frame % 2 is 0
        @scale 0.97, 0.97
        @rotate 45
      else
        @jump_as_mario()
      scale = Math.abs(@scaleX)
      @visible = false  if scale < 0.33

    #退場したキャラのデータを削除する
    @go_out = ->
      if @y > SCREEN_Y or @x > SCREEN_X or @x < -10
        game.score += Math.round(1 * game.score_magnification)
        if @status is STATUS_SHOOT
          game.score += Math.round(9 * game.score_magnification)
          game.score_magnification = Math.round(game.score_magnification * 1.5)
          game.max_magnification = game.score_magnification if game.max_magnification < game.score_magnification
        else
          game.score_magnification = 1
        # キャラデータの削除
        game.rootScene.removeChild this
        delete this

    #マリオジャンプの挙動を見よ
    @jump_as_mario = ->
      y_temp = @y
      @y -= @y_prev - @y + @F
      @y_prev = y_temp
      @F = -1
)

createLabelWithFont = (x, y, fontSize = 24) ->
  label = new Label(x, y)
  label.font = "#{fontSize}px game_font"
  label
