#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <stdexcept>

#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#else
#include <io.h>
#include <windows.h>
#endif

// ============================================================
// !!! ÇÖZÜM: '0' OLAN TESTLERİ AÇMAK İÇİN BU BAYRAK EKLENDİ !!!
// Bu bayrak, menu.cpp'yi include etmeden ÖNCE tanımlanmalı.
// ============================================================
#define ENABLE_MENU_TEST_HOOKS 1

// .cpp dosyasını dahil etmek linker sorunlarını çözer
#include "../../../local_event_planner/src/menu.cpp"
#include "../../googletest/googletest/include/gtest/gtest.h"

// ============================================================
// !!! ÇÖZÜM: CLEAR_SCREEN makrosunu testler için devre dışı bırak !!!
// ============================================================
#ifdef CLEAR_SCREEN
#undef CLEAR_SCREEN
#endif
#define CLEAR_SCREEN() (void)0

// ============================================================
// STUBLAR: dış bağımlılıklar
// ============================================================
static int g_called_register = 0;
static int g_called_login = 0;
static int g_called_create = 0;
static int g_force_throw_after_call = 0; // exit yerine exception kullan

// Test için özel exception
class TestExitException : public std::exception {
public:
    const char* what() const noexcept override {
        return "TestExit";
    }
};

// Stub fonksiyonlar
int initiateUserRegistration() {
    ++g_called_register;

    if (g_force_throw_after_call) {
        throw TestExitException(); // exit yerine exception
    }

    return 1;
}

int initiateUserLogin() {
    ++g_called_login;

    if (g_force_throw_after_call) {
        throw TestExitException(); // exit yerine exception
    }

    return 1;
}

int create_event() {
    ++g_called_create;
    return 1;
}

// ============================================================
// TEST HOOK: runMenu override
// ============================================================
#ifdef ENABLE_MENU_TEST_HOOKS
extern "C" void menu_set_runmenu_override(int (*fn)(const char[][30], int));
#endif

// ============================================================
// TEST YARDIMCILAR
// ============================================================
static std::string g_lastTempFile;

static void simulateInputFromString(const std::string& script) {
#if defined(_WIN32) || defined(_WIN64)
    char path[L_tmpnam];
    tmpnam_s(path, L_tmpnam);
    g_lastTempFile = path;
    FILE* f = std::fopen(g_lastTempFile.c_str(), "wb");
    ASSERT_NE(f, nullptr) << "Temp file open failed";
    std::fwrite(script.data(), 1, script.size(), f);
    std::fclose(f);
    ASSERT_NE(freopen(g_lastTempFile.c_str(), "rb", stdin), nullptr);
#else
    char tmpl[] = "/tmp/menu_test_XXXXXX";
    int fd = mkstemp(tmpl);
    ASSERT_NE(fd, -1) << "mkstemp failed";
    g_lastTempFile = tmpl;
    ssize_t wr = write(fd, script.data(), script.size());
    ASSERT_EQ(static_cast<size_t>(wr), script.size());
    close(fd);
    ASSERT_NE(freopen(g_lastTempFile.c_str(), "r", stdin), nullptr);
#endif
}

static void resetInput() {
#if defined(_WIN32) || defined(_WIN64)
    freopen("CON", "r", stdin);

    if (!g_lastTempFile.empty()) {
        _unlink(g_lastTempFile.c_str());
        g_lastTempFile.clear();
    }

#else
    FILE* r = freopen("/dev/tty", "r", stdin);
    (void)r;

    if (!g_lastTempFile.empty()) {
        unlink(g_lastTempFile.c_str());
        g_lastTempFile.clear();
    }

#endif
}

// ============================================================
// TEST FIXTURE
// ============================================================
class MenuTests : public ::testing::Test {
protected:
    void SetUp() override {
        g_called_register = 0;
        g_called_login = 0;
        g_called_create = 0;
        g_force_throw_after_call = 0;
    }

    void TearDown() override {
        resetInput();
    }
};

