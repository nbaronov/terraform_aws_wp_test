#!/bin/bash

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: $0 \"database name\""
        exit 1;
fi

DB_NAME=${1}

QUERY_DB_EXISTS="SELECT COUNT(SCHEMA_NAME)  FROM INFORMATION_SCHEMA.SCHEMATA  WHERE SCHEMA_NAME = '${DB_NAME}';"
ROW_COUNT=`mysql -AN -e"${QUERY_DB_EXISTS}"`
if [ ${ROW_COUNT} -eq 0 ]
then
    echo "Database '${DB_NAME}' does not exist"
    exit 2;
fi

function print_table_sizes() {
        QUERY_TABLE_SIZES="SELECT table_name as table_name, round(((data_length + index_length) / 1024 ), 2) as size_kb FROM information_schema.TABLES  WHERE table_schema = '${DB_NAME}' order by 1;"
        RESULT=`mysql -A -t -e"${QUERY_TABLE_SIZES}"`

        if [ $? -ne 0 ]
        then
            echo "Error getting table sizes for database '${DB_NAME}'"
            exit 3;
        fi
        echo "${RESULT}"

}

echo

echo 'Table sizes before OPTIMIZE:'
print_table_sizes

function optimize() {
        echo
        echo 'Optimizing tables ...'
        echo
        RESULT=`mysqlcheck --optimize ${DB_NAME}`

        if [ $? -ne 0 ]
        then
            echo "Error optimizing '${DB_NAME}': ${RESULT}"
            exit 4;
        fi
        echo 'Done optimizing tables'
}

optimize

echo
echo 'Table sizes after OPTIMIZE:'
print_table_sizes
