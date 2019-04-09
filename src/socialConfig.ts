import {
    AuthServiceConfig,
    GoogleLoginProvider
  } from 'angularx-social-login';

export function getAuthServiceConfigs() {
    let config = new AuthServiceConfig([
      {
        id: GoogleLoginProvider.PROVIDER_ID,
        provider: new GoogleLoginProvider("1066835797914-s57ni9h6r96r1rsfnrsvs7ej7ogg45ah.apps.googleusercontent.com")
      }
    ]);
  
    return config;
}