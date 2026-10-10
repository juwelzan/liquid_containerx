/// Configuration for the physics engine of a LiquidContainer.
class LiquidPhysics {
  final bool enabled;
  final double elasticity;
  final double viscosity;
  final double maxDeformation;
  final double damping;

  const LiquidPhysics({
    this.enabled = true,
    this.elasticity = 0.7,
    this.viscosity = 0.5,
    this.maxDeformation = 0.5,
    this.damping = 0.8,
  })  : assert(elasticity >= 0.0 && elasticity <= 1.0),
        assert(viscosity >= 0.0 && viscosity <= 1.0),
        assert(maxDeformation >= 0.0),
        assert(damping >= 0.0 && damping <= 1.0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidPhysics &&
        other.enabled == enabled &&
        other.elasticity == elasticity &&
        other.viscosity == viscosity &&
        other.maxDeformation == maxDeformation &&
        other.damping == damping;
  }

  @override
  int get hashCode => Object.hash(enabled, elasticity, viscosity, maxDeformation, damping);
}
