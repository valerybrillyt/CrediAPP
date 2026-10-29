/// Lógica de tasas / cronograma estilo CrediMax.
///
/// CrediMax usa:
/// - interesPct flat sobre el capital (total = capital × (1 + tasa/100))
/// - plazos en semanas: 4, 6, 8, 10, 12, 16
/// - preview de letras antes de emitir
/// - mora: S/ 10 por cada semana de atraso
library;

class ConfigTasas {
  ConfigTasas({
    this.interesPctDefault = 20,
    this.semanasDefault = 8,
    this.plazosPermitidos = const [4, 6, 8, 10, 12, 16],
    this.recargoPorSemana = 10,
  });

  double interesPctDefault;
  int semanasDefault;
  List<int> plazosPermitidos;
  double recargoPorSemana;
}

class LetraPreview {
  const LetraPreview({
    required this.numero,
    required this.fecha,
    required this.monto,
  });

  final int numero;
  final DateTime fecha;
  final double monto;
}

class PreviewCuotas {
  const PreviewCuotas({
    required this.capital,
    required this.interesPct,
    required this.interes,
    required this.totalPagar,
    required this.cuota,
    required this.letras,
  });

  final double capital;
  final double interesPct;
  final double interes;
  final double totalPagar;
  final double cuota;
  final List<LetraPreview> letras;
}

int diasPorFrecuencia(String frecuencia) {
  switch (frecuencia) {
    case 'Diario':
      return 1;
    case 'Quincenal':
      return 15;
    case 'Mensual':
      return 30;
    case 'Semanal':
    default:
      return 7;
  }
}

/// Tasa sugerida por frecuencia (referencia CrediMax / prestamistas locales).
double tasaSugerida(String frecuencia, {double baseSemanal = 20}) {
  switch (frecuencia) {
    case 'Diario':
      return (baseSemanal / 7).clamp(1, 100);
    case 'Quincenal':
      return (baseSemanal * 2).clamp(1, 100);
    case 'Mensual':
      return (baseSemanal * 4).clamp(1, 100);
    case 'Semanal':
    default:
      return baseSemanal;
  }
}

double redondear2(double v) => (v * 100).roundToDouble() / 100;

PreviewCuotas calcularPreview({
  required double capital,
  required double interesPct,
  required int nCuotas,
  required DateTime fechaInicio,
  String frecuencia = 'Semanal',
}) {
  final interes = redondear2(capital * (interesPct / 100));
  final total = redondear2(capital + interes);
  final cuotaBase = nCuotas <= 0 ? 0.0 : redondear2(total / nCuotas);
  final step = diasPorFrecuencia(frecuencia);
  final letras = <LetraPreview>[];
  var acumulado = 0.0;
  for (var i = 1; i <= nCuotas; i++) {
    final monto = i == nCuotas ? redondear2(total - acumulado) : cuotaBase;
    acumulado = redondear2(acumulado + monto);
    letras.add(LetraPreview(
      numero: i,
      fecha: fechaInicio.add(Duration(days: step * i)),
      monto: monto,
    ));
  }
  return PreviewCuotas(
    capital: capital,
    interesPct: interesPct,
    interes: interes,
    totalPagar: total,
    cuota: cuotaBase,
    letras: letras,
  );
}

int semanasAtraso(DateTime vencimiento, DateTime pago) {
  if (!pago.isAfter(vencimiento)) return 0;
  final dias = pago.difference(vencimiento).inDays;
  final w = dias ~/ 7;
  return w == 0 ? 1 : w;
}

double calcularMora({
  required DateTime vencimiento,
  required DateTime pago,
  double recargoPorSemana = 10,
}) {
  final w = semanasAtraso(vencimiento, pago);
  if (w <= 0) return 0;
  return redondear2(w * recargoPorSemana);
}

String fechaCorta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String fechaLarga(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
