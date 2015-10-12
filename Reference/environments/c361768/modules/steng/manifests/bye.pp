class steng::bye ($message=undef) {
  notify{'notification-abort':
    message=>$message,
  }
  fail("Aborting:${message}")
}
