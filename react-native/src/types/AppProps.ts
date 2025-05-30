export interface AppProps {
  oauthToken: string;
  graphQLEndpoint: string;
  language: string;
  currency: string;
  buildVersion: string;
  deviceIdentifier: string;
  appId: string;
  isLoggedIn: boolean;
  currentUserId: string;
  currentUserEmail: string;
} 