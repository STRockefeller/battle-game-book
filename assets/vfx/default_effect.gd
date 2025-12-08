extends Node2D

# 預設特效 - 簡單的閃光效果

@onready var sprite = $Sprite2D
var duration = 0.5
var elapsed = 0.0

func _ready():
	# 創建一個簡單的白色閃光
	sprite = Sprite2D.new()
	add_child(sprite)
	
	# 使用程式生成的白色方塊
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0.8))
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	
	# 開始淡出動畫
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, duration)
	tween.tween_callback(queue_free)

func _process(delta):
	elapsed += delta
	# 擴大效果
	scale = Vector2.ONE * (1.0 + elapsed * 2.0)
