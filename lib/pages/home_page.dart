import 'package:audio_player/repositories/app_settings_repository.dart';
import 'package:audio_player/repositories/songs_repository.dart';
import 'package:audio_player/services/player_service.dart';
import 'package:audio_player/shared/widgets/label_custom.dart';
import 'package:audio_player/shared/widgets/title_custom.dart';
import 'package:audio_player/widgets/player_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //repositories
  var appSettingsRepository = AppSettingsRepository();
  var songsRepository = SongsRepository();

  //services
  late PlayerService playerService;

  //utils
  List<String> paths = [];

  //inicializar

  _pegarPaths() async {
    paths = await appSettingsRepository.getPaths();
    setState(() {
      for (var path in paths) {
        playerService.playlist.addAll(songsRepository.getSongs(path));
      }
    });
  }

  _inicializar() async {
    _pegarPaths();
  }

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    playerService.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    playerService = Provider.of<PlayerService>(context);
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: openPlaylist, icon: const Icon(Icons.list)),
                  IconButton(
                      onPressed: openConfig, icon: const Icon(Icons.settings))
                ],
              ),
              playerService.playlist.isEmpty
                  ? const Center(child: Text("Nenhuma musica selecionada"))
                  : Column(
                      children: [
                        AspectRatio(
                            aspectRatio: 1,
                            child: playerService
                                        .playlist[playerService.songIndex]
                                        .songImage ==
                                    ""
                                ? const Icon(
                                    Icons.play_circle_rounded,
                                    size: 256,
                                  )
                                : Image.network(
                                    playerService
                                        .playlist[playerService.songIndex]
                                        .songImage,
                                    fit: BoxFit.cover,
                                  )),
                        const SizedBox(height: 5),
                        PlayerWidget(
                            player: playerService.player,
                            songName: playerService
                                .playlist[playerService.songIndex].songName,
                            artistName: playerService
                                .playlist[playerService.songIndex].artistName,
                            nextSong: playerService.nextSong,
                            previousSong: playerService.previousSong,
                            changeRepeatMode: playerService.changeRepeatType,
                            repeatMode: playerService.repeatType),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  openPlaylist() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2))),
                title: const TitleCustom(text: "Playlist"),
                content: StatefulBuilder(
                  builder: (context, customSetState) => Container(
                    constraints: const BoxConstraints(maxWidth: 350),
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: playerService.playlist.length,
                      itemBuilder: (context, index) {
                        var song = playerService.playlist[index];
                        return ListTile(
                          selected: playerService.songIndex == index,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  song.songName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    customSetState(() {
                                      playerService.songIndex = index;
                                      playerService.setSong(song.songPath);
                                    });
                                  },
                                  icon: const Icon(Icons.play_arrow))
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Fechar"),
                  )
                ]));
  }

  openConfig() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2))),
            title: const TitleCustom(text: "Configuracoes"),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 350),
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LabelCustom(text: "Volume"),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                            value: playerService.player.volume,
                            onChanged: (value) async {
                              await playerService.player.setVolume(value);
                              setState(() {});
                            }),
                      ),
                      Text("${(playerService.player.volume * 100).round()}%")
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const LabelCustom(text: "Diretorios"),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              limpar() {
                                setState(() {
                                  paths = [];
                                  appSettingsRepository.setPaths([]);
                                  playerService.playlist = [];
                                  Navigator.pop(context);
                                });
                              }

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Deseja mesmo limpar?"),
                                  content: const Text(
                                      "Você ira perder todas as suas musicas!"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancelar")),
                                    TextButton(
                                        onPressed: limpar,
                                        child: const Text("Confirmar"))
                                  ],
                                ),
                              );
                            },
                            child: const Text("Limpar"),
                          )
                        ],
                      ),
                      IconButton(
                          onPressed: () async {
                            String? selectedDirectory =
                                await FilePicker.platform.getDirectoryPath();
                            if (selectedDirectory == null) {
                              return;
                            }

                            setState(() {
                              paths.add(selectedDirectory);
                            });
                          },
                          icon: const Icon(Icons.add)),
                    ],
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: paths.length,
                      itemBuilder: (context, index) {
                        var path = paths[index];
                        return ListTile(title: Text(path));
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    await appSettingsRepository.setPaths(paths);
                    await appSettingsRepository
                        .setVolume(playerService.player.volume);
                    _pegarPaths();
                    Navigator.pop(context);
                  },
                  child: const Text("Salvar"))
            ],
          ),
        );
      },
    );
  }
}
