
for tool in dialog figlet; do
    if ! command -v "$tool" &>/dev/null; then
        echo "$tool is not installed. Install it with: sudo apt install $tool"
        exit 1
    fi
done

clear
figlet "Disk Cleanup Toolkit"
sleep 2

show_disk_usage() {
    df -h / > /tmp/df_output.txt
    dialog --title "Disk Usage" --textbox /tmp/df_output.txt 21 70
}

clean_apt() {
    sudo apt clean && sudo apt autoclean && sudo apt autoremove -y
    dialog --title "APT Cleanup" --msgbox "APT cache cleared." 10 40
}

remove_old_kernels() {
    CURRENT=$(uname -r)
    KERNELS=$(dpkg --list | grep linux-image | awk '{print $2}' | grep -v "$CURRENT")
    echo "$KERNELS" | while read -r k; do sudo apt remove -y "$k"; done
    sudo apt autoremove -y
    dialog --title "Old Kernels" --msgbox "Old kernels removed." 10 40
}

clean_journal_logs() {
    sudo journalctl --vacuum-time=7d
    dialog --title "Journal Logs" --msgbox "Logs older than 7 days removed." 10 50
}

clean_user_cache() {
    rm -rf ~/.cache/thumbnails/* ~/.cache/*
    dialog --title "User Cache" --msgbox "User cache cleaned." 10 50
}

clean_tmp() {
    sudo rm -rf /tmp/*
    dialog --title "/tmp Cleaned" --msgbox "/tmp directory cleaned." 10 40
}

run_all_tasks() {
    clean_apt
    remove_old_kernels
    clean_journal_logs
    clean_user_cache
    clean_tmp
    dialog --title "All Tasks" --msgbox "All cleanup tasks completed!" 10 40
}

while true; do
    CHOICE=$(dialog --clear --backtitle "Disk Cleanup Toolkit" \
        --title "Main Menu" \
        --menu "Choose a cleanup option:" 20 60 10 \
        1 "Show Disk Usage" \
        2 "Clear APT Cache" \
        3 "Remove Old Kernels" \
        4 "Clean Journal Logs" \
        5 "Clean User Cache" \
        6 "Clean /tmp" \
        7 "Run All Cleanup Tasks" \
        8 "Exit" \
        3>&1 1>&2 2>&3)

    case $CHOICE in
        1) show_disk_usage ;;
        2) clean_apt ;;
        3) remove_old_kernels ;;
        4) clean_journal_logs ;;
        5) clean_user_cache ;;
        6) clean_tmp ;;
        7) run_all_tasks ;;
        8) clear; exit 0 ;;
    esac
done