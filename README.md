# Deprecated?

All Riru users and Riru modules should migrate to Zygisk.

# Riru

Riru only does one thing, inject into zygote in order to allow modules to run their codes in apps or the system server.

> The name, Riru, comes from a character. (https://www.pixiv.net/member_illust.php?illust_id=74128856)

## Requirements

Android 6.0+ devices rooted with [Magisk](https://github.com/LSPosed/Magisk)

## Guide

### Install

  > The Magisk version requirement is enforced by Magisk Manager. You can check [Magisk's module installer script](https://github.com/topjohnwu/Magisk/blob/master/scripts/module_installer.sh).

  1. Download the zip from the [GitHub release](https://github.com/Citrinae-Lime/Riru/releases)
  2. Install in Magisk Manager (Modules - Install from storage - Select downloaded zip)

### Common problems

* Third-party ROMs have incorrect SELinux rule

  <https://github.com/RikkaApps/Riru/wiki/Explanation-about-incorrect-SELinux-rules-from-third-party-ROMs-cause-Riru-not-working>

* Have low quality module that changes `ro.dalvik.vm.native.bridge` installed

  **If you are using other modules that change `ro.dalvik.vm.native.bridge`, Riru will not work.** (Riru will automatically set it back)

  A typical example is, some "optimize" modules change this property. Since changing this property is meaningless for "optimization", their quality is very questionable. In fact, changing properties for optimization is a joke.

## How Riru works?

* How to inject into the zygote process?

  We found a super easy way, the "native bridge" (`ro.dalvik.vm.native.bridge`). The specific "so" file will be automatically "dlopen-ed" and "dlclose-ed" by the system. This way is from [here](https://github.com/canyie/NbInjection).

* How to know if we are in an app process or a system server process?

  Some JNI functions (`com.android.internal.os.Zygote#nativeForkAndSpecialize` & `com.android.internal.os.Zygote#nativeForkSystemServer`) is to fork the app process or the system server process.
  So we need to replace these functions with ours. This part is simple, hook `jniRegisterNativeMethods` since all Java native methods in `libandroid_runtime.so` is registered through this function.
  Then we can call the original `jniRegisterNativeMethods` again to replace them.
  
## Build

Gradle tasks:

* `:riru:assembleDebug/Release`
   
   Generate Magisk module zip to `out`.

* `:riru:pushDebug/Release`
   
   Push the zip with adb to `/data/local/tmp`.

* `:riru:flashDebug/Release`
   
   Flash the zip with `adb shell su -c magisk --install-module`.

* `:riru:flashAndRebootDebug/Release`

   Flash the zip and reboot the device.

## Module template

https://github.com/RikkaApps/Riru-ModuleTemplate

## Module API changes

https://github.com/RikkaApps/Riru-ModuleTemplate/blob/master/README.md#api-changes