remotebackup
============

`remotebackup` is a Vagrant project for storing encrypted backups on an untrusted remote server using [SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol) under Windows. Involved technologies and tools:

1. VirtualBox
1. Vagrant
1. rsync
1. SFTP
1. sshfs
1. cryptsetup, LUKS, dm-crypt
1. ext4


Getting started
---------------

1. Copy the directory `settings-example` and its contents to a location where you want to store your `remotebackup` settings.
1. Copy `vagrant.yaml.example` to `vagrant.yaml` and adapt to your needs:
    1. Change `mounts.source` to the Windows path you want to backup.
    1. Make sure the path at `mounts.settings` points to the directory of your settings from step 1.
1. Customize the files in your settings directory:
    1. `remote_storage_key` needs to contain the private SSH key to the remote SFTP server.
    1. `settings.sh` needs to contain the remote SSH server credentials.
    1. Optional: `authorized_keys` can contain a public SSH key if you want to login to the VM without a password.
    1. Optional: `known_hosts` can contain a SSH server fingerprint if you do not want to confirm the remote server identity on the first connection after VM initialization.
        * You can use the output of the command `ssh-keyscan -H <host> 2> /dev/null`.
1. Open a command prompt in the main directory and run `vagrant up`.
1. Connect to the VM using the address `root@192.168.50.50` and the private key corresponding to the public key in `authorized_keys`.


Tasks
-----

### Create a new volume

1. Run `mount_remote_storage.sh`.
1. Run `/provisioning/share/create_new_volume.sh`. You will be asked for a volume size and password.
1. Run `close_all.sh`.


### Mount and open (decrypt) remote backup

1. Run `mount_and_open.sh`.

If you choose to cache the volume password, the watchdog can automatically reconnect and reopen the volume on connection errors. The password will be cached on a tmpfs volume, i.e. it will be gone when the VM is powered off.


### Close opened remote backup

1. Run `close_all.sh`.
    * The sync process must not be running.
        * Run `systemctl stop rb_watchdog sync` to stop both background processes (see below).


### Start synchronization (foreground)

1. Run `run_sync.sh`.


### Start synchronization (background)

1. Run `systemctl start sync`.
1. Run `journalctl -u sync -af` to check the sync progress.
1. Run `systemctl stop sync` to stop the sync process.


### Start watchdog (background)

The watchdog will continuously check if the opened remote backup is writable. If there is an error, it will stop the sync process and run `close_all.sh`. If the volume password was cached (see above), it will try to mount the remote storage, open the volume and start the sync process again.

1. Run `systemctl start rb_watchdog`.
1. Run `journalctl -u rb_watchdog -af` to check for any watchdog actions.
    * Add `-n 200` parameter to show more (200) previous lines.
1. Run `systemctl stop rb_watchdog` to stop the watchdog.


License
-------

[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)
