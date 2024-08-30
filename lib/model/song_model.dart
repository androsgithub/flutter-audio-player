class SongModel {
  String songName = "";
  String artistName = "";
  String songPath = "";
  String songImage = "";

  SongModel.vazio();
  SongModel.simples(this.songName, this.songPath);
  SongModel(this.songName, this.artistName, this.songPath, this.songImage);
}
