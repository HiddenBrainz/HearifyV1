/// Session sizing shared by every classic-exercise runner. Kept in one
/// place so the "how many items per session" choice can be tuned once.
class SessionConfig {
  SessionConfig._();
  static const int itemsPerSession = 10;
}
