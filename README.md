# Arch VM

This repo details the protocol for setting up my development VM.

## Prelude

Download latest [Arch Linux image](https://www.archlinux.org/download/).

Ensure you're running the latest version of Virtual Box.

Create a new virtual machine using the following details:

| Setting | Value                                   |
| ---     | ---                                     |
| Name    | `archvm_YYYYMMDD`                       |
| Type    | Linux                                   |
| Version | Arch Linux (64-bit)                     |
| Memory  | 1024 MB                                 |
| Disk    | New, VDI, Dynamic, default name, 100 GB |

Update the following settings:

| Setting | Value                        |
| ---     | ---                          |
| System  | 1 CPU                        |
| Storage | Downloaded Arch Linux image  |
| Network | Forward 8000->8000, 22DD->22 |
| Audio   | Disable audio output         |

## Step 1

Start the VM then run the following commands:

```
loadkeys dvorak
curl https://raw.githubusercontent.com/peterstace/archvm/master/install.sh | bash
shutdown -h now
```

## Step 2

Unmount the live CD, start the VM up again, and login as root.

Run the following commands:

```
/archvm/post_install.sh
reboot
```

## Step 3

Don't login. Instead, SSH into the machine using the following command:

```
ssh -p 22XX petsta@localhost
```

Then run the following command:

```
/archvm/setup.sh
```
