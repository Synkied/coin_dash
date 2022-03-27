extends Node2D

export (PackedScene) var Coin
export (PackedScene) var Powerup
export (PackedScene) var Cactus
export (int) var playtime

var level = 0
var score = 0
var time_left = 0
var screensize
var playing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	$Player.hide()

func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start($PlayerStart.position)
	$Player.show()
	$GameTimer.start()
	spawn_coins()
	spawn_cacti()
	$HUD.update_score(score)
	$HUD.update_level(level)
	$HUD.update_timer(time_left)

func spawn_coins():
	for _i in range(4 + level):
		var c = Coin.instance()
		$CoinContainer.add_child(c)
		c.screensize = screensize
		c.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y))


func spawn_cacti():
	free_cacti()
	for _i in range(level):
		var c = Cactus.instance()
		$CactusContainer.add_child(c)
		c.screensize = screensize
		c.position = Vector2(rand_range(20, screensize.x - 20), rand_range(20, screensize.y - 20))

func free_coins():
	for coin in $CoinContainer.get_children():
		coin.queue_free()

func free_cacti():
	for cactus in $CactusContainer.get_children():
		cactus.queue_free()

func game_over():
	playing = false
	$GameTimer.stop()
	free_coins()

	$HUD.show_game_over()
	$Player.die()
	$EndSound.play()

func _process(delta):
	if playing and $CoinContainer.get_child_count() == 0:
		$LevelSound.play()
		level += 1
		time_left += 5
		spawn_coins()
		spawn_cacti()
		$PowerupTimer.wait_time = rand_range(5, 10)
		$PowerupTimer.start()
		$HUD.update_level(level)

func _on_GameTimer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()

func _on_Player_hurt():
	game_over()

func _on_Player_pickup(type):
	match type:
		"coin":
			score += 1
			$CoinSound.play()
			$HUD.update_score(score)
		"powerup":
			time_left += 5
			$PowerupSound.play()
			$HUD.update_score(score)


func _on_PowerupTimer_timeout():
	var p = Powerup.instance()
	add_child(p)
	p.screensize = screensize
	p.position = Vector2(
		rand_range(0, screensize.x),
		rand_range(0, screensize.y)
	)
