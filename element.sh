#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

generate_message() {
    echo -e "The element with atomic number $1 is $3 ($2). It's a $4, with a mass of $5 amu. $3 has a melting point of $6 celsius and a boiling point of $7 celsius."
}

if [[ -z $1 ]]; then
    echo "Please provide an element as an argument."
else
    if [[ $1 =~ ^[0-9]+$ ]]; then
        QUERY_RESULT=$($PSQL "SELECT elements.atomic_number, elements.symbol, elements.name, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, properties.type_id FROM elements LEFT JOIN properties ON elements.atomic_number=properties.atomic_number LEFT JOIN types ON properties.type_id=types.type_id WHERE elements.atomic_number=$1;")

    elif [[ -n $1 && (${#1} -eq 1 || ${#1} -eq 2) && ! $1 =~ [0-9] ]]; then
        QUERY_RESULT=$($PSQL "SELECT elements.atomic_number, elements.symbol, elements.name, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, properties.type_id FROM elements LEFT JOIN properties ON elements.atomic_number=properties.atomic_number LEFT JOIN types ON properties.type_id=types.type_id  WHERE elements.symbol='$1';")

    elif [[ -n $1 && ${#1} -gt 2 && ! $1 =~ [0-9] ]]; then
        QUERY_RESULT=$($PSQL "SELECT elements.atomic_number, elements.symbol, elements.name, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, properties.type_id FROM elements LEFT JOIN properties ON elements.atomic_number=properties.atomic_number LEFT JOIN types ON properties.type_id=types.type_id  WHERE elements.name='$1';")
    fi

    if [[ -z $QUERY_RESULT ]]; then
        echo "I could not find that element in the database."
    else
        IFS='|' read -r -a values <<<"$QUERY_RESULT"
        generate_message "${values[@]}"
    fi
fi
