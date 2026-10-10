import re
with open('lib/src/widgets/liquid_container.dart', 'r') as f:
    contents = f.read()

contents = re.sub(r'class _CombinedSimulation extends Simulation \{.*?\}', '''class _CombinedSimulation extends Simulation {
  final SpringSimulation simX;
  final SpringSimulation simY;
  
  _CombinedSimulation(this.simX, this.simY);

  @override
  double x(double time) => time; // time drives the animation

  @override
  double dx(double time) => 1;

  @override
  bool isDone(double time) => simX.isDone(time) && simY.isDone(time);
}''', contents, flags=re.DOTALL)

with open('lib/src/widgets/liquid_container.dart', 'w') as f:
    f.write(contents)