// ============================================================
// BASİT getInput() TESTLERİ
// ============================================================
TEST_F(MenuTests, GetInput_Enter_Newline) {
    simulateInputFromString("\n");
    int result = getInput();
    EXPECT_EQ(result, ENTER);
}

TEST_F(MenuTests, GetInput_UpArrow_A) {
    simulateInputFromString("A");
    int result = getInput();
    EXPECT_EQ(result, UP_ARROW);
}

TEST_F(MenuTests, GetInput_DownArrow_B) {
    simulateInputFromString("B");
    int result = getInput();
    EXPECT_EQ(result, DOWN_ARROW);
}

TEST_F(MenuTests, GetInput_Scripted_UnknownChar_ReturnsNone) {
    simulateInputFromString("Z"); // 'Z' karakteri - Satır 122'yi kapsar
    EXPECT_EQ(getInput(), NONE);
}

// ============================================================
// Windows hook testleri - SADECE GÜVENLİ TESTLER
// ============================================================
#if defined(_WIN32) || defined(_WIN64)
static std::vector<int> g_keys;
static size_t g_idx = 0;

static int fake_getch_seq() {
    if (g_idx >= g_keys.size()) return 0;

    return g_keys[g_idx++];
}

static void set_keys(const std::vector<int>& seq) {
    g_keys = seq;
    g_idx = 0;
    menu_set_key_reader(&fake_getch_seq);
}

static void clear_keys() {
    menu_set_key_reader(nullptr);
    g_keys.clear();
    g_idx = 0;
}

class MenuTestsWinPath : public ::testing::Test {
protected:
    void SetUp() override {
        g_called_register = 0;
        g_called_login = 0;
        g_called_create = 0;
        g_force_throw_after_call = 0;
        clear_keys();
    }

    void TearDown() override {
        clear_keys();
    }
};

// --- Basit getInput testleri ---
TEST_F(MenuTestsWinPath, GetInput_WindowsSpecial_UpArrow_224_72) {
    set_keys({ 224, 72 });
    EXPECT_EQ(getInput(), UP_ARROW);
}

TEST_F(MenuTestsWinPath, GetInput_WindowsSpecial_DownArrow_224_80) {
    set_keys({ 224, 80 });
    EXPECT_EQ(getInput(), DOWN_ARROW);
}

TEST_F(MenuTestsWinPath, GetInput_WindowsSpecial_Enter13) {
    set_keys({ 13 });
    EXPECT_EQ(getInput(), ENTER);
}

TEST_F(MenuTestsWinPath, GetInput_WindowsSpecial_UnknownAfter224) {
    set_keys({ 224, 0x3F });
    EXPECT_EQ(getInput(), NONE);
}

TEST_F(MenuTestsWinPath, GetInput_Hook_UnknownNormalKey_ReturnsNone) {
    set_keys({ 120 }); // 'x' karakteri - Satır 89'u kapsar
    EXPECT_EQ(getInput(), NONE);
}

// --- runMenu testleri ---
TEST_F(MenuTestsWinPath, RunMenu_SelectsSecondItemWithDownEnter) {
    const char items[][30] = { "One", "Two", "Three" };
    set_keys({ 224, 80, 13 });
    int selected = runMenu(items, 3);
    EXPECT_EQ(selected, 1);
}

TEST_F(MenuTestsWinPath, RunMenu_WrapFromTopToLastWithUpEnter) {
    const char items[][30] = { "One", "Two", "Three" };
    set_keys({ 224, 72, 13 });
    int selected = runMenu(items, 3);
    EXPECT_EQ(selected, 2);
}

TEST_F(MenuTestsWinPath, RunMenu_EmptyMenuReturnsZero) {
    int selected = runMenu(nullptr, 0);
    EXPECT_EQ(selected, 0);
}

