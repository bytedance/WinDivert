# Contributing to WinDivert

> See also: [https://reqrypt.org/windivert-doc.html#building](https://reqrypt.org/windivert-doc.html#building)

## Prerequisites

- [Visual Studio Community 2019](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&rel=16) :  Unfortunately we can't use VS2022, that **no support for building drivers that target any Windows version before Windows 10** and **no support for building 32-bit drivers** **.** See also [https://www.osr.com/blog/2022/09/21/the-windows-driver-kit-and-visual-studio-2022/](https://www.osr.com/blog/2022/09/21/the-windows-driver-kit-and-visual-studio-2022/)
- **[WDK for Windows 11, version 21H2](https://go.microsoft.com/fwlink/?linkid=2166289)**

## Building

To build the WinDivert drivers from source:

1. Download and install [Windows Driver Kit 7.1.0](http://www.microsoft.com/whdc/devtools/wdk/default.mspx).
2. Open a `Developer Command Prompt for VS 2019` / `Developer PowerShell for VS 2019` console.
3. In the WinDivert package root directory, run the command:

   ```cmd
   msvc-build.bat
   ```

   The generated `WinDivert.dll`/`WinDivert.lib` files should be compatible with all major compilers, including both MinGW and Visual Studio.

## Driver Signing

> To install the driver, it must be signed. The driver signing process is described in detail in the [Windows Driver Kit documentation](https://docs.microsoft.com/en-us/windows-hardware/drivers/develop/signed-drivers).

1. Copy `.env.sample` file as `.env` , and update the variables' value with your cert service info
2. Run `sh scripts/sign.sh` to make and sign cab file
3. Upload the `install/WinDivert.cab` file to [Microsoft Partner Center](https://partner.microsoft.com/zh-cn/dashboard/hardware/Search)

## Installing/Uninstalling

- [Install the driver](https://reqrypt.org/windivert-doc.html#installing)
- [Uninstall the driver](https://reqrypt.org/windivert-doc.html#uninstalling)
