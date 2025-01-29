enum ApplicationRoute {
  home("/"),
  player("/playing");

  const ApplicationRoute(this.route);
  final String route;
}
