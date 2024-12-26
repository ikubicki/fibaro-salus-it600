# Salus IT600 thermostats integration

Virtual device that allow to control Salus IT600 thermostats. It creates three child devices that show current temperature and humidity. The previous binary switch was removed and replaced with operating status on main device.

Due to discontinuation of the cloud access, it is necessary to switch to a local mode in Salus Gateway and use a proxy solution.

There's ability to use aeslib library to communicate with gateway directly, however running aes encryption every few seconds, may affect the performance of HC unit. I decided to go with a JS based proxy. Which you can find [here](https://registry.hub.docker.com/r/irekk/salus-proxy) and [here](https://github.com/ikubicki/salus-proxy).

## Configuration

`User` - Salus prpxy user

`Password` - Salus proxy password

`Host` - IP or hostname of the docker proxy

### Optional properties

`Port` - Port of the docker proxy. Defaults to 80

`DeviceID` - ID of the device

`Interval` - Update interval expressed in seconds (5s by default)


## Installation

Follow regular installation process. After virtual device will be added to your Home Center unit, click on Variables and provide following variables:
 * `User` Proxy user name - not salus username (previous `Username` variable was replaced due to review all the whole configuration)
* `Password` Proxy user password - not salus user password
* `Host` Proxy IP address or hostname (without protocol and path).

Once saved, the device should automatically pull list of device and present in the select field, where you can choose the device.

This should improve the UX of the device.

If you're installing another device, your User, Password Host and Port variables will be automatically populated from previous device.

## Notes

Salus API is locking account for 30 minutes after few invalid login attempts. If you'll change your password, virtual devices may lock your account.

## Change

### v.2.0.0
 - Uses local mode
 - UX iprovements

### v.1.3.0
 - UI improvements

### v.1.2.0
 - Improved API error handling

### v.1.1.0
 - Feature: Battery level reporting

### v.1.1.1
 - Fix: Auth token refreshing
