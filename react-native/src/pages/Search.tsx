import React, { useState, useRef, useCallback } from 'react';
import { ActivityIndicator, FlatList, SafeAreaView, StatusBar, Text, TextInput, useColorScheme, View, ViewToken } from 'react-native';
import { GraphQLProvider } from '../context/GraphQLContext';
import { AppProps } from '../types/AppProps';
import { useGraphQLQuery } from '../hooks/useGraphQLQuery';
import { SearchDocument, SearchQuery, SearchQueryVariables, ProjectSort, PublicProjectState } from '../generated/graphql';
import { SearchCell } from '../components/SearchCell';

function SearchResults({ searchTerm }: { searchTerm: string }) {
  const { data, loading, error } = useGraphQLQuery<SearchQuery, SearchQueryVariables>(
    SearchDocument,
    {
      variables: {
        term: searchTerm || undefined,
        first: 40,
        sort: ProjectSort.Popularity,
        state: PublicProjectState.Live
      }
    }
  );

  const [visibleIds, setVisibleIds] = useState<Set<string>>(new Set());
  const viewabilityConfig = useRef({ itemVisiblePercentThreshold: 60 });
  const onViewableItemsChanged = useCallback(({
    viewableItems,
  }: {
    viewableItems: Array<ViewToken>;
  }) => {
    setVisibleIds(new Set(viewableItems.map((vi) => (vi.item as any)?.id)));
  }, []);

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.centerContainer}>
        <Text>Error: {error.message}</Text>
      </View>
    );
  }

  const projects = data?.projects?.nodes?.filter((item): item is NonNullable<typeof item> => item != null) ?? [];

  if (projects.length === 0) {
    return (
      <View style={styles.centerContainer}>
        <Text style={styles.emptyText}>No projects found</Text>
      </View>
    );
  }

  return (
    <FlatList
      data={projects}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <SearchCell project={item} isVisible={visibleIds.has(item.id)} />
      )}
      onViewableItemsChanged={onViewableItemsChanged}
      viewabilityConfig={viewabilityConfig.current}
    />
  );
}

function SearchScreen(props: AppProps): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [searchTerm, setSearchTerm] = useState('');

  return (
    <GraphQLProvider props={props}>
      <SafeAreaView style={[styles.container, { backgroundColor: isDarkMode ? '#000' : '#fff' }]}>
        <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
        <View style={styles.searchContainer}>
          <TextInput
            style={[
              styles.searchInput,
              {
                backgroundColor: isDarkMode ? '#333' : '#fff',
                color: isDarkMode ? '#fff' : '#000',
              }
            ]}
            placeholder="Search projects..."
            placeholderTextColor={isDarkMode ? '#999' : '#666'}
            value={searchTerm}
            onChangeText={setSearchTerm}
            autoCapitalize="none"
            autoCorrect={false}
          />
        </View>
        <SearchResults searchTerm={searchTerm} />
      </SafeAreaView>
    </GraphQLProvider>
  );
}

const styles = {
  container: {
    flex: 1,
  },
  searchContainer: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  searchInput: {
    height: 40,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 12,
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
  },
} as const;

export default SearchScreen;