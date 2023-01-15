extends Node2D

signal player_hit
signal bullet_shot

const FRICTION_RATE: float = 20
const PLAYER_SPEED: float = 75
var bullet: PackedScene = preload("res://scene/MainGame/PlayerBullet/Bullet.tscn")

var speed_multiplier: float = 1
var velocity: Vector2 = Vector2(0,0)
var stats: Dictionary
var invulnerable: bool = false

func _ready():
	self.connect("player_hit",Global._on_player_hit)
	self.connect("player_hit",take_damage)
	self.connect("bullet_shot",Global._on_player_fire)
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
		new_bullet.start_point = position
		new_bullet.angle = Global.angle+PI
		get_parent().add_child(new_bullet)
		emit_signal("bullet_shot")
	speed_multiplier = 1 - 0.5*float(Input.is_action_pressed("ingame_focus"))
	position += velocity * delta
	Global.player_pos = position
	velocity = lerp(velocity,Vector2(0,0),FRICTION_RATE*delta)
	position.x = clamp(position.x,0,300)
	position.y = clamp(position.y,0,350)
	$Indicator.rotation = -Global.angle

func _on_hitbox_area_entered(area: Area2D) -> void:
	if !invulnerable: 
		emit_signal("player_hit")

func take_damage() -> void:
	$Invulnerability.start(2)
	$AnimationPlayer.play("Invulnerability")
	invulnerable = true

func _on_invulnerability_timeout() -> void:
	invulnerable = false