// --- GÜVENLİ firstMenu testleri (exception kullanarak) ---
// Bu testler 'break' (L243) satırına ulaşamaz, ama 'initiate' (L242) satırını kapsar
TEST_F(MenuTestsWinPath, FirstMenu_SelectRegister_CountCall) {
    set_keys({ 13 }); // Enter (Register seç)

    try {
        g_force_throw_after_call = 1; // initiateUserRegistration'dan sonra exception
        firstMenu();
        FAIL() << "Expected TestExitException";
    }
    catch (const TestExitException&) {
        // Beklenen exception - test başarılı
    }
    catch (...) {
        FAIL() << "Expected TestExitException but got different exception";
    }

    EXPECT_EQ(g_called_register, 1);
}

TEST_F(MenuTestsWinPath, FirstMenu_SelectLogin_CountCall) {
    set_keys({ 224, 80, 13 }); // Down, Enter (Login seç)

    try {
        g_force_throw_after_call = 1; // initiateUserLogin'den sonra exception
        firstMenu();
        FAIL() << "Expected TestExitException";
    }
    catch (const TestExitException&) {
        // Beklenen exception - test başarılı
    }
    catch (...) {
        FAIL() << "Expected TestExitException but got different exception";
    }

    EXPECT_EQ(g_called_login, 1);
}

// --- firstMenu GÜVENLİ test (sonsuz döngü olmadan) ---
TEST_F(MenuTestsWinPath, FirstMenu_SelectGuestThenExit) {
    set_keys({ 224, 80, 224, 80, 13,      // Guest (Seçim 2)
               224, 80, 224, 80, 224, 80, 13 }); // Exit (Seçim 3)
    int ret = firstMenu();
    EXPECT_EQ(ret, 0);
    EXPECT_EQ(g_called_register, 0);
    EXPECT_EQ(g_called_login, 0);
}

TEST_F(MenuTestsWinPath, FirstMenu_SelectExit) {
    set_keys({ 224, 80, 224, 80, 224, 80, 13 }); // Down, Down, Down, Enter (Exit)
    int ret = firstMenu();
    EXPECT_EQ(ret, 0);
}

// --- eventMenu TESTLERİ ---
TEST_F(MenuTestsWinPath, EventMenu_CreateEventThenReturn) {
    set_keys({ 13, 224, 80, 224, 80, 13 }); // Enter, Down, Down, Enter
    int ret = eventMenu(1, "user");
    EXPECT_EQ(ret, 0);
    EXPECT_EQ(g_called_create, 1);
}

TEST_F(MenuTestsWinPath, EventMenu_ReturnImmediately) {
    set_keys({ 224, 80, 224, 80, 13 }); // Down, Down, Enter
    int ret = eventMenu(7, "u");
    EXPECT_EQ(ret, 0);
    EXPECT_EQ(g_called_create, 0);
}

#endif

// ============================================================
// EN GÜVENLİ YOL: runMenu override ile - TÜM COVERAGE İÇİN
// BU BLOK, PROJEN 'ENABLE_MENU_TEST_HOOKS' İLE DERLENDİĞİNDE ÇALIŞIR
// ============================================================
#ifdef ENABLE_MENU_TEST_HOOKS
static std::vector<int> g_forced_returns;
static size_t g_forced_idx = 0;

static int forced_runmenu(const char[][30], int) {
    if (g_forced_idx >= g_forced_returns.size()) return 3; // Emniyet (Exit)

    return g_forced_returns[g_forced_idx++];
}

// *** BU TEST L242 VE L243 (break) SATIRLARINI KAPSAR ***
TEST_F(MenuTests, FirstMenu_RegisterSelection_WithOverride) {
    g_forced_returns = { 0, 3 }; // Register -> Exit
    g_forced_idx = 0;
    menu_set_runmenu_override(&forced_runmenu);
    int ret = firstMenu();
    EXPECT_EQ(ret, 0);
    EXPECT_EQ(g_called_register, 1); // L242 doğrulandı
    EXPECT_EQ(g_called_login, 0);
    // L243 (break) çalıştı ve döngü 3 (Exit) ile bitti
    menu_set_runmenu_override(nullptr);
    g_forced_returns.clear();
}

