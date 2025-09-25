import 'app.dart';
import 'core/flavor/flavor.dart';

void main() {
  bootstrap(
      FlavorConfig(
          baseUrl: 'www.google.com.br',
          flavor: AppFlavor.dev,
          restKey: 'AIzaSyAgclIqS3U9-2wfw3B7p6CqOZjPu8IHkPs',
          appId: '1:1055424410138:android:3c5ec16fef7b1b4ebc57a3',
      )
  );
}