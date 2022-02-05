enum AuthWith {
  password,
  facebook,
  google,
  apple,
}

enum HomuraError {
  passwordEmpty,
  passwordTooWeak,
  passwordInvalid,

  emailEmpty,
  emailInvalid,
  emailAlreadyInUse,
  emailNotFound,
  emailAlreadyVerified,

  googleLoginFailed,
  facebookLoginFaild,
  connectFailed,
  disconnectFailed,
  needAtLeastOneProvider,

  userNotFound,
  userNotSignedIn,

  notInitialized,
  unknown,

  notReadyYet,
}
