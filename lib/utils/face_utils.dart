import 'dart:math';

List<double> l2Normalize(List<double> v) {
  final double sum = v.fold(0.0, (a, b) => a + b * b);
  final double norm = sqrt(sum);
  if (norm == 0) return v;
  return v.map((e) => e / norm).toList();
}

double cosineSimilarity(List<double> a, List<double> b) {
  final int n = min(a.length, b.length);
  double dot = 0.0, na = 0.0, nb = 0.0;
  for (int i = 0; i < n; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  if (na == 0 || nb == 0) return 0.0;
  return dot / (sqrt(na) * sqrt(nb));
}

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371000;
  double dLat = _deg2rad(lat2 - lat1);
  double dLon = _deg2rad(lon2 - lon1);
  double a = sin(dLat/2)*sin(dLat/2) + cos(_deg2rad(lat1))*cos(_deg2rad(lat2))*sin(dLon/2)*sin(dLon/2);
  double c = 2 * atan2(sqrt(a), sqrt(1-a));
  return R * c;
}
double _deg2rad(double deg) => deg * (pi / 180);
