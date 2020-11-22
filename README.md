# Arch VM

This repo details the protocol for setting up my development VM.

## Prelude

Download latest [Arch Linux image](https://www.archlinux.org/download/).

Ensure you're running the latest version of Virtual Box.

Create a new virtual machine using the following details:

| Setting | Value                                                    |
| ---     | ---                                                      |
| Name    | `archvm_YYYYMMDD`                                        |
| Type    | Linux                                                    |
| Version | Arch Linux (64-bit)                                      |
| Memory  | 1024 MB (16384MB for work)                               |
| Disk    | New, VDI, Dynamic, default name, 100 GB (250GB for work) |

Update the following settings:

| Setting | Value                                    |
| ---     | ---                                      |
| System  | 1 CPU (6 for work)                       |
| Storage | Downloaded Arch Linux image              |
| Audio   | Uncheck "Enable Audio"                   |
| Network | Forward 22DD->22, 8080, 8081, 8000, 8001 |

## Step 1

Start the VM then run the following commands:

```
loadkeys dvorak
echo DNSSEC=false >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service
curl https://raw.githubusercontent.com/peterstace/archvm/master/install.sh | bash
shutdown -h now
```

## Step 2

Unmount the live CD, start the VM up again, and login as root.

Run the following commands:

```
/archvm/post_install.sh
shutdown -h now
```

## Step 3

Start the VM, but don't login. Instead, SSH into the machine using the following command:

```
ssh -p 22XX petsta@localhost
```

Then run the following command:

```
/archvm/setup.sh
```
