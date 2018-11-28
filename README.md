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

```
curl https://raw.githubusercontent.com/peterstace/archvm/master/install.sh | bash
```

Unmount the live CD, restart, then login as petsta.

```
curl https://raw.githubusercontent.com/peterstace/archvm/master/setup.sh | bash
```
