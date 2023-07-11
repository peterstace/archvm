# Arch VM

This repo contains a set of scripts to do the basic provisioning for my
Arch Linux development VM. The scripts only perform provisioning for the base
OS. Separate scripts (stored elsewhere) are used for full setup.

## Bootable Image

Download latest Arch Linux image:

| Architecture | Image                                            | Notes                                                                                 |
| ---          | ---                                              | ---                                                                                   |
| `x86_64`     | [Link](https://www.archlinux.org/download/)      |                                                                                       |
| `aarch64`    | [Link](https://archboot.com/iso/aarch64/latest/) | The image filename matches the format `archboot-YYYY.MM.DD-HH.SS-latest-aarch64.iso`. |

## Set up the VM

Ensure you're running the latest version of the virtualisation software (e.g.
Virtual Box or Parallels).

It's important that the VM is set up to use UEFI. Parallels does this by
default. Virtual Box must be configured to boot with UEFI.

The VM should be given name `archvmYYYYMMDD`.

Resource settings:

| Setting | Home   | Work   |
| ---     | ---    | ---    |
| CPU     | 2      | 6      |
| Memory  | 2048MB | 8192MB |
| Disk    | 64GB   | 250GB  |

## Invoke install script

Once the VM boots up into the live installer, execute the following steps by
typing them manually:

```
loadkeys dvorak
curl -L tinyurl.com/52f3wz3n | bash
```

## Forward ports

The port `22DD` on the host should be forwarded to `22` on the guest (for SSH).

In VMware Fusion, this can be done by configuring a custom network named "NAT
w/ Ports", which contains the appropriate forwarding rule. The VM should then
be configured to use that network. To get the IP address of the VM, use the `ip
addr` command inside the VM itself.

# TODOs

- Does using the "larger" image really matter? All things being equal, smaller
  image is better. Need to try out both (I've been using the "larger" one).

- Work out how to install from the generic ARM images.

- Strip anything from the install scripts that aren't actually needed.

- Add comments for _why_ everything is needed.

- Use notices rather than comments.
