/// Stores claimed days separately for each calendar year.
abstract interface class AdventProgressRepository {
  Set<int> loadClaimedDays(int year);

  Future<void> saveClaimedDays(int year, Set<int> days);
}
