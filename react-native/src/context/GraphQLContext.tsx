import { ApolloClient, ApolloProvider, HttpLink, InMemoryCache, NormalizedCacheObject } from '@apollo/client';
import React, { createContext, useContext, useMemo } from 'react';
import { AppProps } from '../types/AppProps';

interface GraphQLContextType {
  client: ApolloClient<NormalizedCacheObject>;
}

const GraphQLContext = createContext<GraphQLContextType | null>(null);

interface GraphQLProviderProps {
  children: React.ReactNode;
  props: AppProps;
}

export const GraphQLProvider: React.FC<GraphQLProviderProps> = ({ children, props }) => {
  const client = useMemo(() => {
    const httpLink = new HttpLink({
      uri: props.graphQLEndpoint,
      headers: {
        Authorization: props.oauthToken ? `token ${props.oauthToken}` : '',
        'Accept-Language': props.language,
        'Kickstarter-App-Id': props.appId,
        'Kickstarter-Device-Id': props.deviceIdentifier,
        'Kickstarter-Version': props.buildVersion,
        'Kickstarter-Currency': props.currency,
      },
    });

    return new ApolloClient({
      link: httpLink,
      cache: new InMemoryCache(),
      defaultOptions: {
        watchQuery: {
          fetchPolicy: 'cache-and-network',
        },
        query: {
          fetchPolicy: 'network-only',
        },
      },
    });
  }, [props]);

  const value = useMemo(() => ({ client }), [client]);

  return (
    <GraphQLContext.Provider value={value}>
      <ApolloProvider client={client}>{children}</ApolloProvider>
    </GraphQLContext.Provider>
  );
};

export const useGraphQL = () => {
  const context = useContext(GraphQLContext);
  if (!context) {
    throw new Error('useGraphQL must be used within a GraphQLProvider');
  }
  return context;
}; 