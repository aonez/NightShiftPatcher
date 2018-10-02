# NightShiftPatcher

**Enable Night Shift on unsupported machines**

Original idea by [Pike](https://pikeralpha.wordpress.com/2017/01/30/4398)

Motivated by [NightPatch](https://github.com/pookjw/NightPatch)

## Contributions

- macOS 10.14 Mojave compatibility fix by [@albinoz](https://github.com/albinoz)

## How to use

1. Download the latest stable script from the [Releases](https://github.com/aonez/NightShiftPatcher/releases) section
2. Disable [SIP](https://developer.apple.com/library/content/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html)[*](https://en.wikipedia.org/wiki/System_Integrity_Protection)
3. Execute `NightShiftPatcher.sh` script
4. Don't forget to reenable SIP. This is not required, but recommended for system security ;)

## In case of error

- If the system does not boot, restart in [single-user mode](https://support.apple.com/en-bh/HT201573) or with the [recovery partition](https://support.apple.com/en-us/HT201314)

- You can restore the backup using the `NightShiftPatcher` script since `1.0` version with the `-r` option:

  ```sh
  ./NightShiftPatcher.sh -r
  ```

- The backup file can be found here:

  ```sh
  /System/Library/PrivateFrameworks/CoreBrightness.framework.bak
  ```

- If you used an old `NightShiftPatcher` script (before September 2018), first remove those files from the backup:

  ```sh
  sudo rm '/System/Library/PrivateFrameworks/CoreBrightness.framework.bak/Versions/Current/CoreBrightness.temp'
  sudo rm '/System/Library/PrivateFrameworks/CoreBrightness.framework.bak/Versions/Current/CoreBrightness.tbd'
  ```

- To restore the backup with the terminal, you can use this terminal line:

  ```sh
  sudo f='/System/Library/PrivateFrameworks/CoreBrightness.framework'; mv "${f}" "${f}.hack"; mv "${f}.bak" "${f}";
  ```



