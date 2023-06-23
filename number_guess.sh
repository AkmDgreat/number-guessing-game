#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

echo "Enter your username:"
read INP_USER_NAME

USER_NAME=$($PSQL "SELECT username FROM users WHERE username='$INP_USER_NAME'")

if [[ -z $USER_NAME ]]
then
    INSERT_USER_NAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$INP_USER_NAME')")
    echo -e "\nWelcome, $INP_USER_NAME! It looks like this is your first time here."
else
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME'")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(num_tries) FROM games WHERE user_id=$USER_ID")
    echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$INP_USER_NAME'")

SECRET_NUM=$(( $(( RANDOM % 1001 )) + 1 ))
TRIES=0

MAIN () {
    TRIES=$((TRIES+1))
    echo -e "\n$1"

    read GUESSED_NUM

    if [[ $GUESSED_NUM == $SECRET_NUM ]]
    then 
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, num_tries) VALUES($USER_ID, $TRIES)")
        echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET_NUM. Nice job!"
    fi

    if [[ ! $GUESSED_NUM =~ ^[0-9]*$ ]]
    then
        MAIN "That is not an integer, guess again:"
    fi

    if [[ $GUESSED_NUM < $SECRET_NUM ]]
    then
        MAIN "It's higher than that, guess again:"
    fi

    if [[ $GUESSED_NUM > $SECRET_NUM ]]
    then
        MAIN "It's lower than that, guess again:"
    fi
}

MAIN "Guess the secret number between 1 and 1000:"