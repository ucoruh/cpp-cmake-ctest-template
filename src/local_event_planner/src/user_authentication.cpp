#include "../../local_event_planner/header/user_authentication.h"

bool isTestEnvironment = false;

int performUserLogin(HashTable* ht) {
  char username[50], password[50];
  User* user = NULL;
  printf("Enter your username: ");
  scanf("%49s", username);

  if (!findUserBrent(ht, username, &user) || user == NULL) {
    printf("User not found! Returning to the main menu...\n");
    WAIT(3);
    return 1;
  }

  while (1) {
    printf("Enter your password (or type '0' to return to the main menu): ");
    scanf("%49s", password);

    if (strcmp(password, "0") == 0) {
      printf("Returning to the main menu...\n");
      WAIT(3);
      return 1;
    }

    if (strcmp(user->password, password) == 0) {
      printf("Login successful! Welcome, %s.\n", user->username);
      WAIT(3);

      if (!isTestEnvironment) {
        eventMenu(user->id, user->username);
      } else {
        printf("Bypassed mainMenu in test environment.\n");
      }

      return 0;
    } else {
      printf("Incorrect password. Please try again.\n");
      WAIT(3);
      return 1;
    }
  }
}

int performUserRegistration(HashTable* ht) {
  char username[50], password[50];

  while (1) {
    printf("Enter a username: ");
    scanf("%49s", username);

    if (findUserBrent(ht, username, NULL)) {
      printf("Username already exists! Please choose a different username.\n");
    } else {
      break;
    }
  }

  while (1) {
    printf("Enter a password (at least 4 characters): ");
    scanf("%49s", password);

    if (strlen(password) < 4) {
      printf("Password must be at least 4 characters long. Please try again.\n");
    } else {
      break;
    }
  }

  if (insertUserBrent(ht, currentID++, username, password)) {
    printf("User registered successfully with ID: %d\n", currentID - 1);
    WAIT(3);
    return 0;
  } else {
    printf("User registration failed.\n");
    return 1;
  }
}

int initiateUserRegistration() {
  HashTable ht;
  initBrentHashTable(&ht);
  loadUsersFromBinaryFile(&ht, "users.dat");
  int result = performUserRegistration(&ht);
  saveUsersToBinaryFile(&ht, "users.dat");
  return result;
}

int initiateUserLogin() {
  HashTable ht;
  initBrentHashTable(&ht);
  loadUsersFromBinaryFile(&ht, "users.dat");
  return performUserLogin(&ht);
}