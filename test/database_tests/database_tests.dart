import 'migration_tests.dart' as migrations_tests;
import 'migration_tests/v1_tests.dart' as app_migrations_tests;
import 'repo_tests/drink_repo_tests.dart' as drink_repo_tests;
import 'repo_tests/preferences_repo_tests.dart' as preferences_tests;
import 'repo_tests/profile_repo_tests.dart' as profile_repo_tests;
import 'repo_tests/session_repo_tests.dart' as session_repo_tests;

void main() {
  app_migrations_tests.main();
  migrations_tests.main();
  profile_repo_tests.main();
  session_repo_tests.main();
  drink_repo_tests.main();
  preferences_tests.main();
}
