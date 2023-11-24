# Salus IT600 thermostats integration

Virtual device that allow to control Salus IT600 thermostats. It creates three child devices that show current temperature, humidity and heating status in form of binary switch.

## Configuration

`Username` - Velux username

`Password` - Velux password

`DeviceID` - ID of the device

`Interval` - Update interval expressed in seconds (30s by default)


## Installation

Follow regular installation process. After virtual device will be added to your Home Center unit, click on Variables and provide `Username` and `Password`.
Then, click on `Search devices` button which will pull all information from your Salus account that includes Gateways and associated Devices.

If you're installing another device, your Username and Password will be automatically populated from previous device.

To access pulled information, go to logs of the device, review detected devices and use proper IDs as variables of the QuickApp.

To change update interval add Interval property or replace existing one (if there's no edit botton).

## Notes

Salus API is locking account for 30 minutes after few invalid login attempts. If you'll change your password, virtual devices may lock your account.

## Changes

### v.1.3.0
 - UI improvements

### v.1.2.0
 - Improved API error handling

### v.1.1.0
 - Feature: Battery level reporting

### v.1.1.1
 - Fix: Auth token refreshing
