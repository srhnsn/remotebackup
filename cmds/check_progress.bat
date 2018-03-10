@echo off

cd ..

vagrant ssh -c "sudo -i journalctl -u rb_sync -afn 500"

pause
