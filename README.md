# NightShiftPatcher

**Enable Night Shift on unsupported machines**

Original idea by [Pike](https://pikeralpha.wordpress.com/2017/01/30/4398)

Motivated by [NightPatch](https://github.com/pookjw/NightPatch)

## Contributions

- macOS 10.14 Mojave compatibility fix by [@albinoz](https://github.com/albinoz)

## How to use

1. Disable [SIP](https://developer.apple.com/library/content/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html)[*](https://en.wikipedia.org/wiki/System_Integrity_Protection)
2. Execute ***NightShiftPatcher.sh*** script with superuser privileges (using [sudo](https://en.wikipedia.org/wiki/Sudo), for example)
3. Don't forget to reenable SIP. This is not required, but recommended for system security ;)

## In case of error

- If the system does not boot, restart in [single-user mode](https://support.apple.com/en-bh/HT201573) or with the [recovery partition](https://support.apple.com/en-us/HT201314). 

- The backup file can be found here:

  ```sh
  /System/Library/PrivateFrameworks/CoreBrightness.framework.bak
  ```

- If you used an old `NightShiftPatcher` script (before September 2018), first remove this file from the backup:

  ```sh
  rm '/System/Library/PrivateFrameworks/CoreBrightness.framework.bak/Versions/Current/CoreBrightness.temp'
  ```

- To restore the backup with the terminal, you can use this terminal line:

  ```sh
  f='/System/Library/PrivateFrameworks/CoreBrightness.framework'; mv "${f}" "${f}.hack"; mv "${f}.bak" "${f}";
  ```



