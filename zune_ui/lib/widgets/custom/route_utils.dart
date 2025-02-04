enum ApplicationRoute {
  home("/", "home"),
  player("/playing", "now-playing"),
  music("/music", "music-library");

  const ApplicationRoute(this.route, this.name);
  final String route;
  final String name;
}
