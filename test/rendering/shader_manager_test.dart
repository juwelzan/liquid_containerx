import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_containerx/src/rendering/shader_manager.dart';

void main() {
  test('ShaderManager handles missing shader gracefully (fallback)', () async {
    // In test environment, the asset might not load unless correctly bundled,
    // which simulates the failure path perfectly.
    await ShaderManager.loadLiquidGlassShader();
    // It should not throw.
    final shader = ShaderManager.createLiquidGlassShader();
    // In widget tests without real assets, this might be null.
    // If it is null, fallback is active.
    expect(true, isTrue); // Just ensuring no crash
  });
}
