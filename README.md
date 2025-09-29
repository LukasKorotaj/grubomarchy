# Omarchy

Turn a fresh Arch installation into a fully-configured, beautiful, and modern web development system based on Hyprland by running a single command. That's the one-line pitch for Omarchy (like it was for Omakub). No need to write bespoke configs for every essential tool just to get started or to be up on all the latest command-line tools. Omarchy is an opinionated take on what Linux can be at its best.

Read more at [omarchy.org](https://omarchy.org).

---

# Fork Info
This is a fork of Omarchy that uses GRUB instead of Limine, doesn't require disk encryption and, because of that, uses sddm.

## Why?
I sometimes need to dual-boot on my laptop with one nvme-slot.

## How to install
Follow the official [manual installation guide](https://learn.omacom.io/2/the-omarchy-manual/96/manual-installation). You can ignore the disk configuration, disk encryption and bootloader parts. 
The guide is correct apart from the last paragraph where Omarchy should prompt for name and e-mail. I had to dig through commits to fix that :).

## Drawbacks
* Master branch was only tested on a VM.
* Didn't check if btrfs is still required.
* Ugly sddm/GRUB screen because of theme licences, you will have to install those yourself.

Apart from that the core Omarchy functionality is there.

---

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
