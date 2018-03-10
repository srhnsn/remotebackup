@echo off

cd ..

vagrant ssh -c "sudo -i systemctl stop rb_watchdog rb_sync"
vagrant ssh -c "sudo -i close_all.sh"

pause
