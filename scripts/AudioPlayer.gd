class_name AudioPlayer
extends AudioStreamPlayer

func switch_to(clip : String):
	if !playing: play();
	var playback : AudioStreamPlaybackInteractive = get_stream_playback();
	playback.switch_to_clip_by_name(clip);
