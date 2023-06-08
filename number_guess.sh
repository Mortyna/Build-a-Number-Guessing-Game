#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

USER_ENTRY() {
echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM usernames WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  #if user does not exist in database
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  NEW_USER=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME')")
else
  #if user already is in database
  GAMES_PLAYED=$($PSQL "SELECT count(game_id) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

ACTUAL_NUM=$((1 + $RANDOM % 1000))

echo "Guess the secret number between 1 and 1000:"
read NUM_GUESSED
TIMES_GUESSED=1
CHECK_NUMBER
echo "You guessed it in $TIMES_GUESSED tries. The secret number was $ACTUAL_NUM. Nice job!"
SAVING_GAME_RESULTS
}

CHECK_NUMBER() {
while [[ $NUM_GUESSED =~ ^[+-]?[0-9]+$ && ! $NUM_GUESSED -eq $ACTUAL_NUM ]]
do
  if [[ $NUM_GUESSED -gt $ACTUAL_NUM ]]
  then
    echo "It's lower than that, guess again:"
    read NUM_GUESSED
  elif [[  $NUM_GUESSED -lt $ACTUAL_NUM ]]
  then
    echo "It's higher than that, guess again:"
    read NUM_GUESSED
  fi
((TIMES_GUESSED++))
done 
if [[ ! $NUM_GUESSED =~ ^[+-]?^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
  read NUM_GUESSED
  CHECK_NUMBER
fi
}

SAVING_GAME_RESULTS() {
USER_ID=$($PSQL "SELECT user_id FROM usernames WHERE username='$USERNAME'")
INSERT_DATA=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TIMES_GUESSED)")
}

USER_ENTRY
