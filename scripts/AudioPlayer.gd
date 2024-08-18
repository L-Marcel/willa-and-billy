class_name AudioPlayer
extends AudioStreamPlayer

@export var _current_music : String = "Default";

func switch_to(clip : String):
	_current_music = clip;
	get_stream_playback().switch_to_clip_by_name(clip);
	
func get_current_music() -> String:
	return _current_music;
