#!/bin/bash

GRAPHQL_FILE_LIST="$PROJECT_DIR/KsApi/GraphQLFiles.xcfilelist"

#Find all GraphQL files in KsApi.
#Replace the literal $PROJECT_DIR with the token $(PROJECT_DIR)
find $PROJECT_DIR -name "*.graphql" | sed "s#^$PROJECT_DIR#\$(PROJECT_DIR)#" > "$GRAPHQL_FILE_LIST.tmp"

GRAPHQL_FILE_COUNT=$(wc -l $GRAPHQL_FILE_LIST.tmp | awk '{print $1}')
echo "Found $GRAPHQL_FILE_COUNT GraphQL file dependencies."

#Did any of the dependencies change?
#Xcode tries to be smart and checks the file timestamp for changes, so we trick it
#by only copying the file to its final location if it's actually different.
echo "Diffing file list with previous version:"
diff "$GRAPHQL_FILE_LIST" "$GRAPHQL_FILE_LIST.tmp"

if [[ $? != 0 ]]
then
    #If they did change, update our dependency file list. Means you added or removed a graphql file.
    echo "GraphQL file dependencies changed. Updating $GRAPHQL_FILE_LIST with new dependencies."
    cp "$GRAPHQL_FILE_LIST.tmp" "$GRAPHQL_FILE_LIST"
else
    #If not, do nothing.
    echo "GraphQL file dependencies are unchanged since last build."
fi

rm "$GRAPHQL_FILE_LIST.tmp"
    
#For debugging
#cat $GRAPHQL_FILE_LIST

