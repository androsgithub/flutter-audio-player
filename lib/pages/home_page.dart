import 'package:audio_player/repositories/app_settings_repository.dart';
import 'package:audio_player/repositories/songs_repository.dart';
import 'package:audio_player/services/player_service.dart';
import 'package:audio_player/shared/widgets/label_custom.dart';
import 'package:audio_player/shared/widgets/title_custom.dart';
import 'package:audio_player/widgets/player_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

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
    paths = [];
    paths = await appSettingsRepository.getPaths();

    playerService.playlist = [];
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      for (var path in paths) {
        playerService.playlist
            .addAll(await songsRepository.getSongs(path: path));
      }
    } else {
      playerService.playlist.addAll(await songsRepository.getSongs());
    }
    if (playerService.playlist.isNotEmpty) {
      playerService
          .setSong(playerService.playlist[playerService.songIndex].data);
    }

    setState(() {});
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: openPlaylist, icon: const Icon(Icons.list)),
          IconButton(onPressed: openConfig, icon: const Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Center(
          child: playerService.playlist.isEmpty
              ? const Text("Nenhuma musica selecionada")
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: const FittedBox(
                          child: Icon(
                            Icons.play_circle_rounded,
                          ),
                        ),
                      ),
                    ),
                    PlayerWidget(
                        player: playerService.player,
                        songName: playerService
                            .playlist[playerService.songIndex].title,
                        artistName: playerService
                            .playlist[playerService.songIndex].artist,
                        nextSong: playerService.nextSong,
                        previousSong: playerService.previousSong,
                        changeRepeatMode: playerService.changeRepeatType,
                        repeatMode: playerService.repeatType),
                  ],
                ),
        ),
      ),
    );
  }

  //Playlist
  openPlaylist() {
    var playlistFiltered = playerService.playlist;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                title: TitleCustom(
                    text: "Playlist - ${playerService.playlist.length} files"),
                content: StatefulBuilder(
                  builder: (context, customSetState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          customSetState(() {
                            if (value.isEmpty) {
                              playlistFiltered = playerService.playlist;
                            } else {
                              playlistFiltered = playerService.playlist
                                  .where((song) =>
                                      song.title
                                          .toString()
                                          .toLowerCase()
                                          .contains(value) ||
                                      song.artist
                                          .toString()
                                          .toLowerCase()
                                          .contains(value) ||
                                      song.data
                                          .toString()
                                          .toLowerCase()
                                          .contains(value))
                                  .toList();
                            }
                          });
                        },
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          child: ListView.builder(
                            itemCount: playlistFiltered.length,
                            itemBuilder: (context, index) {
                              var song = playlistFiltered[index];
                              return ListTile(
                                key: ValueKey(index),
                                selected: playerService.songIndex == index,
                                selectedColor:
                                    Theme.of(context).colorScheme.tertiary,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        song.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          customSetState(() {
                                            playerService.songIndex = index;
                                            playerService.setSong(song.data);
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
                    ],
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2))),
            title: const TitleCustom(text: "Configuracoes"),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 350),
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LabelCustom(text: "Volume"),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                            value: playerService.player.volume,
                            thumbColor: Theme.of(context).colorScheme.tertiary,
                            activeColor: Theme.of(context).colorScheme.tertiary,
                            onChanged: (value) async {
                              await playerService.player.setVolume(value);
                              setState(() {});
                            }),
                      ),
                      Text("${(playerService.player.volume * 100).round()}%")
                    ],
                  ),
                  Visibility(
                    visible: Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS,
                    child: Row(
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
                  ),
                  Visibility(
                    visible: Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS,
                    child: Container(
                      clipBehavior: Clip.hardEdge, // this
                      decoration: BoxDecoration(
                        border: Border.all(width: 0, color: Colors.transparent),
                      ),

                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: paths.length,
                        itemBuilder: (context, index) {
                          var path = paths[index];
                          return Slidable(
                            startActionPane: ActionPane(
                                extentRatio: 0.4,
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    label: "Remover",
                                    backgroundColor: Colors.red,
                                    onPressed: (context) {
                                      setState(() {
                                        paths = paths
                                            .where((path_) => path_ != path)
                                            .toList();
                                      });
                                    },
                                    icon: Icons.delete,
                                  )
                                ]),
                            child: ListTile(
                              title: Text(path),
                            ),
                          );
                        },
                      ),
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
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ))
            ],
          ),
        );
      },
    );
  }
}
