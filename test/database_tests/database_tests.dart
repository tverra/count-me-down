import 'repo_tests/drink_repo_tests.dart' as drinkRepoTests;
import 'migration_tests/v1_tests.dart' as appMigrationsTests;
import 'repo_tests/profile_repo_tests.dart' as profileRepoTests;
import 'repo_tests/session_repo_tests.dart' as sessionRepoTests;
import 'migration_tests.dart' as migrationsTests;
import 'repo_tests/preferences_repo_tests.dart' as preferencesTests;

main() {
  appMigrationsTests.main();
  migrationsTests.main();
  profileRepoTests.main();
  sessionRepoTests.main();
  drinkRepoTests.main();
  preferencesTests.main();
}
