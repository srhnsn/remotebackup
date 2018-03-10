@echo off

cd ..

vagrant ssh -c "sudo -i systemctl start rb_sync rb_watchdog"

pause
