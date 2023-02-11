enum AuthWith {
  password,
  facebook,
  google,
  apple,
  customToken,
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

  customTokenEmpty,

  googleLoginFailed,
  facebookLoginFailed,
  customTokenLoginFailed,
  facebookLoginGetAccessTokenFailed,
  connectFailed,
  disconnectFailed,
  needAtLeastOneProvider,

  userNotFound,
  userNotSignedIn,

  getFileURLFailed,

  notInitialized,
  facebookSigninConfigInitializeFailed,
  unknown,

  homuraAuthNameEmpty,
  homuraAuthNameDisallowed,
  homuraAuthInitializeFailed,

  notReadyYet,
}
