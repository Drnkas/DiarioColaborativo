import 'app.dart';
import 'core/flavor/flavor.dart';

void main() {
  bootstrap(
      FlavorConfig(
          baseUrl: 'www.google.com.br',
          flavor: AppFlavor.dev
      )
  );
}