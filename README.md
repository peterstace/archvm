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
| Memory  | 4096 MB                                 |
| Disk    | New, VDI, Dynamic, default name, 100 GB |

Update the following settings:

| Setting        | Value                            |
| ---            | ---                              |
| Storage        | Downloaded Arch Linux image      |
| Network        | Forward 8000->8000, 2222->22     |
| Shared Folders | `~/Downloads` (check Auto-mount) |

## Pre-Install

```
loadkeys dvorak
```

## Install

1. Run the install script. Once it is complete, the VM will shut down. `curl https://raw.githubusercontent.com/peterstace/archvm/master/install.sh | bash`

2. Unmount the live CD and start the VM up again (don't log in).

3. Then SSH into the machine using using `ssh -p 2222 petsta@localhost`.

4. Run the setup script using `curl https://raw.githubusercontent.com/peterstace/archvm/master/setup.sh | bash`
