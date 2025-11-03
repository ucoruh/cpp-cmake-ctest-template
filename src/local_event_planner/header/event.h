#pragma once

// Projede her yerde kullanılacak TEK Event tanımı
struct Event {
  int  id;
  char title[100];
  char description[500];
  char date[20]; // "YYYY-MM-DD"
};
