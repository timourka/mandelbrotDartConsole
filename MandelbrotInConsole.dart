const bool upscaled = true; // использовать псевдо графику?
const SymbolsVariant usingSymbolsVariant =
    SymbolsVariant.unicodVariant; // какой вариант символов?
const InterestingPoint usingInterestingPoint =
    InterestingPoint.fullVue; // какой кусочек множества?

enum SymbolsVariant {
  asciiVariant,
  unicodVariant,
}

enum InterestingPoint {
  zip,
  fullVue,
  littleMandelbrot,
}

Future<int> mandelbrotIterations(
    double cx, double cy, int maxIterations) async {
  double zx = 0.0;
  double zy = 0.0;
  int iterations = 0;

  while (zx * zx + zy * zy <= 4.0 && iterations < maxIterations) {
    double temp = zx * zx - zy * zy + cx;
    zy = 2.0 * zx * zy + cy;
    zx = temp;
    iterations++;
  }

  return iterations;
}

extension IntX on int {
  String getSymbol(int maxIterations) {
    List<String> symbols;
    switch (usingSymbolsVariant) {
      case SymbolsVariant.asciiVariant:
        symbols = [' ', '.', '•', ':', '-', '=', '+', '*', '#', '%', '@'];
        break;
      case SymbolsVariant.unicodVariant:
        symbols = ['□', '▣', '▤', '▥', '▦', '▧', '▨', '▩', '■'];
        break;
    }
    int index = (this / maxIterations * (symbols.length - 1)).floor();
    return symbols[index];
  }
}

Future<void> main() async {
  int width = 90;
  switch (usingSymbolsVariant) {
    case SymbolsVariant.asciiVariant:
      width = 110;
      break;
    case SymbolsVariant.unicodVariant:
      width = 70;
      break;
  }

  int height = 40;
  if (upscaled) {
    width = 150;
    height = 80;
  }
  int maxIterations = 70;
  double minX = -2.0;
  double maxX = 1.0;
  double minY = -1.0;
  double maxY = 1.0;

  switch (usingInterestingPoint) {
    case InterestingPoint.fullVue:
      minX = -2.0;
      maxX = 1.0;
      minY = -1.0;
      maxY = 1.0;
      break;
    case InterestingPoint.littleMandelbrot:
      maxIterations = 891;
      minX = -1.7433419053321 - 0.00000000374 / 2;
      maxX = -1.7433419053321 + 0.00000000374 / 2;
      minY = 0.0000907687489 - 0.00000000374 * 40 / 100 / 2;
      maxY = 0.0000907687489 + 0.00000000374 * 40 / 100 / 2;
      break;
    case InterestingPoint.zip:
      maxIterations = 170;
      minX = -0.8141011;
      maxX = -0.7182021;
      minY = 0.1628571;
      maxY = 0.1258571;
      break;
  }

  List<Future<String>> rows = [];
  for (int y = 0; y < height; y++) {
    List<Future<String>> row = [];
    for (int x = 0; x < width; x++) {
      double cx = minX + (maxX - minX) * x / width;
      double cy = minY + (maxY - minY) * y / height;

      row.add(mandelbrotIterations(cx, cy, maxIterations).then((iterations) {
        return iterations.getSymbol(maxIterations);
      }));
    }
    rows.add(Future.wait(row).then((symbols) => symbols.join()));
  }

  if (upscaled) {
    List<String> result = await Future.wait(rows);
    for (int y = 0; y < height; y += 2) {
      String row = '';
      for (int x = 0; x < width; x += 2) {
        const pixels = [
          '▖', // 0
          '▗', // 1
          '▝', // 2
          '▘', // 3
          '▃', // 4
          '▐', // 5
          '▀', // 6
          '▌', // 7
          '▚', // 8
          '▞', // 9
          '▙', // 10
          '▟', // 11
          '▜', // 12
          '▛', // 13
          '□', // 14
          '█' // 15
        ];
        List<bool> canPixel = List<bool>.filled(pixels.length, true);
        //LT
        if (result[y][x] == '@' || result[y][x] == '■') {
          canPixel[0] = false;
          canPixel[1] = false;
          canPixel[2] = false;
          canPixel[4] = false;
          canPixel[5] = false;
          canPixel[9] = false;
          canPixel[11] = false;
          canPixel[14] = false;
        } else {
          canPixel[3] = false;
          canPixel[6] = false;
          canPixel[7] = false;
          canPixel[8] = false;
          canPixel[10] = false;
          canPixel[12] = false;
          canPixel[13] = false;
          canPixel[15] = false;
        }
        //LB
        if (result[y + 1][x] == '@' || result[y + 1][x] == '■') {
          canPixel[1] = false;
          canPixel[2] = false;
          canPixel[3] = false;
          canPixel[5] = false;
          canPixel[6] = false;
          canPixel[8] = false;
          canPixel[12] = false;
          canPixel[14] = false;
        } else {
          canPixel[0] = false;
          canPixel[4] = false;
          canPixel[7] = false;
          canPixel[9] = false;
          canPixel[10] = false;
          canPixel[11] = false;
          canPixel[13] = false;
          canPixel[15] = false;
        }
        //RB
        if (result[y + 1][x + 1] == '@' || result[y + 1][x + 1] == '■') {
          canPixel[0] = false;
          canPixel[2] = false;
          canPixel[3] = false;
          canPixel[6] = false;
          canPixel[7] = false;
          canPixel[9] = false;
          canPixel[13] = false;
          canPixel[14] = false;
        } else {
          canPixel[1] = false;
          canPixel[4] = false;
          canPixel[5] = false;
          canPixel[8] = false;
          canPixel[10] = false;
          canPixel[11] = false;
          canPixel[12] = false;
          canPixel[15] = false;
        }
        //RT
        if (result[y][x + 1] == '@' || result[y][x + 1] == '■') {
          canPixel[0] = false;
          canPixel[1] = false;
          canPixel[3] = false;
          canPixel[4] = false;
          canPixel[7] = false;
          canPixel[8] = false;
          canPixel[10] = false;
          canPixel[14] = false;
        } else {
          canPixel[2] = false;
          canPixel[5] = false;
          canPixel[6] = false;
          canPixel[9] = false;
          canPixel[11] = false;
          canPixel[12] = false;
          canPixel[13] = false;
          canPixel[15] = false;
        }
        for (int i = 0; i < pixels.length; i++) {
          if (canPixel[i]) {
            if (i == 14 &&
                usingSymbolsVariant == SymbolsVariant.unicodVariant) {
              row += result[y][x];
            } else {
              row += pixels[i];
            }
          }
        }
      }
      print(row);
    }
  } else {
    List<String> result = await Future.wait(rows);
    result.forEach(print);
  }
}
