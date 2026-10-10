import 'dart:io';
void main() {
  final file = File('lib/src/widgets/liquid_container.dart');
  String contents = file.readAsStringSync();
  contents = contents.replaceAll(RegExp(r'class _CombinedSimulation extends Simulation \{.*?\}', dotAll: true), '''class _CombinedSimulation extends Simulation {
  final SpringSimulation simX;
  final SpringSimulation simY;
  
  _CombinedSimulation(this.simX, this.simY);

  @override
  double x(double time) => time; // time drives the animation

  @override
  double dx(double time) => 1;

  @override
  bool isDone(double time) => simX.isDone(time) && simY.isDone(time);
}''');
  file.writeAsStringSync(contents);
}
