#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo -e "\nWelcome to My Salon, how can I help you?"
  # echo -e "1) cut\n2) color\n3) trim"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
  echo "$SERVICE_ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED

  # check the available services
  SERVICE_AVAILBILITY=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # if not found
  if [[ -z $SERVICE_AVAILBILITY ]]
  then
  MAIN_MENU "I could not find that service. What would you like today?"

  # if found 
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_INFO=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_INFO ]]
    then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

    #get new customer id
    NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # get selected service name
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo "What time would you like your $(echo $SERVICE_NAME_SELECTED | sed 's/ |/"/'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    # get the appointment time
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($NEW_CUSTOMER_ID, $SERVICE_AVAILBILITY, '$SERVICE_TIME')")

    #get service name
    echo "I have put you down for a $(echo $SERVICE_NAME_SELECTED | sed 's/ |/"/') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    else
    # get selected service name
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo "What time would you like your $(echo $SERVICE_NAME_SELECTED | sed 's/ |/"/'), $(echo $CUSTOMER_INFO | sed -r 's/^ *| *$//g')?"
    # get the appointment time
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_AVAILBILITY, '$SERVICE_TIME')")

    #get service name
    echo "I have put you down for a $(echo $SERVICE_NAME_SELECTED | sed 's/ |/"/') at $SERVICE_TIME, $(echo $CUSTOMER_INFO | sed -r 's/^ *| *$//g')."
    fi
  fi
}


MAIN_MENU