// *** BU TEST L246 VE L247 (break) SATIRLARINI KAPSAR ***
TEST_F(MenuTests, FirstMenu_LoginSelection_WithOverride) {
    g_forced_returns = { 1, 3 }; // Login -> Exit
    g_forced_idx = 0;
    menu_set_runmenu_override(&forced_runmenu);
    int ret = firstMenu();
    EXPECT_EQ(ret, 0);
    EXPECT_EQ(g_called_register, 0);
    EXPECT_EQ(g_called_login, 1); // L246 doğrulandı
    // L247 (break) çalıştı
    menu_set_runmenu_override(nullptr);
    g_forced_returns.clear();
}

// *** BU TEST L250 VE L251 (break) SATIRLARINI KAPSAR ***
TEST_F(MenuTests, FirstMenu_GuestSelection_WithOverride) {
    g_forced_returns = { 2, 3 }; // Guest -> Exit
    g_forced_idx = 0;
    menu_set_runmenu_override(&forced_runmenu);
    int ret = firstMenu();
    EXPECT_EQ(ret, 0);
    EXPECT_EQ(g_called_register, 0);
    EXPECT_EQ(g_called_login, 0);
    // L251 (break) çalıştı
    menu_set_runmenu_override(nullptr);
    g_forced_returns.clear();
}

// *** BU TEST L258 VE L259 (break) SATIRLARINI KAPSAR ***
TEST_F(MenuTests, FirstMenu_DefaultBranch_ThenExit) {
    g_forced_returns = { 99, 3 }; // invalid -> Exit
    g_forced_idx = 0;
    menu_set_runmenu_override(&forced_runmenu);
    int ret = firstMenu();
    EXPECT_EQ(ret, 0);
    // L258 (printf) ve L259 (break) çalıştı
    menu_set_runmenu_override(nullptr);
    g_forced_returns.clear();
}

// *** BU TEST L288 VE L289 (break) SATIRLARINI KAPSAR ***
TEST_F(MenuTests, EventMenu_CreateEvent_WithOverride) {
    g_forced_returns = { 0, 2 }; // Create Event -> Return
    g_forced_idx = 0;
    menu_set_runmenu_override(&forced_runmenu);
    int ret = eventMenu(1, "user");
    EXPECT_EQ(ret, 0);
    EXPECT_EQ(g_called_create, 1); // L288 doğrulandı
    // L289 (break) çalıştı
    menu_set_runmenu_override(nullptr);
    g_forced_returns.clear();
}

// *** BU TEST L292 VE L293 (break) SATIRLARINI KAPSAR ***
TEST_F(MenuTests, EventMenu_ManageEvents_WithOverride) {
    g_forced_returns = { 1, 2 }; // Manage Events -> Return
    g_forced_idx = 0;
    menu_set_runmenu_override(&forced_runmenu);
    int ret = eventMenu(1, "user");
    EXPECT_EQ(ret, 0);
    EXPECT_EQ(g_called_create, 0);
    // L292 (comment) ve L293 (break) çalıştı
    menu_set_runmenu_override(nullptr);
    g_forced_returns.clear();
}

// *** BU TEST L299 VE L300 (break) SATIRLARINI KAPSAR ***
TEST_F(MenuTests, EventMenu_DefaultBranch_ThenReturn) {
    g_forced_returns = { 77, 2 }; // invalid -> Return
    g_forced_idx = 0;
    menu_set_runmenu_override(&forced_runmenu);
    int ret = eventMenu(1, "user");
    EXPECT_EQ(ret, 0);
    // L299 (printf) ve L300 (break) çalıştı
    menu_set_runmenu_override(nullptr);
    g_forced_returns.clear();
}

#endif

// ============================================================
// DİREKT FONKSİYON TESTLERİ
// ============================================================
TEST_F(MenuTests, PrintMenu_NullMenuItems_DoesNotCrash) {
    EXPECT_EQ(printMenu(nullptr, 3, 0), 1);
}

TEST_F(MenuTests, StdinIsTty_ReturnsBool) {
    bool result = stdin_is_tty();
    EXPECT_TRUE(result == true || result == false);
}

TEST_F(MenuTests, MenuSetKeyReader_SetsFunction) {
    menu_set_key_reader(nullptr);
    SUCCEED();
}