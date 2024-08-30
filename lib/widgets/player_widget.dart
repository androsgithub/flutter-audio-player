import 'dart:async';

import 'package:audio_player/services/player_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  final String? songName;
  final String? artistName;
  final RepeatType? repeatMode;
  final void Function()? nextSong;
  final void Function()? previousSong;
  final void Function()? changeRepeatMode;

  const PlayerWidget({
    super.key,
    required this.player,
    this.nextSong,
    this.previousSong,
    this.songName,
    this.artistName,
    this.repeatMode,
    this.changeRepeatMode,
  });

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  double get _volume => player.volume;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position?.toString().split('.').first ?? '';

  bool _isMuted = false;

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                widget.songName ?? "Song name",
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.artistName ?? "Artist name",
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              key: const Key('mode_button'),
              onPressed: widget.changeRepeatMode,
              icon: widget.repeatMode != null &&
                      widget.repeatMode == RepeatType.random
                  ? const Icon(Icons.shuffle)
                  : widget.repeatMode == RepeatType.linear
                      ? const Icon(Icons.repeat)
                      : const Icon(Icons.repeat_one),
            ),
            IconButton(
              key: const Key('rewind_button'),
              onPressed: widget.previousSong,
              icon: const Icon(Icons.fast_rewind),
            ),
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? _pause : _play,
              icon: _isPlaying
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
            ),
            IconButton(
              key: const Key('foward_button'),
              onPressed: widget.nextSong,
              icon: const Icon(Icons.fast_forward),
            ),
            IconButton(
              key: const Key('options_button'),
              onPressed: _mute,
              icon: _volume > 0
                  ? const Icon(Icons.volume_up)
                  : const Icon(Icons.volume_off),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _position != null
                  ? _positionText
                  : _duration != null
                      ? _durationText
                      : '',
              style: const TextStyle(fontSize: 16.0),
            ),
            Text(
              _position != null
                  ? _durationText
                  : _duration != null
                      ? _durationText
                      : '',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
              thumbColor: Colors.grey,
              trackHeight: 1,
              activeTrackColor: Colors.grey,
              valueIndicatorShape: RoundSliderThumbShape(),
              minThumbSeparation: 10,
              thumbShape: RoundSliderThumbShape(
                  elevation: 0, enabledThumbRadius: 5, pressedElevation: 0)),
          child: Slider(
            label: _durationText,
            onChanged: (value) {
              final duration = _duration;
              if (duration == null) {
                return;
              }
              final position = value * duration.inMilliseconds;
              player.seek(Duration(milliseconds: position.round()));
            },
            value: (_position != null &&
                    _duration != null &&
                    _position!.inMilliseconds > 0 &&
                    _position!.inMilliseconds < _duration!.inMilliseconds)
                ? _position!.inMilliseconds / _duration!.inMilliseconds
                : 0.0,
          ),
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _mute() async {
    if (_isMuted) {
      await player.setVolume(1);
    } else {
      await player.setVolume(0);
    }
    _isMuted = !_isMuted;
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
