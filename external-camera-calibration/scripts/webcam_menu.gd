extends MenuButton
class_name WebCamMenu

@export var tex: CameraTexture
@export var rect: TextureRect

var camera_extension: CameraServerExtension

func _ready() -> void:
	get_popup().about_to_popup.connect(pre_popup)
	get_popup().id_pressed.connect(id_press)

	if not OS.get_name().to_lower().contains("linux"):
		camera_extension = CameraServerExtension.new()
		camera_extension.request_permission()
		
func disable_current_feed():
	if tex.camera_feed_id == 0:
		return
	var feed = CameraServer.get_feed(tex.camera_feed_id -1)
	if feed != null:
		feed.feed_is_active = false
		
func switch_to_feed(index: int):
	print(index)
	disable_current_feed()
	var feed = CameraServer.get_feed(index-1)
	if feed == null:
		print("No feed at index "+str(index))
		return
	if feed.formats.size() == 0 :
		print("Camera has no formats!")
		return
	feed.set_format(0,{})
	feed.feed_is_active = true
	tex.camera_feed_id = index
	tex.which_feed = CameraServer.FEED_YCBCR_IMAGE

func id_press(index: int) -> void:
	switch_to_feed(index)
	if rect.texture.is_class("ViewportTexture"): #disable the fake camera when it's not on screen
		var vt: ViewportTexture = rect.texture
		var v: Viewport = vt.get_local_scene().get_node_or_null(vt.viewport_path)
		v.disable_3d =true
		
	rect.texture = tex

func pre_popup() -> void:
	var pop = get_popup()
	pop.clear()
	for feed in CameraServer.feeds():
		pop.add_item(feed.get_name(), feed.get_id())
