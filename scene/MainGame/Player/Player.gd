extends Node2D

signal player_hit
signal bullet_shot
signal bullet_reload
signal bullet_grazed

const FRICTION_RATE: float = 20
const PLAYER_SPEED: float = 75
var bullet: PackedScene = preload("res://scene/MainGame/PlayerBullet/Bullet.tscn")

var speed_multiplier: float = 1
var velocity: Vector2 = Vector2(0,0)
var stats: Dictionary
var invulnerable: bool = false
var game: Node

func _ready():
	game = get_parent()
	self.connect("player_hit",Global._on_player_hit)
	self.connect("player_hit",take_damage)
	self.connect("bullet_shot",Global._on_player_fire)
	self.connect("bullet_shot",game._on_player_fire)
	self.connect("bullet_reload",Global._on_player_reload)
	self.connect("bullet_grazed",Global._on_player_graze)
	stats = Global.player_stats

func _process(delta):
	if Input.is_action_pressed("ingame_move_down"):
		velocity.y = PLAYER_SPEED * speed_multiplier
	elif Input.is_action_pressed("ingame_move_up"):
		velocity.y = -PLAYER_SPEED * speed_multiplier
	if Input.is_action_pressed("ingame_move_right"):
		velocity.x = PLAYER_SPEED * speed_multiplier
	elif Input.is_action_pressed("ingame_move_left"): 
		velocity.x = -PLAYER_SPEED * speed_multiplier
	if Input.is_action_just_pressed("ingame_fire") and stats.Bullets > 0:
		var new_bullet = bullet.instantiate()
		new_bullet.start_point = $Sprite/Arm1/Hand1/Gun/BulletSpawn.global_position
		new_bullet.angle = Global.angle+PI
		get_parent().add_child(new_bullet)
		emit_signal("bullet_shot")
		$Reload.stop()
	if Input.is_action_just_pressed("ingame_focus"):
		$Reload.start(0.5)
	if Input.is_action_just_released("ingame_focus"):
		$Reload.stop()
	speed_multiplier = 1 - 0.5*float(Input.is_action_pressed("ingame_focus"))
	position += velocity * delta
	Global.player_pos = position
	velocity = lerp(velocity,Vector2(0,0),FRICTION_RATE*delta)
	position.x = clamp(position.x,0,300)
	position.y = clamp(position.y,0,350)
	$Indicator.rotation = -Global.angle
	$Sprite/Arm1.rotation = -Global.angle

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Graze":
		emit_signal("bullet_grazed")
		area.queue_free()
	elif !invulnerable: 
		emit_signal("player_hit")

func take_damage() -> void:
	$Invulnerability.start(2)
	$AnimationPlayer.play("Invulnerability")
	invulnerable = true

func _on_invulnerability_timeout() -> void:
	invulnerable = false

func _on_reload_timeout():
	if stats.Bullets < 6:
		emit_signal("bullet_reload")
		$Reload.start(0.5)
