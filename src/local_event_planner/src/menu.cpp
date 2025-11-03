#include "../../local_event_planner/header/menu.h"
#include <user_authentication.h>
#include <cstdio>

#if !defined(_WIN32) && !defined(_WIN64)
  #include <termios.h>
  #include <unistd.h>
#else
  #include <conio.h>
  #include <io.h>
#endif

// ============================================================
// TEST HOOK: özel getch enjektörü (coverage için)
// ============================================================
typedef int (*MenuKeyReader)();
static MenuKeyReader g_menu_key_reader = nullptr;

void menu_set_key_reader(MenuKeyReader reader) {
  g_menu_key_reader = reader;
}

// ============================================================
// TEST HOOK: runMenu override (sadece test derlemesinde aktif)
// Bu sayede firstMenu/eventMenu içinde "geçersiz seçim" gibi
// yolları zorlayıp default kollarını kapsayabiliriz.
// ============================================================
#ifdef ENABLE_MENU_TEST_HOOKS
typedef int (*RunMenuOverride)(const char items[][30], int size);
static RunMenuOverride g_runmenu_override = nullptr;
extern "C" void menu_set_runmenu_override(RunMenuOverride fn) {
  g_runmenu_override = fn;
}

#endif

#ifndef _WIN32
// Unix-like sistemler için güvenli getch
static int getch_unix() {
  termios oldt{}, newt{};
  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= static_cast<unsigned>(~(ICANON | ECHO));
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);
  int ch = getchar();
  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
  return ch;
}

#endif

// stdin TTY mi?
static bool stdin_is_tty() {
#if defined(_WIN32) || defined(_WIN64)
  return _isatty(_fileno(stdin)) != 0;
#else
  return isatty(fileno(stdin)) != 0;
#endif
}

/**
 * @name   getInput
 * @brief  Klavye girdisini menü sabitlerine çevirir.
 * @note   stdin TTY değilse (dosyadan besleniyorsa) 'A','B','\n','\r' map edilir.
 */
int getInput() {
  // --- TEST HOOK: Eğer test okuyucu set edildiyse doğrudan burayı kullan ---
  if (g_menu_key_reader) {
#if defined(_WIN32) || defined(_WIN64)
    int ch = g_menu_key_reader();

    if (ch == 224 || ch == 0) {
      ch = g_menu_key_reader();

      switch (ch) {
        case 72:
          return UP_ARROW;     // Up

        case 80:
          return DOWN_ARROW;   // Down

        default:
          return NONE;
      }
    }

    if (ch == 13) return ENTER;

    return NONE;
#else
    int ch = g_menu_key_reader();

    if (ch == 27) {
      int c2 = g_menu_key_reader();
      int c3 = g_menu_key_reader();

      if (c2 == '[') {
        if (c3 == 'A') return UP_ARROW;

        if (c3 == 'B') return DOWN_ARROW;
      }

      return NONE;
    }

    if (ch == '\n') return ENTER;

    return NONE;
#endif
  }

  // --- SCRIPTED INPUT: stdin TTY değilse dosyadan gelen karakterleri oku ---
  if (!stdin_is_tty()) {
    int ch = fgetc(stdin);

    if (ch == 'A') return UP_ARROW;           // Up

    if (ch == 'B') return DOWN_ARROW;         // Down

    if (ch == '\n' || ch == '\r') return ENTER;

    return NONE;
  }

#if defined(_WIN32) || defined(_WIN64)
  int ch = _getch();

  // Özel tuşlar 224 veya 0 ile gelir
  if (ch == 224 || ch == 0) {
    ch = _getch();

    switch (ch) {
      case 72:
        return UP_ARROW;     // Up

      case 80:
        return DOWN_ARROW;   // Down

      default:
        return NONE;
    }
  }

  if (ch == 13) return ENTER;       // Enter

  return NONE;
#else
  int ch = getch_unix();

  if (ch == 27) {                   // ESC
    int c2 = getch_unix();          // '['
    int c3 = getch_unix();          // 'A'/'B'

    if (c2 == '[') {
      if (c3 == 'A') return UP_ARROW;

      if (c3 == 'B') return DOWN_ARROW;
    }

    return NONE;
  }

  if (ch == '\n') return ENTER;

  return NONE;
#endif
}

/**
 * @name   printMenu
 */
int printMenu(const char menuItems[][30], int menuSize, int selectedIndex) {
  CLEAR_SCREEN();
  std::printf("=== MENU ===\n");

  for (int i = 0; i < menuSize; ++i) {
    std::printf("%s %s\n",
                (i == selectedIndex ? ">" : " "),
                menuItems ? menuItems[i] : "");
  }

  std::printf("\nYön tuşlarıyla gez, ENTER ile seç.\n");
  return 1;
}

/**
 * @name   runMenu
 */
int runMenu(const char menuItems[][30], int menuSize) {
  if (menuSize <= 0) return 0;           // Boş menü güvenliği

  int selectedIndex = 0;                 // İlk öğe seçili başlasın

  while (true) {
    printMenu(menuItems, menuSize, selectedIndex);
    int input = getInput();

    switch (input) {
      case UP_ARROW:
        selectedIndex = (selectedIndex - 1 + menuSize) % menuSize;
        break;

      case DOWN_ARROW:
        selectedIndex = (selectedIndex + 1) % menuSize;
        break;

      case ENTER:
        CLEAR_SCREEN();
        return selectedIndex;

      default:
        break; // yok say
    }
  }
}

/**
 * @name   firstMenu
 */
int firstMenu() {
  const char mainMenuItems[][30] = {
    "Register",
    "Login",
    "Guest Mode",
    "Exit"
  };

  while (true) {
    int selection =
#ifdef ENABLE_MENU_TEST_HOOKS
      (g_runmenu_override ? g_runmenu_override(mainMenuItems,
        (int)(sizeof(mainMenuItems) / sizeof(mainMenuItems[0]))) :
#endif
       runMenu(mainMenuItems, (int)(sizeof(mainMenuItems) / sizeof(mainMenuItems[0])))
#ifdef ENABLE_MENU_TEST_HOOKS
      )
#endif
      ;

    switch (selection) {
      case 0:
        initiateUserRegistration();
        break;

      case 1:
        initiateUserLogin();
        break;

      case 2:
        // guestMenu();
        break;
        
      case 3:
        std::printf("Exiting...\n");
        return 0;
    }
  }
}

/**
 * @name   eventMenu
 */
int eventMenu(const int userID, const char* userName) {
  const char eventMenuItems[][30] = {
    "Create Event",
    "Manage Events",
    "Return"
  };

  while (true) {
    int selection =
#ifdef ENABLE_MENU_TEST_HOOKS
      (g_runmenu_override ? g_runmenu_override(eventMenuItems,
        (int)(sizeof(eventMenuItems) / sizeof(eventMenuItems[0]))) :
#endif
       runMenu(eventMenuItems, (int)(sizeof(eventMenuItems) / sizeof(eventMenuItems[0])))
#ifdef ENABLE_MENU_TEST_HOOKS
      )
#endif
      ;

    switch (selection) {
      case 0:
        create_event();
        break;

      case 1:
        // manage events
        break;

      case 2:
        return 0; // geri
    }
  }
}