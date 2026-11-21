class PrevisaoDia {
  final String data;
  final String tempo;
  final int maxima;
  final int minima;
  final double iuv;

  PrevisaoDia({
    required this.data,
    required this.tempo,
    required this.maxima,
    required this.minima,
    required this.iuv,
  });

  factory PrevisaoDia.fromXml(dynamic element) {
    String ler(String tag) {
      return element.getElement(tag)?.text.trim() ?? '';
    }

    return PrevisaoDia(
      data: ler('dia'),
      tempo: ler('tempo'),
      maxima: int.tryParse(ler('maxima')) ?? 0,
      minima: int.tryParse(ler('minima')) ?? 0,
      iuv: double.tryParse(ler('iuv')) ?? 0.0,
    );
  }
}