import 'package:flutter_test/flutter_test.dart';
import 'package:crediapp/calculadora.dart';

void main() {
  group('Calculadora CrediMax', () {
    test('interés flat 20% sobre capital 1000 en 8 semanas', () {
      final p = calcularPreview(
        capital: 1000,
        interesPct: 20,
        nCuotas: 8,
        fechaInicio: DateTime(2026, 10, 29),
      );
      expect(p.interes, 200);
      expect(p.totalPagar, 1200);
      expect(p.cuota, 150);
      expect(p.letras.length, 8);
      expect(p.letras.first.fecha, DateTime(2026, 11, 5));
      expect(p.letras.last.fecha, DateTime(2026, 12, 24));
      final suma = p.letras.fold<double>(0, (s, l) => s + l.monto);
      expect(suma, closeTo(1200, 0.01));
    });

    test('plazos permitidos por defecto CrediMax', () {
      final cfg = ConfigTasas();
      expect(cfg.interesPctDefault, 20);
      expect(cfg.semanasDefault, 8);
      expect(cfg.plazosPermitidos, [4, 6, 8, 10, 12, 16]);
      expect(cfg.recargoPorSemana, 10);
    });

    test('mora S/10 por semana de atraso', () {
      final due = DateTime(2026, 10, 1);
      expect(calcularMora(vencimiento: due, pago: DateTime(2026, 10, 1)), 0);
      expect(calcularMora(vencimiento: due, pago: DateTime(2026, 10, 3)), 10);
      expect(calcularMora(vencimiento: due, pago: DateTime(2026, 10, 15)), 20);
    });

    test('frecuencia quincenal espacia 15 días', () {
      final p = calcularPreview(
        capital: 500,
        interesPct: 20,
        nCuotas: 2,
        fechaInicio: DateTime(2026, 1, 1),
        frecuencia: 'Quincenal',
      );
      expect(p.letras[0].fecha, DateTime(2026, 1, 16));
      expect(p.letras[1].fecha, DateTime(2026, 1, 31));
    });
  });
}
