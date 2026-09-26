#!/usr/bin/env bash
# ==============================================================================
#  login_simulation.sh — Імітація текстової консольної авторизації в GNU/Linux
#  Курс: Системне програмування
# ==============================================================================

# --- Налаштування кольорів ANSI ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m' # Скинути стиль

# --- Конфігурація системи ---
readonly HOSTNAME="sp-workstation"
readonly VALID_USER="admin"
readonly VALID_PASS="linux2026"
readonly MAX_ATTEMPTS=3
readonly LOCKOUT_TIME=10 # Секунди блокування при вичерпанні спроб

attempts=0

# --- Функція: Банер входу системи ---
print_banner() {
    clear
    echo ""
    echo -e "  ${CYAN}${BOLD}██████╗ ███╗   ██╗██╗   ██╗    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗${NC}"
    echo -e "  ${CYAN}██╔════╝ ████╗  ██║██║   ██║    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝${NC}"
    echo -e "  ${CYAN}██║  ███╗██╔██╗ ██║██║   ██║    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ ${NC}"
    echo -e "  ${CYAN}██║   ██║██║╚██╗██║██║   ██║    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ ${NC}"
    echo -e "  ${CYAN}╚██████╔╝██║ ╚████║╚██████╔╝    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗${NC}"
    echo -e "  ${CYAN} ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝     ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝${NC}"
    echo ""
    echo -e "  ${DIM}ОС: Ubuntu 24.04 LTS (Noble Numbat) | Ядро: $(uname -r 2>/dev/null || echo '6.8.0-generic')${NC}"
    echo -e "  ${DIM}Хост: ${HOSTNAME} | Дата: $(date '+%d.%m.%Y %H:%M:%S')${NC}"
    echo ""
    echo -e "  ${YELLOW}Введіть облікові дані для авторизації:${NC}"
    echo ""
}

# --- Функція: Блокування при перевищенні ліміту ---
lockout_user() {
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  [БЕЗПЕКА] Перевищено ліміт спроб (${MAX_ATTEMPTS})! Вхід заблоковано.${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for ((sec=LOCKOUT_TIME; sec>0; sec--)); do
        printf "\r  Зачекайте перед повторною спробою: ${YELLOW}%02d сек${NC}... " "$sec"
        sleep 1
    done
    
    echo -e "\n\n  ${GREEN}Блокування знято. Відновлення форми входу...${NC}"
    sleep 1.5
    attempts=0
    print_banner
}

# --- Функція: Успішна авторизація (MOTD) ---
welcome_screen() {
    local user="$1"
    clear
    echo ""
    echo -e "${GREEN}=================================================================${NC}"
    echo -e "${GREEN}${BOLD}  ✓ Авторизація успішна! Ласкаво просимо, ${user}.${NC}"
    echo -e "${GREEN}=================================================================${NC}"
    echo ""
    echo -e "  ${CYAN}Системний статус (MOTD):${NC}"
    echo -e "    • Останній вхід : $(date '+%a %b %d %T %Y') з 127.0.0.1"
    echo -e "    • Uptime        : $(uptime -p 2>/dev/null || echo 'up 5 days, 12 hours')"
    echo -e "    • Використання  : Диск 34% (34G/100G) | RAM 2.4G/16G"
    echo -e "    • Доступ        : /home/${user} (права: rwx)"
    echo ""
    echo -e "  ${DIM}Доступні демо-команди: whoami, pwd, ls, date, clear, exit${NC}"
    echo ""
}

# --- Головний цикл аутентифікації ---
print_banner

while true; do
    printf "  ${HOSTNAME} login: "
    read -r input_user

    # Прапор -s вимикає echo-відображення символів пароля
    printf "  Password: "
    read -rs input_pass
    echo ""

    if [[ "$input_user" == "$VALID_USER" && "$input_pass" == "$VALID_PASS" ]]; then
        welcome_screen "$input_user"
        break
    else
        (( attempts++ ))
        local_remaining=$(( MAX_ATTEMPTS - attempts ))
        echo ""
        echo -e "  ${RED}Login incorrect. Спроба помилкова.${NC}"

        if [[ $attempts -ge $MAX_ATTEMPTS ]]; then
            lockout_user
        else
            echo -e "  ${YELLOW}Залишилось спроб: ${local_remaining} з ${MAX_ATTEMPTS}${NC}\n"
        fi
    fi
done

# --- Інтерактивна міні-оболонка після успішного входу ---
while true; do
    printf "${GREEN}${VALID_USER}@${HOSTNAME}:${CYAN}~${NC}$ "
    read -r cmd

    case "$cmd" in
        exit|logout)
            echo -e "  ${CYAN}Завершення сеансу. logout.${NC}\n"
            exit 0 ;;
        whoami)
            echo "  $VALID_USER" ;;
        pwd)
            echo "  /home/$VALID_USER" ;;
        ls)
            echo -e "  ${CYAN}Desktop  Documents  Downloads  projects  public_html${NC}" ;;
        date)
            date ;;
        clear)
            clear ;;
        "") ;;
        *)
            echo -e "  bash: $cmd: команда не знайдена (режим симуляції)" ;;
    esac
done
