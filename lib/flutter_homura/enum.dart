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
  facebookLoginFailed,
  facebookLoginGetAccessTokenFailed,
  connectFailed,
  disconnectFailed,
  needAtLeastOneProvider,

  userNotFound,
  userNotSignedIn,

  getFileURLFailed,

  notInitialized,
  unknown,

  notReadyYet,
}
