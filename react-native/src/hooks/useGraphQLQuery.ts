import { DocumentNode, OperationVariables, QueryHookOptions, useQuery } from '@apollo/client';
import { useGraphQL } from '../context/GraphQLContext';

export function useGraphQLQuery<TData = any, TVariables extends OperationVariables = OperationVariables>(
  query: DocumentNode,
  options?: QueryHookOptions<TData, TVariables>
) {
  const { client } = useGraphQL();
  
  return useQuery<TData, TVariables>(query, {
    ...options,
    client,
  });
} 