import 'drink_repo_tests.dart' as drinkRepoTests;
import 'migration_tests.dart' as migrationTests;
import 'profile_repo_tests.dart' as profileRepoTests;
import 'session_repo_tests.dart' as sessionRepoTests;

main() {
  migrationTests.main();
  profileRepoTests.main();
  sessionRepoTests.main();
  drinkRepoTests.main();
}
