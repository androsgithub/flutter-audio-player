class LocalSongModel {
  String songName = "";
  String artistName = "";
  String songPath = "";
  String songImage = "";

  LocalSongModel.vazio();
  LocalSongModel.simples(this.songName, this.songPath);
  LocalSongModel(this.songName, this.artistName, this.songPath, this.songImage);
}
